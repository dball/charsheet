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
    character.str = 18
    character.str_modifier.should == 4
    character.dex = 17
    character.dex_modifier.should == 3
    character.con = 16
    character.con_modifier.should == 3
    character.int = 9
    character.int_modifier.should == -1
    character.wis = 8
    character.wis_modifier.should == -1
    character.cha = 0
    character.cha_modifier.should == -5
  end

end
