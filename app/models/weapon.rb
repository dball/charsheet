class Weapon < Equipment

  field :light, :type => Boolean, :default => false
  field :critical_threshold, :type => Integer, :default => 20
  field :critical_multiplier, :type => Integer, :default => 2

end
