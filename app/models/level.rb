class Level
  include Mongoid::Document

  embedded_in :character, :inverse_of => :levels

  referenced_in :cclass

  def cclass_name=(name)
    self.cclass = Cclass.named(name)
  end

  def cclass_name
    cclass.name
  end

  field :hp, :type => Integer
  validates_presence_of :hp
  validates_numericality_of :hp, :greater_than => 0

  %w(fort reflex will).each do |save|
    field save, :type => Integer, :default => 0
    validates_presence_of save
    validates_numericality_of save, :greater_than_or_equal_to => 0
  end

  scope :cclass, lambda { |cclass| where(:cclass_id => cclass.id) }

  def level
    character.levels.index(self) + 1
  end

  def cclass_level
    character.levels.cclass(cclass).to_a.index(self) + 1
  end

  def cclass=(cclass)
    self[:cclass_id] = cclass.id
    clevel = cclass.clevel(cclass_level)
    %w(fort reflex will).each do |save|
      self.send("#{save}=", clevel.send(save))
    end
  end

end
