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

  context "parsing" do

    it "should parse 'long sword'" do
      weapon = Weapon.parse("long sword")
      weapon.name.should == "long sword"
    end

    it "should parse 'masterwork mace'" do
      weapon = Weapon.parse("masterwork mace")
      weapon.name.should == "mace"
      weapon.should be_masterwork
    end

    it "should parse '+1 dagger'" do
      weapon = Weapon.parse("+1 dagger")
      weapon.name.should == "dagger"
      weapon.should be_masterwork
      weapon.effects.map do |effect|
        [effect.type, effect.attack, effect.damage]
      end.should == [['enhancement', 1, 1]]
    end

  end

end
