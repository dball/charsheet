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
      character = Factory(:character)
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
      character = Factory(:character, :base_str => 18, :adjustment => { :effects => [{ :str => 12 }] })
      character.str.should == 30
    end

  end

  describe "hp" do

    it "should derive hp from con and levels" do
      character = Factory(:character, :base_con => 12)
      cclass = Factory(:cclass)
      [5, 7].each { |hp| character.levels.gain(cclass, hp) }
      character.hp.should == 14
    end

    it "should apply a minimum of 1 hp per level" do
      pending "implementing stupid con bonus minimum rule"
      character = Factory(:character, :base_con => 8)
      [1, 1, 1].each { |hp| character.levels.build(:hp => hp) }
      character.hp.should == 3
    end

    it "should derive hp from level feats" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 2, :feats => [Factory(:feat, :effects => [{ hp: 3 }])])
      character.hp.should == 5
    end
  
    it "should derive hp from racial feats" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 2)
      character.race.feats += [Factory(:feat, :effects => [{ hp: 3 }])]
      character.hp.should == 5
    end
  
  end
  
  describe "current_hp" do
    it "should change with damage and healing" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 12)
      character.current_hp.should == 12
      character.wound 4
      character.current_hp.should == 8
      character.heal 2
      character.current_hp.should == 10
    end
    
    it "should not heal above max hp" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 12)
      character.current_hp.should == 12
      character.heal 10
      character.current_hp.should == 12
    end
  end
  
  describe "wounds" do
    it "should be created on damage" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 8)
      character.wound 2
      character.wound 3
      character.wound 1
      character.wounds.length.should == 3
      character.current_hp.should == 2
    end
    
    it "should be removed with sufficient healing" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 8)
      character.wound 2
      character.wound 3
      character.wound 1
      character.heal 5
      character.wounds.length.should == 1
      character.current_hp.should == 7
      character.heal 7
      character.wounds.length.should == 0
    end
    
    it "should allow types of damage" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 8)
      character.wound 2, types: [:piercing, :slashing]
      character.wounds.last.damage_types.should == [:piercing, :slashing]
      character.wound 7, types: [:bludgeoning]
      character.wounds.last.damage_types.should == [:bludgeoning]
      character.wound 5
      character.wounds.last.damage_types.should == nil
    end
    
    it "should allow a source of damage" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 8)
      character.wound 5, types: [:bludgeoning], source: 'a big rock'
      character.wounds.last.source.should == 'a big rock'
      character.wound 2, source: 'Fizzwind the Wizard'
      character.wounds.last.source.should == 'Fizzwind the Wizard'
    end
  end
  
  describe "scars" do
    it "should be created when a wound is healed" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 12)
      character.wound 2
      character.heal 2
      character.scars.length.should == 1
      character.wound 3
      character.heal 4
      character.scars.length.should == 2
    end
    
    it "should store the attributes from the wound" do
      character = Factory(:character, :base_con => 10)
      cclass = Factory(:cclass)
      character.levels.gain(cclass, 12)
      character.wound 2, types: [:piercing], source: 'bumblebee'
      character.heal 2
      character.scars.length.should == 1
      character.scars.last.source.should == 'bumblebee'
      character.scars.last.damage_types.should == [:piercing]
      character.scars.last.damage.should == 2
    end
  end

  describe "levels" do

    before do
      @cclasses = %w(fighter rogue).map do |name|
        Factory(:cclass, :name => name)
      end
    end

    it "should have class levels" do
      character = Factory(:character)
      @cclasses.each do |cclass|
        character.levels.gain(cclass, 1)
      end
      character.levels.map(&:cclass).should == @cclasses
      character.level.should == 2
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

    it "should be able to compute formula bonuses to ac" do
      character = Factory(:character, :base_dex => 10, :base_wis => 14)
      character.equipment.create(:effects => [{ :ac => 'wis_bonus + 2' }])
      character.ac.should == 14
    end

    it "should be able to add class feature effects to ac" do
      character = Factory(:character, :base_dex => 10, :base_wis => 16)
      cclass = Factory(:cclass, :features => [{ :name => 'monk', :level => 1, :effects => [{ ac: 'wis_bonus' }] }])
      character.levels.build.tap { |level| level.cclass = cclass }
      character.ac.should == 13
    end

  end

  describe "saves" do

    it "should derive reflex from dexterity, levels, and effects" do
      character = Factory(:character, :base_dex => 18)
      cclass = Factory(:cclass)
      [2, 0, 1].each do |save|
        level = character.levels.build(:reflex => save)
        level.cclass = cclass
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

    it "should assign new speed from effects like alter self" do
      character = Factory(:character)
      character.race.speed = 30
      character.buffs.create(:effects => [{ :speed => 40, :operator => '=' }])
      character.speed.should == 40
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

  describe "bab" do
  
    before do
      @character = Factory(:character)
      cclass = Factory(:cclass, :bab => '1/2')
      3.times { @character.levels.gain(cclass, 1) }
    end

    it "should have a bab of 1" do
      @character.bab.should == 1
    end

    it "should allow bab to be reset by effects" do
      @character.buffs.create(:effects => [{ :bab => 'level', :operator => '=' }])
      @character.bab.should == 3
    end

    it "should allow bab bonus from soulbow and bab assignment from divine power to stack" do
      # http://www.wizards.com/default.asp?x=dnd/ex/20060403a&page=2
      pending "crazy bab corner case"
    end

    it "should allow bonus from skillful weapons to change bab progression" do
      # Complete Arcane; they set your BAB progression to 3/4
      pending "crazy bab corner case"
    end
 
  end

  describe "attacks" do

    before do
      @character = Factory(:character)
    end

    it "should always have an unarmed attack" do
      @character.attacks.map(&:name).should == %w(unarmed)
    end

    it "should have worn weapons as attacks" do
      @character.equipment << Weapon.new(:worn => true, :name => 'sword')
      @character.attacks.map(&:name).should == %w(sword unarmed)
    end

    describe "bonuses" do

      before do
        @character.base_str = 16
        cclass = Factory(:cclass, :bab => '1')
        2.times { @character.levels.gain(cclass, 1) }
      end

      it "attacks should use bab + str as the base bonus" do
        @character.attacks.map(&:bonus).should == [5]
      end

      it "attacks should add weapon effects to bonus" do
        @character.equipment << Weapon.parse('+1 dagger')
        @character.attacks.map(&:bonus).should == [6, 5]
      end

    end

  end

end
