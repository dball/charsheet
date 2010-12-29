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

  it "should have armor class" do
    character = Factory(:character, :base_dex => 10)
    character.armor_class.should == 10
  end

  it "should apply dex modifier to armor class" do
    character = Factory(:character, :base_dex => 18)
    character.armor_class.should == 14
  end

  it "should apply worn armor to armor class" do
    character = Factory(:character, :base_dex => 10)
    character.equipment.create(:ac_bonus => 8, :worn => true, :name => 'foo')
    character.armor_class.should == 18
  end

  it "should not stack armor bonuses of the same type" do
    character = Factory(:character, :base_dex => 10)
    character.equipment.create(
      :ac_bonus => 4, :worn => true, :bonus_type => 'armor', :name => 'foo')
    character.equipment.create(
      :ac_bonus => 8, :worn => true, :bonus_type => 'armor', :name => 'bar')
    character.equipment.create(
      :ac_bonus => 1, :worn => true, :bonus_type => 'luck', :name => 'baz')
    character.armor_class.should == 19
  end

  it "should apply worn equipment bonuses to ability scores" do
    character = Factory(:character, :base_str => 18)
    character.equipment.create(:str_bonus => 4, :worn => true, :name => 'foo')
    character.str.should == 22
  end

  it "should not apply unworn equipment bonuses to ability scores" do
    character = Factory(:character, :base_str => 18)
    character.equipment.create(:str_bonus => 4, :worn => false, :name => 'foo')
    character.str.should == 18
  end

  it "should not stack equipment bonuses of the same type" do
    character = Factory(:character, :base_str => 18)
    character.equipment.create(
      :str_bonus => 2, :worn => true, :bonus_type => 'morale', :name => 'foo')
    character.equipment.create(
      :str_bonus => 4, :worn => true, :bonus_type => 'morale', :name => 'bar')
    character.equipment.create(
      :str_bonus => 7, :worn => true, :bonus_type => 'luck', :name => 'baz')
    character.str.should == 29
  end

  it "should stack untyped equipment bonuses" do
    character = Factory(:character, :base_str => 18)
    character.equipment.create(
      :str_bonus => 2, :worn => true, :bonus_type => 'morale', :name => 'foo')
    character.equipment.create(:str_bonus => 3, :worn => true, :name => 'bar')
    character.equipment.create(:str_bonus => 5, :worn => true, :name => 'baz')
    character.str.should == 28
  end

  describe "skills" do

    it "should accept ranks in all of the core skills" do
      character = Factory(:character)
      Skill.all.keys.each do |skill|
        character.send("#{skill}_ranks=", 4)
        character.send("#{skill}_ranks").should == 4
      end
    end

    it "should compute skill modifiers from abilities and ranks" do
      character = Factory(:character, :base_cha => 16, :bluff_ranks => 5)
      character.bluff_modifier.should == 8
    end

    it "should add skill synergies to skill modifiers" do
      character = Factory(:character, :base_cha => 16,
        :bluff_ranks => 5, :diplomacy_ranks => 1)
      character.diplomacy_modifier.should == 6
    end

    it "should add conditional skill synergies to skill modifiers" do
      character = Factory(:character, :base_cha => 16,
        :bluff_ranks => 5, :disguise_ranks => 1)
      character.disguise_modifier.should == 4
      pending
      character.disguise_modifier.conditions.should ==
        { 'to act in character' => '+2' }
      character.diplomacy_modifiers.conditions.should == {}
    end

  end

end
