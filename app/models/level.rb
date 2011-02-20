class Level
  include Mongoid::Document

  embedded_in :character, :inverse_of => :levels
  referenced_in :cclass
  embeds_one :effect
  
  after_initialize :build_effect

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
      effect.send("#{save}=", clevel.send(save))
    end
  end

  def features
    cclass.features.select { |feature| feature.level == cclass_level }
  end

  def effects
    [effect] + features.map(&:effects).flatten
  end

  def type
  end

end
