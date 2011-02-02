require 'spec_helper'

describe Character do

  it "should have a name" do
    character = Character.new(:name => 'Gerhard')
    character.name.should == 'Gerhard'
  end

  it "should not allow duplicate names" do
    characters = (1..3).map { Factory.build(:character, :name => 'Gerhard').tap { |char| char.save } }
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

  it "should have ac" do
    character = Factory(:character, :base_dex => 10)
    character.ac.should == 10
  end

  it "should apply dex modifier to ac" do
    character = Factory(:character, :base_dex => 18)
    character.ac.should == 14
  end

  describe "armor effects" do

    it "should apply worn armor to ac" do
      character = Factory(:character, :base_dex => 10)
      character.equipment.create(:slot => 'armor', :effects => [{ :ac => 8 }])
      character.ac.should == 18
    end
  
    it "should not stack armor bonuses of the same type" do
      character = Factory(:character, :base_dex => 10)
      character.equipment.create(:effects => [{ :ac => 4, :type => 'armor' }])
      character.equipment.create(:effects => [{ :ac => 8, :type => 'armor' }])
      character.equipment.create(:effects => [{ :ac => 1, :type => 'luck' }])
      character.ac.should == 19
    end

    it "should stack dodge bonuses" do
      character = Factory(:character, :base_dex => 14)
      character.buffs.create(:effects => [{ :ac => 4, :type => 'dodge' }])
      character.buffs.create(:effects => [{ :ac => 6, :type => 'dodge' }])
      character.buffs.create(:effects => [{ :ac => 1, :type => 'luck' }])
      character.ac.should == 23
    end

  end

  describe "ability effects" do
  
    it "should apply worn equipment bonuses to ability scores" do
      character = Factory(:character, :base_str => 18)
      character.equipment.create(:worn => true, :name => 'foo', :effects => [{ :str => 4 }])
      character.str.should == 22
    end
  
    it "should not stack equipment bonuses of the same type" do
      character = Factory(:character, :base_str => 18)
      character.equipment.create(:effects => [{ :str => 2, :type => 'morale' }])
      character.equipment.create(:effects => [{ :str => 4, :type => 'morale' }])
      character.equipment.create(:effects => [{ :str => 7, :type => 'luck' }])
    end
  
    it "should stack untyped equipment bonuses" do
      character = Factory(:character, :base_str => 18)
      character.equipment.create(:effects => [{ :str => 2, :type => 'morale' }])
      character.equipment.create(:effects => [{ :str => 3 }])
      character.equipment.create(:effects => [{ :str => 5 }])
      character.str.should == 28
    end

  end

  describe "size" do

    it "should derive its size from its race" do
      character = Character.new(:race => { :size => 'large' })
      character.size.should == 'large'
    end

    it "should add effects to its size" do
      pending
    end

  end

  describe "speed" do

    it "should derive its speed from its race" do
      character = Character.new(:race => { :speed => 45 })
      character.speed.should == 45
    end

    it "should add effects to its speed" do
      character = Factory(:character)
      character.race.speed = 30
      character.buffs.create(:effects => [{ :speed => 10, :type => 'morale'}])
      character.buffs.create(:effects => [{ :speed => 5, :type => 'morale'}])
      character.buffs.create(:effects => [{ :speed => 25 }])
      character.equipment.create(:effects => [{ :speed => 5, :type => 'enhancement' }])
      character.speed.should == 70
    end

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
      pending "fixing skills"
      character = Factory(:character, :base_cha => 16,
        :bluff_ranks => 5, :diplomacy_ranks => 1)
      character.diplomacy_modifier.should == 6
    end

    it "should add conditional skill synergies to skill modifiers" do
      pending "fixing skills"
      character = Factory(:character, :base_cha => 16,
        :bluff_ranks => 5, :disguise_ranks => 1)
      character.disguise_modifier.should == 4
      character.disguise_modifier.conditions.should ==
        { 'to act in character' => '+2' }
      character.diplomacy_modifiers.conditions.should == {}
    end

  end

end
