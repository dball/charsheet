class Equipment
  include Mongoid::Document         

  embedded_in :character, :inverse_of => :equipment
  embeds_many :effects

  field :name
  field :slot
  field :worn, :type => Boolean, :default => true

  scope :worn, where(:worn => true)
  scope :armor, where(:slot => 'armor')
  scope :weapons, where(:_type => 'Weapon')

  alias :all_effects :effects

end
