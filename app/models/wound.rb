class Wound
  include Mongoid::Document
  
  field :damage, :type => Integer
  validates_numericality_of :damage, allow_nil: false, only_integer: true
end
