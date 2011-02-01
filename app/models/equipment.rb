class Equipment
  include Mongoid::Document         

  embedded_in :character, :inverse_of => :equipment
  embeds_many :effects

  field :name
  field :slot
  field :worn

  field :bonus_type
  Ability::ABILITIES.each do |ability|
    field "#{ability}_bonus"
  end
  field :ac_bonus

  scope :worn, where(:worn => true)
  scope :armor, where(:ac_bonus.gt => 0)

end
