describe 'Race' do

  before do
    @race = Race.new
  end

  it "should have a name" do
    @race.name = 'human'
    @race.name.should == 'human'
  end

  it "should have a size" do
    @race.size = 'large'
    @race.size.should == 'large'
  end

  it "should have a speed" do
    @race.speed = 40
    @race.speed.should == 40
  end

  it "should have a character" do
    @race.character = character = Character.new
    @race.character.should == character
  end

end
