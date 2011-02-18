describe 'Cclass' do

  before do
    @cclass = Factory(:cclass)
  end

  describe "saving throws" do

    it "should have good saves" do
      @cclass.fort = 'good'
      [2, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1].each_with_index do |bonus, i|
        @cclass.clevel(i + 1).fort.should == bonus
      end
    end

    it "should have bad saves" do
      @cclass.reflex = 'bad'
      [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0].each_with_index do |bonus, i|
        @cclass.clevel(i + 1).reflex.should == bonus
      end
    end

  end

  describe "bab" do
    
    it "should have full bab" do
      @cclass.bab = 'full'
      ([1] * 20).each_with_index do |bab, i|
        @cclass.clevel(i + 1).bab.should == bab
      end
    end

    it "should have 3/4 bab" do
      @cclass.bab = 'three_quarters'
      ([0, 1, 1, 1] * 5).each_with_index do |bab, i|
        @cclass.clevel(i + 1).bab.should == bab
      end
    end

    it "should have 1/2 bab" do
      @cclass.bab = 'one_half'
      ([0, 1] * 10).each_with_index do |bab, i|
        @cclass.clevel(i + 1).bab.should == bab
      end
    end

  end

  describe "features" do

    it "should have features keyed by level" do
      @cclass.features.create( level: 1, name: 'sneakiness', effects: [{ reflex: '2' }])
      @cclass.features.map(&:name).should == %w(sneakiness)
    end

  end

end
