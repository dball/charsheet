class Equipment
  include Mongoid::Document         

  embedded_in :character, :inverse_of => :equipment
  embeds_many :effects

  field :name
  field :slot
  field :worn

  scope :worn, where(:worn => true)
  scope :armor, where(:slot => 'armor')

end