class Cclass
  include Mongoid::Document

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name
  index :name, :unique => true

  def self.named(name)
    where(:name => name).first
  end

  field :bab
  validates_presence_of :bab
  validates_inclusion_of :bab, :in => %w(full three_quarters half)

  [:fort, :reflex, :will].each do |save|
    field save
    validates_presence_of save
    validates_inclusion_of save, :in => %w(good bad)
  end

end
