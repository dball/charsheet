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

  attr_reader :ability

  def initialize(ability, &block)
    @ability = ability
    @block = block
  end

  def synergies(*args)
    {}
  end

  def trained?
    true
  end

  register(:appraise, :int)
  register(:balance, :dex) #acp
  register(:bluff, :cha) do
    synergies :diplomacy, :intimidate, :sleight_of_hand,
      :disguise => 'to act in character'
  end
  register(:climb, :str) #acp
  register(:concentration, :con)
  register(:craft, :int) do
    subskills :alchemy, :armorsmithing, :bowmaking, :weaponsmithing, :trapmaking
    synergies :appraise => 'related to items made with that craft skill'
  end
  register(:decipher_script, :int) do
    trained_only
    synergies :use_magic_device => 'involving scrolls'
  end
  register(:diplomacy, :cha)
  register(:disguise, :cha)
  register(:escape_artist, :dex) do #acp
    synergies :use_rope => 'to bind someone'
  end
  register(:forgery, :int)
  register(:gather_information, :cha)
  register(:handle_animal, :cha) do
    trained_only
    synergies :ride #wild empathy
  end
  register(:heal, :wis)
  register(:hide, :dex) #acp #size
  register(:intimidate, :cha)
  register(:jump, :str) do #acp
    synergies :tumble
  end
  register(:knowledge, :int) do
    trained_only
    subskill(:arcana) { synergies :spellcraft }
    subskill :architecture_and_engineering do
      synergies :search => 'to find secret doors or hidden compartments'
    end
    subskill :geography do
      synergies :survival => 'to keep from getting lost or to avoid natural hazards'
    end
    subskill :history #bardic knowledge
    subskill :local do
      synergies :gather_information
    end
    subskill :nature do
      synergies :survival => 'made in aboveground natural environments'
    end
    subskill :nobility_and_royalty do
      synergies :diplomacy
    end
    subskill :religion #turn undead
    subskill :planes do
      synergies :survival => 'made while on other planes'
    end
    subskill 'dungeoneering' do
      synergies :survival => 'made while underground'
    end
  end

end
