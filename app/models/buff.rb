class Buff
  include Mongoid::Document

  embedded_in :character, :inverse_of => :buffs
  embeds_many :effects

  field :name
  field :active, :type => Boolean, :default => true

  scope :active, where(:active => true)

end
