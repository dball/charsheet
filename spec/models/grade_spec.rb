describe 'Grade' do

  before do
    @grade = Class.new(Grade)
  end

  describe "saving throws" do

    it "should have good saves" do
      @grade.fort(:good)
      [2, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1].each_with_index do |bonus, i|
        @grade.level(i + 1).fort.should == bonus
      end
    end

    it "should have bad saves" do
      @grade.reflex(:bad)
      [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0].each_with_index do |bonus, i|
        @grade.level(i + 1).reflex.should == bonus
      end
    end

  end

  describe "bab" do
    
    it "should have full bab" do
      @grade.bab(:full)
      ([1] * 20).each_with_index do |bab, i|
        @grade.level(i + 1).bab.should == bab
      end
    end

    it "should have 3/4 bab" do
      @grade.bab(:three_quarters)
      ([0, 1, 1, 1] * 5).each_with_index do |bab, i|
        @grade.level(i + 1).bab.should == bab
      end
    end

    it "should have 1/2 bab" do
      @grade.bab(:one_half)
      ([0, 1] * 10).each_with_index do |bab, i|
        @grade.level(i + 1).bab.should == bab
      end
    end

  end

end
