describe Weapon do

  before do
    @weapon = Factory(:weapon)
  end

  it "should be valid" do
    @weapon.should be_valid
  end

  it "should have no effects" do
    @weapon.all_effects.should be_empty
  end

  it "should apply masterwork bonus to attack" do
    @weapon.masterwork = true
    @weapon.all_effects.map(&:attack).should == [1]
  end

end
