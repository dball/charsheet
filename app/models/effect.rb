class Effect
  include Mongoid::Document

  embedded_in :effector, :inverse_of => :effects

  field :type
  field :operator, :default => '='
  Ability::ABILITIES.each do |ability|
    field ability, :type => Integer
  end
  field :ac, :type => Integer
  %w(fort reflex will).each do |save|
    field save, :type => Integer
  end
  field :attack, :type => Integer
  field :damage, :type => Integer

end
