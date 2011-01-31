require 'spec_helper'

describe Skill do

  skills = [:appraise,
   :balance,
   :bluff,
   :climb,
   :concentration,
   :craft,
   :decipher_script,
   :diplomacy,
   :disguise,
   :escape_artist,
   :forgery,
   :gather_information,
   :handle_animal,
   :heal,
   :hide,
   :intimidate,
   :jump,
   :knowledge]
  
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
