describe 'Feat' do

  before do
    @feat = Factory(:feat)
  end

  it "should be valid" do
    @feat.should be_valid
  end

  it "should have effects" do
    @feat.effects.create(:hp => 3)
    @feat.effects.map(&:hp).should == [3]
  end

end
