describe 'Level' do

  before do
    @level = Character.new.levels.build
  end

  it "should have a cclass" do
    @level.cclass = cclass = Factory(:cclass)
    @level.cclass.should == cclass
  end

  it "should have a cclass_name accessor" do
    cclass = Factory(:cclass, :name => 'fighter')
    @level.cclass_name = 'fighter'
    @level.cclass.should == cclass
    @level.cclass_name.should == 'fighter'
  end

  it "should have hp" do
    @level.hp = 8
    @level.hp.should == 8
  end

  it "should have saves" do
    %w(fort reflex will).each do |save|
      @level.send("#{save}=", 2)
      @level.send(save).should == 2
    end
  end

  it "should copy saves from cclass" do
    @level.cclass = Factory(:cclass)
    @level.fort.should == 0
    @level.reflex.should == 2
    @level.will.should == 0
  end

  describe "levels" do

    before do
      %w(rogue fighter).each do |name|
        Factory(:cclass, :name => name)
      end
      character = Factory(:character)
      character.levels.create(:cclass_name => 'rogue', :hp => 1)
      character.levels.create(:cclass_name => 'rogue', :hp => 1)
      @level = character.levels.create(:cclass_name => 'fighter', :hp => 1)
    end

    it "should know its level" do
      @level.level.should == 3
    end
  
    it "should know its cclass level" do
      @level.cclass_level.should == 1
    end

  end

end
