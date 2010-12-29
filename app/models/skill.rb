class Skill

  def self.all
    @skills ||= {}
  end

  def self.register(name, *args)
    skill = self.new(*args)
    all[name] = skill
    (class << self; self end).instance_eval do
      define_method(name) { skill }
    end
    skill
  end

  attr_reader :ability, :trained
  alias :trained? :trained

  def initialize(ability, trained, *synergies)
    @ability = ability
    @trained = trained
    @synergies = synergies
  end

  register(:bluff, :cha, false, :diplomacy, :disguise => 'to act in character')
  register(:diplomacy, :cha, false)
  register(:disguise, :cha, false)

end
