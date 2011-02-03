describe 'Klass' do

  before do
    @klass = Class.new(Klass)
  end

  describe "saving throws" do

    it "should have good saves" do
      @klass.fort(:good)
      [2, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1].each_with_index do |bonus, i|
        @klass.level(i + 1).fort.should == bonus
      end
    end

    it "should have bad saves" do
      @klass.reflex(:bad)
      [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0].each_with_index do |bonus, i|
        @klass.level(i + 1).reflex.should == bonus
      end
    end

  end

  describe "bab" do
    
    it "should have full bab" do
      @klass.bab(:full)
      ([1] * 20).each_with_index do |bab, i|
        @klass.level(i + 1).bab.should == bab
      end
    end

    it "should have 3/4 bab" do
      @klass.bab(:three_quarters)
      ([0, 1, 1, 1] * 5).each_with_index do |bab, i|
        @klass.level(i + 1).bab.should == bab
      end
    end

    it "should have 1/2 bab" do
      @klass.bab(:one_half)
      ([0, 1] * 10).each_with_index do |bab, i|
        @klass.level(i + 1).bab.should == bab
      end
    end

  end

end
