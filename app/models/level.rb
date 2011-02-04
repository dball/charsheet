class Level
  include Mongoid::Document

  embedded_in :character, :inverse_of => :levels

  field :klass
  validates_presence_of :klass

  field :hp, :type => Integer
  validates_presence_of :hp
  validates_numericality_of :hp, :greater_than => 0

  %w(fortitude reflex will).each do |save|
    field save, :type => Integer, :default => 0
    validates_presence_of save
    validates_numericality_of save, :greater_than_or_equal_to => 0
  end

  scope :char_class, lambda { |name| where(:klass => name) }

  def level
    character.levels.index(self) + 1
  end

  def klass_level
    character.levels.char_class(klass).to_a.index(self) + 1
  end

end
