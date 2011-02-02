describe 'Adjustment' do

  before do
    @adjustment = Adjustment.new
  end

  it "should have a character" do
    @adjustment.character = character = Factory(:character)
    @adjustment.character.should == character
  end

end
