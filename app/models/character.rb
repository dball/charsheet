class Character
  include Mongoid::Document         

  embeds_many :equipment

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name

  def effects
    equipment.worn.map { |eq| eq.effects }.flatten
  end

  Ability::ABILITIES.each do |ability|
    field "base_#{ability}"
    validates_numericality_of "base_#{ability}",
      :allow_nil => true, :only_integer => true

    define_method(ability.to_sym) do
      value = send("base_#{ability}")
      return unless value
      #bonus_types = Set.new
      #equipment.worn.group_by(&:bonus_type).each do |bonus_type, items|
      #  bonuses = items.map { |item| item.send("#{ability}_bonus") }.compact
      #  unless bonuses.empty?
      #    if bonus_type.present?
      #      value += bonuses.sort.last
      #    else
      #      value = bonuses.inject(value) { |sum, bonus| sum + bonus }
      #    end
      #  end
      #end
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
    field "#{name}_ranks".to_sym, :default => 0
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

  def armor_class
    value = 10 + dex_modifier
    armor_effects = effects.select { |eff| eff.ac.present? }
    armor_effects.group_by(&:type).each do |type, effects|
      if type.present?
        value += effects.map(&:ac).sort.last
      else
        value = effects.inject(value) { |sum, effect| sum + effect.ac }
      end
    end
    value
  end

end
