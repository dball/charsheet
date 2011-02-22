class Spell

  include Mongoid::Document

  referenced_in :library, :inverse_of => :spells
  embeds_many :effects

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name

end
