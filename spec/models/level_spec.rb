describe 'Level' do

  before do
    @level = Character.new.levels.build
  end

  it "should have a klass" do
    @level.klass = 'fighter'
    @level.klass.should == 'fighter'
  end

  it "should have hp" do
    @level.hp = 8
    @level.hp.should == 8
  end

end
