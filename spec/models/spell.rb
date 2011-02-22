describe 'Spell' do

  before do
    @spell = Factory(:spell)
  end

  it "should be valid" do
    @spell.should be_valid
  end

  it "should have effects" do
    @spell.effects.create(str: 4, bonus: 'enhancement')
    @spell.effects.map(&:str).should == [4]
  end

end
