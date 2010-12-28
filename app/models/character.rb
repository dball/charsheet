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
      worn = equipment.select(&:worn?)
      worn.group_by(&:bonus_type).each do |bonus_type, items|
        bonus = items.map do |item| 
          item.send("#{ability}_bonus")
        end.compact.sort.last
        value += bonus if bonus
      end
      value
    end
    define_method("#{ability}_modifier".to_sym) do
      (send(ability) - 10) / 2
    end
  end

  has_many :equipment

end
