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

  it "should have saves" do
    %w(fortitude reflex will).each do |save|
      @level.send("#{save}=", 2)
      @level.send(save).should == 2
    end
  end

  describe "levels" do

    before do
      character = Factory(:character, :levels => [
        { :klass => 'rogue', :hp => 1, :fort => 0, :reflex => 0, :will => 0 },
        { :klass => 'rogue', :hp => 1, :fort => 0, :reflex => 0, :will => 0 },
        { :klass => 'fighter', :hp => 1, :fort => 0, :reflex => 0, :will => 0 }
      ])
      @level = character.levels.last
      @level.klass.should == 'fighter'
    end

    it "should know its level" do
      @level.level.should == 3
    end
  
    it "should know its class level" do
      @level.klass_level.should == 1
    end

  end

end
