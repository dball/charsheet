FactoryGirl.define do
  factory :character do
    name 'Gerhard'
    base_str 10
    base_dex 10
    base_con 10
    base_int 10
    base_wis 10
    base_cha 10
    race({ :name => 'dwarf', :size => 'medium', :speed => 20 })
  end

  factory :equipment do
    character
    name 'belt of giant strength'
    slot 'belt'
  end

  factory :weapon do
    character
    name 'long sword'
    slot 'grip'
  end

  factory :buff do
    character
    name 'Shield'
  end

  factory :adjustment do
    character
  end

  factory :cclass do
    library
    name 'rogue'
    bab 'three_quarters'
    fort 'bad'
    reflex 'good'
    will 'bad'
  end

  factory :feature do
    cclass
    level 2
    name 'divine grace'
  end

  factory :library do
  end

  factory :feat do
    library
    name 'toughness'
  end

  factory :spell do
    library
    name "bull's strength"
  end

end
