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
    relevant_effects = effects.select { |eff| eff.send(field).present? }
    relevant_effects.group_by(&:type).each do |type, effects|
      values = effects.map { |eff| eff.send(field) }
      # FIXME - hilariously unsafe use of instance_eval. And yet, so effective!
      values.map! { |value| value.is_a?(Integer) ? value : instance_eval(value) }
      value += if type.present? && type != 'dodge'
        values.max
      else
        values.reduce(&:+)
      end
    end
    value
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

  { :fort => :con, :reflex => :dex, :will => :wis }.each_pair do |save, ability|
    define_method "#{save}_save" do
      effective_value(send("#{ability}_modifier"), save)
    end
  end

  def attacks
    attacks = equipment.worn.weapons.map(&:name) + %w(unarmed)
    attacks.map { |name| Attack.new.tap { |attack| attack.name = name } }
  end

end
