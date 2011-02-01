describe Equipment do

  before do
    @equipment = Character.new.equipment.build
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

  it "should have effects" do
    @equipment.effects.create(:ac => 8, :operator => '+')
    @equipment.effects.map { |eq| [eq.ac, eq.operator] }.should == [[8, '+']]
  end

  it "should have a worn scope" do
    character = Factory(:character)
    equipment = [true, false].map do |worn|
      Factory(:equipment, :worn => worn, :character => character)
    end
    character.equipment.worn.all.should == [equipment.first]
  end

  it "should have an armor scope" do
    character = Factory(:character)
    equipment = [false, true].map do |armor|
      Factory(:equipment, :slot => armor ? 'armor' : 'neck', :character => character)
    end
    character.equipment.armor.all.should == [equipment.last]
  end

end
