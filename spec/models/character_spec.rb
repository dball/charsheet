require 'spec_helper'

describe Character do

  it "should have a name" do
    character = Character.new(:name => 'Gerhard')
    character.save.should be_true
    character.name.should == 'Gerhard'
  end

  it "should not allow duplicate names" do
    characters = (1..3).map { Character.new(:name => 'Gerhard') }
    characters.map { |character| character.save }.should == [true, false, false]
  end

  it "should have ability scores and modifiers" do
    character = Character.new(:name => 'Gerhard')
    scores = [18, 17, 16, 9, 8, 0]
    modifiers = [4, 3, 3, -1, -1, -5]
    Ability::ABILITIES.zip(scores, modifiers).each do |ability, score, modifier|
      character.send("base_#{ability}=", score)
      character.send(ability).should == score
      character.send("#{ability}_modifier").should == modifier
    end
  end

  it "should apply worn equipment bonuses to ability scores" do
    character = Factory.build(:character, :base_str => 18)
    character.equipment.build(:str_bonus => 4, :worn => true)
    character.str.should == 22
  end

  it "should not apply unworn equipment bonuses to ability scores" do
    character = Factory.build(:character, :base_str => 18)
    character.equipment.build(:str_bonus => 4, :worn => false)
    character.str.should == 18
  end

  it "should not stack equipment bonuses of the same type" do
    character = Factory.build(:character, :base_str => 18)
    character.equipment.build(
      :str_bonus => 2, :worn => true, :bonus_type => 'enhancement')
    character.equipment.build(
      :str_bonus => 4, :worn => true, :bonus_type => 'enhancement')
    character.equipment.build(
      :str_bonus => 7, :worn => true, :bonus_type => 'luck')
    character.str.should == 29
  end

end
