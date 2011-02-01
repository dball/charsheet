FactoryGirl.define do
  factory :character do
    name 'Gerhard'
    base_str 10
    base_dex 10
    base_con 10
    base_int 10
    base_wis 10
    base_cha 10
  end

  factory :equipment do
    character
    name 'Belt of Giant Strength'
    slot 'belt'
  end
end
