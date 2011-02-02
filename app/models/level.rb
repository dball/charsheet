class Level
  include Mongoid::Document

  embedded_in :character, :inverse_of => :levels

  field :klass
  validates_presence_of :klass

  field :hp, :type => Integer
  validates_presence_of :hp

  %w(fortitude reflex will).each do |save|
    field save, :type => Integer, :default => 0
    validates_presence_of save
  end

end
