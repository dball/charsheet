class Feature
  include Mongoid::Document

  embeds_many :effects
  embedded_in :cclass

  field :name
  validates_presence_of :name

  field :level, :type => Integer
  validates_numericality_of :level, :greater_than => 0

  field :description
end
