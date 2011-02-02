class Klass
  def self.hd(die)
  end

  def self.skills(skills)
  end

  def self.skill_points(skill_points)
  end

  def self.bab(bab)
  end

  def self.fort(fort)
  end

  def self.reflex(reflex)
  end

  def self.will(will)
  end

  def self.level(number)
  end
end

class Barbarian < Klass
  hd 12
  skills %w(climb craft handle_animal intimidate jump listen ride survival swim)
  skill_points 4
  bab :full
  fort :good
  reflex :bad
  will :bad
  
  level(1) do
    intrinsic :fast_movement, :effects => [{ :speed => 10 }]
    buff :rage, :effects => [
      { :str => 4, :con => 4, :ac => -2 },
      { :will => 2, :type => 'morale' }
    ]
  end
  level(11) do
    buff :rage, :effects => [
      { :str => 6, :con => 6, :ac => -2 },
      { :will => 3, :type => 'morale' }
    ]
  end
  level(20) do
    buff :rage, :effects => [
      { :str => 8, :con => 8, :ac => -2 },
      { :will => 4, :type => 'morale' }
    ]
  end
end

class Paladin < Klass
  hd 10
  skills %w(concentration craft diplomacy handle_animal heal) # FIXME continue
  bab :full
  fort :good
  reflex :bad
  will :bad

  level(1) do
    buff :smite_evil, :effects => [
      { :attack => :cha_bonus, :damage => :paladin_level }
    ]
  end
  level(2) do
    intrinsic :divine_grace, :effects => [
      { :fortitude => :cha_bonus, :reflex => :cha_bonus, :will => :cha_bonus }
    ]
  end
end

class Rogue < Klass
  hd 6
  skills %w(many)
  bab :three_quarters
  fort :bad
  reflex :good
  will :bad

  level(1) do
    intrinsic :sneak_attack, :value => '1d6'
  end
end
