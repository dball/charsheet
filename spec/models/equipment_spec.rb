describe Equipment do

  before do
    @equipment = Equipment.new
  end

  it "should have a name" do
    @equipment.name = 'Belt of Battle'
    @equipment.name.should == 'Belt of Battle'
  end

  it "should have a character" do
    @equipment.character = character = Factory(:character)
    @equipment.character.should == character
  end

  it "should have a slot" do
    @equipment.slot = 'neck'
    @equipment.slot.should == 'neck'
  end

  it "should have a worn flag" do
    @equipment.worn = true
    @equipment.worn.should be_true
    @equipment.should be_worn
  end

  it "should have a bonus type" do
    @equipment.bonus_type = 'morale'
    @equipment.bonus_type.should == 'morale'
  end

  it "should have ability bonuses" do
    Ability::ABILITIES.each do |ability|
      @equipment.send("#{ability}_bonus=", 4)
      @equipment.send("#{ability}_bonus").should == 4
    end
  end

  it "should have a worn scope" do
    character = Factory(:character)
    equipment = [true, false].map do |worn|
      Factory(:equipment, :worn => worn, :character => character)
    end
    Equipment.worn.all.should == [equipment.first]
  end

end
