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

  describe "abilities" do
  
    it "should have ability scores, modifiers, and bonuses" do
      character = Character.new(:name => 'Gerhard')
      scores = [18, 17, 16, 9, 8, 0]
      modifiers = [4, 3, 3, -1, -1, -5]
      Ability::ABILITIES.zip(scores, modifiers).each do |ability, score, modifier|
        character.send("base_#{ability}=", score)
        character.send(ability).should == score
        character.send("#{ability}_modifier").should == modifier
        character.send("#{ability}_bonus").should == [modifier, 0].max
      end
    end

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

    it "should apply adjustment bonuses" do
      character = Character.new(:base_str => 18, :adjustment => { :effects => [{ :str => 12 }] })
      character.str.should == 30
    end

  end

  describe "hp" do

    it "should derive hp from con and levels" do
      character = Factory(:character, :base_con => 12)
      [5, 7].each { |hp| character.levels.build(:hp => hp) }
      character.hp.should == 14
    end

    it "should apply a minimum of 1 hp per level" do
      pending "implementing stupid con bonus minimum rule"
      character = Factory(:character, :base_con => 8)
      [1, 1, 1].each { |hp| character.levels.build(:hp => hp) }
      character.hp.should == 3
    end
  
  end

  describe "levels" do

    before do
      %w(fighter rogue).each do |name|
        Factory(:cclass, :name => name)
      end
    end

    it "should have class levels" do
      character = Factory(:character)
      %w(fighter fighter rogue).each do |name|
        character.levels.build(:cclass_name => name)
      end
    end

  end

  describe "ac" do

    it "should have ac" do
      character = Factory(:character, :base_dex => 10)
      character.ac.should == 10
    end
  
    it "should apply dex modifier to ac" do
      character = Factory(:character, :base_dex => 18)
      character.ac.should == 14
    end

    it "should apply armor effects to ac" do
      character = Factory(:character, :base_dex => 10)
      character.equipment.create(:slot => 'armor', :effects => [{ :ac => 8 }])
      character.ac.should == 18
    end
  
    it "should not stack armor effect bonuses of the same type" do
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

    it "should be able to apply an ability bonus to ac" do
      character = Factory(:character, :base_dex => 10, :base_wis => 14)
      character.equipment.create(:effects => [{ :ac => 'wis_bonus' }])
      character.ac.should == 12
    end

  end

  describe "saves" do

    it "should derive reflex from dexterity, levels, and effects" do
      character = Factory(:character, :base_dex => 18)
      [2, 0, 1].each do |save|
        character.levels.build(:reflex => save)
      end
      character.equipment.build(:effects => [{ :reflex => 4, :type => 'resistance' }])
      character.reflex_save.should == 11
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
