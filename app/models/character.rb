class Character
  include Mongoid::Document         

  embeds_one :race
  validates_presence_of :race

  embeds_one :adjustment

  embeds_many :levels
  embeds_many :equipment
  embeds_many :buffs

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name

  def effects
    effectors = equipment.worn + buffs.active
    effectors.push(adjustment) if adjustment.present?
    effectors.map { |eq| eq.effects }.flatten
  end

  Ability::ABILITIES.each do |ability|
    field "base_#{ability}", :type => Integer
    validates_numericality_of "base_#{ability}",
      :allow_nil => true, :only_integer => true

    define_method(ability.to_sym) do
      value = send("base_#{ability}")
      return unless value
      ability_effects = effects.select { |eff| eff.send(ability).present? }
      ability_effects.group_by(&:type).each do |type, effects|
        if type.present?
          value += effects.map { |eff| eff.send(ability) }.sort.last
        else
          value = effects.inject(value) { |sum, eff| sum + eff.send(ability) }
        end
      end
      value
    end

    define_method("#{ability}_modifier".to_sym) do
      (send(ability) - 10) / 2
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
    value = 10 + dex_modifier
    armor_effects = effects.select { |eff| eff.ac.present? }
    armor_effects.group_by(&:type).each do |type, effects|
      if type.present? && type != 'dodge'
        value += effects.map(&:ac).sort.last
      else
        value = effects.inject(value) { |sum, effect| sum + effect.ac }
      end
    end
    value
  end

  def size
    race.size
  end

  def speed
    value = race.speed
    speed_effects = effects.select { |eff| eff.speed.present? }
    speed_effects.group_by(&:type).each do |type, effects|
      if type.present?
        value += effects.map(&:speed).sort.last
      else
        value = effects.inject(value) { |sum, effect| sum + effect.speed }
      end
    end
    value
  end

  def hp
    levels.inject(0) { |sum, level| sum += level.hp + con_modifier }
  end

end
