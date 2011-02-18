describe 'Feature' do

  before do
    @feature = Factory.build(:feature)
  end

  it "should be valid" do
    @feature.should be_valid
  end

end
