class Effect
  include Mongoid::Document

  embedded_in :effector, :inverse_of => :effects

  field :type
  field :operator, :default => '='
  Ability::ABILITIES.each do |ability|
    field ability, :type => Integer
  end
  field :ac, :type => Integer

end
