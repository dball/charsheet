class Character
  include Mongoid::Document

  embeds_one :race
  validates_presence_of :race

  embeds_one :adjustment

  embeds_many :levels do
    def gain(cclass, hp, options = {})
      build(effect: { hp: hp }).tap do |level|
        # FIXME - why in the world can't I do this in the hash?
        level.cclass = cclass
        if options[:feats]
          level.feats += options[:feats]
        end
      end
    end
  end
  embeds_many :equipment
  embeds_many :buffs
  embeds_many :wounds
  embeds_many :scars

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def effects
    effectors = [race] + levels + equipment.worn + buffs.active
    effectors.push(adjustment) if adjustment.present?
    effectors.map { |effector| effector.all_effects }.flatten
  end

  def effective_value(base, field)
    value = base
    relevant = effects.select { |effect| effect.send(field).present? }
    assigns, adds = relevant.partition { |effect| effect.operator == '=' }
    unless assigns.empty?
      value = assigns.map { |effect| evaluate_effective_value(effect, field) }.max
      return value if field == :bab
    end
    adds.group_by(&:type).each do |type, effects|
      values = effects.map { |effect| evaluate_effective_value(effect, field) }
      value += if type.present? && type != 'dodge'
        values.max
      else
        values.reduce(&:+)
      end
    end
    value
  end

  def evaluate_effective_value(effect, field)
    value = effect.send(field)
    case value
      when Integer then value
      else
        # FIXME - hilariously unsafe use of instance_eval. And yet, so effective!
        instance_eval(value)
    end
  end

  Ability::ABILITIES.each do |ability|
    field "base_#{ability}", :type => Integer, :default => 10
    validates_numericality_of "base_#{ability}",
      :allow_nil => true, :only_integer => true

    define_method(ability.to_sym) do
      value = send("base_#{ability}")
      return unless value
      effective_value(value, ability)
    end

    define_method("#{ability}_modifier".to_sym) do
      (send(ability) - 10) / 2
    end

    define_method("#{ability}_bonus".to_sym) do
      [send("#{ability}_modifier"), 0].max
    end
  end

  Skill.all.each do |name, skill|
    field "#{name}_ranks".to_sym, :type => Integer, :default => 0
    validates_numericality_of "#{name}_ranks",
      :allow_nil => true, :only_integer => true

    define_method "#{name}_modifier".to_sym do
      skill = Skill.send(name)
      value = send("#{name}_ranks") + send("#{skill.ability}_modifier")
      Skill.all.each_pair do |oname, oskill|
        if send("#{oname}_ranks") >= 5
          if oskill.synergies.has_key?(name)
            condition = oskill.synergies[name]
            value += 2 unless condition
          end
        end
      end
      value
    end
  end

  def ac
    effective_value(10 + dex_modifier, :ac)
  end

  def size
    race.size
  end

  def speed
    effective_value(race.speed, :speed)
  end

  def hp
    effective_value(con_modifier * levels.length, :hp)
  end
  
  def current_hp
    damage = wounds.inject(0) { |sum, wound| sum + wound[:damage] }
    hp - damage
  end
  
  def wound(x, args = {})
    w = self.wounds.create({damage: x})
    w.damage_types = args[:types] if args[:types]
    w.source = args[:source ] if args[:source]
  end
  
  def heal(x)
    return unless wounds.length > 0
    targeted_wound = wounds.first
    targeted_wound[:damage] -= x
    if targeted_wound[:damage] <= 0
      self.scars.create({
        damage: targeted_wound[:initial_damage],
        source: targeted_wound[:source],
        damage_types: targeted_wound[:damage_types]
      })
      wounds.delete(targeted_wound)
      remaining = targeted_wound[:damage].abs
      self.heal(remaining) if remaining > 0
    end
  end

  { :fort => :con, :reflex => :dex, :will => :wis }.each_pair do |save, ability|
    define_method "#{save}_save" do
      effective_value(send("#{ability}_modifier"), save)
    end
  end

  def attacks
    attacks = equipment.worn.weapons.map do |weapon|
      Attack.new.tap do |attack|
        attack.name = weapon.name
        weapon_bonus = weapon.effects.map(&:attack).compact.reduce(&:+) || 0
        attack.bonus = str_modifier + bab + weapon_bonus
      end
    end
    attacks << Attack.new.tap do |attack|
      attack.name = 'unarmed'
      attack.bonus = str_modifier + bab
    end
  end

  def level
    levels.length
  end

  def bab
    effective_value(0, :bab)
  end

end
