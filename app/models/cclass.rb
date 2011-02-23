class Cclass
  include Mongoid::Document

  referenced_in :library, :inverse_of => :cclasses
  embeds_many :features

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name
  index :name, :unique => true

  def self.named(name)
    where(:name => name).first
  end

  field :bab
  validates_presence_of :bab
  validates_inclusion_of :bab, :in => %w(1 3/4 1/2)

  [:fort, :reflex, :will].each do |save|
    field save
    validates_presence_of save
    validates_inclusion_of save, :in => %w(good bad)
  end

  def clevel(clevel)
    args = []
    args += [:fort, :reflex, :will].map do |save|
      case send(save)
        when 'good' then clevel == 1 ? 2 : (clevel + 1) % 2
        when 'bad' then clevel % 3 == 0 ? 1 : 0
      end
    end
    args.push(case bab
      when '1' then 1
      when '3/4' then (clevel - 1) % 4 == 0 ? 0 : 1
      when '1/2' then (clevel % 2) == 1 ? 0 : 1
    end)
    Clevel.new(*args)
  end

  class Clevel

    attr_reader :fort, :reflex, :will, :bab

    def initialize(*args)
      @fort, @reflex, @will, @bab = args
    end

  end

end

#level(1) do
#  intrinsic :fast_movement, :effects => [{ :speed => 10 }]
#  buff :rage, :effects => [
#    { :str => 4, :con => 4, :ac => -2 },
#    { :will => 2, :type => 'morale' }
#  ]
#end
#level(11) do
#  buff :rage, :effects => [
#    { :str => 6, :con => 6, :ac => -2 },
#    { :will => 3, :type => 'morale' }
#  ]
#end
#level(20) do
#  buff :rage, :effects => [
#    { :str => 8, :con => 8, :ac => -2 },
#    { :will => 4, :type => 'morale' }
#  ]
#end

#level(1) do
#  buff :smite_evil, :effects => [
#    { :attack => :cha_bonus, :damage => :paladin_level }
#  ]
#end
#level(2) do
#  intrinsic :divine_grace, :effects => [
#    { :fort => :cha_bonus, :reflex => :cha_bonus, :will => :cha_bonus }
#  ]
#end

#level(1) do
#  intrinsic :sneak_attack, :value => '1d6'
#end
