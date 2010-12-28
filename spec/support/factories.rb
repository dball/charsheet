FactoryGirl.define do
  factory :character do
    name 'Gerhard'
  end

  factory :equipment do
    character
    name 'Belt of Giant Strength'
    bonus_type 'enhancement'
    str_bonus 4
  end
end
