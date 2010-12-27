class Equipment
  include MongoMapper::Document         

  key :name, :required => true
  key :slot
  key :worn

  key :bonus_type
  Ability::ABILITIES.each do |ability|
    key "#{ability}_bonus"
  end

  belongs_to :character

end
