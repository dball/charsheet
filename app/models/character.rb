class Character
  include Mongoid::Document         

  embeds_many :equipment

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name

  Ability::ABILITIES.each do |ability|
    field "base_#{ability}"
    validates_numericality_of "base_#{ability}",
      :allow_nil => true, :only_integer => true

    define_method(ability.to_sym) do
      value = send("base_#{ability}")
      return unless value
      bonus_types = Set.new
      equipment.worn.group_by(&:bonus_type).each do |bonus_type, items|
        bonuses = items.map { |item| item.send("#{ability}_bonus") }.compact
        unless bonuses.empty?
          if bonus_type.present?
            value += bonuses.sort.last
          else
            value = bonuses.inject(value) { |sum, bonus| sum + bonus }
          end
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
    equipment.worn.armor.group_by(&:bonus_type).each do |bonus_type, items|
      if bonus_type.present?
        value += items.map(&:ac_bonus).sort.last
      else
        value = items.inject(value) { |sum, item| sum + item.ac_bonus }
      end
    end
    value
  end

end
