class Race
  include Mongoid::Document

  embedded_in :character, :inverse_of => :race
  embeds_many :effects

  field :name
  validates_presence_of :name

  field :size, :default => 'medium'
  field :speed, :type => Integer, :default => 30

end
