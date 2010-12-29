class Equipment
  include MongoMapper::Document         

  key :name, :required => true
  key :slot
  key :worn

  key :bonus_type
  Ability::ABILITIES.each do |ability|
    key "#{ability}_bonus"
  end
  key :ac_bonus

  scope :worn, where(:worn => true)
  scope :armor, where(:ac_bonus.gt => 0)

  belongs_to :character

end
