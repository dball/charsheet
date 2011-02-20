describe 'Level' do

  before do
    @level = Character.new.levels.build
  end

  it "should have a cclass" do
    @level.cclass = cclass = Factory(:cclass)
    @level.cclass.should == cclass
  end

  it "should have an effect" do
    @level.effect.hp = 8
    @level.effect.hp.should == 8
  end

  it "should copy saves from cclass" do
    @level.cclass = Factory(:cclass)
    @level.effect.fort.should == 0
    @level.effect.reflex.should == 2
    @level.effect.will.should == 0
  end

  describe "levels" do

    before do
      library = Factory(:library)
      cclasses = %w(rogue fighter).map do |name|
        Factory(:cclass, :name => name, :library => library)
      end
      character = Factory(:character)
      character.levels.gain(cclasses.first, 1)
      character.levels.gain(cclasses.first, 1)
      @level = character.levels.gain(cclasses.last, 1)
    end

    it "should know its level" do
      @level.level.should == 3
    end
  
    it "should know its cclass level" do
      @level.cclass_level.should == 1
    end

  end

end
