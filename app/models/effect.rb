class Effect
  include Mongoid::Document

  embedded_in :equipment, :inverse_of => :effects

  field :type
  field :operator
  Ability::ABILITIES.each do |ability|
    field ability
  end
  field :ac

end
