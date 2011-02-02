class Level
  include Mongoid::Document

  embedded_in :character, :inverse_of => :levels

  field :klass
  validates_presence_of :klass

  field :hp, :type => Integer
  validates_presence_of :hp

end
