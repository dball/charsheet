class Wound
  include Mongoid::Document
  
  field :damage, type: Integer
  validates_numericality_of :damage, allow_nil: false, only_integer: true
  
  field :source, type: String
  field :damage_types, type: Array
end
