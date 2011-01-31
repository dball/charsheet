class Effect
  include MongoMapper::Document

  key :type
  key :operator
  Ability::ABILITIES.each do |ability|
    key ability
  end
  key :ac

end
