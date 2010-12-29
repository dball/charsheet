require 'spec_helper'

describe Skill do

  skills = [:bluff, :diplomacy, :disguise]
  
  it "should have the core skills" do
    skills.each do |name|
      skill = Skill.send(name)
      skill.should_not be_nil
      skill.ability.should_not be_nil
      skill.trained?.should_not be_nil
    end
  end

  it "should have only the core skills" do
    Skill.all.keys.should == skills
  end

end
