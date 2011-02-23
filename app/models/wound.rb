class Wound
  include Mongoid::Document
  
  field :initial_damage, type: Integer
  field :damage, type: Integer
  validates_numericality_of :damage, allow_nil: false, only_integer: true
  
  field :source, type: String
  field :damage_types, type: Array
  
  after_create :record_initial_damage
  
  def record_initial_damage
    self.initial_damage = damage
  end
end
