class Effect
  include Mongoid::Document

  embedded_in :effector, :inverse_of => :effects

  field :type
  field :operator, :default => '+'
  Ability::ABILITIES.each do |ability|
    field ability
  end
  field :ac
  %w(fort reflex will).each do |save|
    field save
  end
  field :attack
  field :damage
  field :hp
  field :bab

end
