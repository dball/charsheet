describe 'Klass' do

  before do
    @klass = Class.new(Klass)
  end

  describe "saving throws" do

    it "should allow good saves" do
      @klass.fort(:good)
      [2, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1].each_with_index do |bonus, i|
        @klass.level(i + 1).fort.should == bonus
      end
    end

    it "should allow bad saves" do
      @klass.reflex(:bad)
      [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0].each_with_index do |bonus, i|
        @klass.level(i + 1).reflex.should == bonus
      end
    end

  end

end
