describe Equipment do

  it "should have a name" do
    equipment = Equipment.new(:name => 'Belt of Battle')
  end

  it "should have a character" do
    equipment = Equipment.new(:character => Character.new(:name => 'Gerhard'))
  end

end
