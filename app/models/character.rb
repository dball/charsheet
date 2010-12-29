class Character
  include MongoMapper::Document         

  key :name, :required => true
  validates_uniqueness_of :name

  Ability::ABILITIES.each do |ability|
    key "base_#{ability}"

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
    attr_accessor "#{name}_ranks".to_sym
  end

  has_many :equipment

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
