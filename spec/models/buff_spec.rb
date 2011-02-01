describe 'Buff' do

  before do
    @buff = Character.new.buffs.build
  end

  it "should have a name" do
    @buff.name = 'Shield'
    @buff.name.should == 'Shield'
  end

  it "should have a character" do
    @buff.character = character = Factory(:character)
    @buff.character.should == character
  end

  it "should have an active flag" do
    @buff.active = true
    @buff.active.should be_true
    @buff.should be_active
  end

  it "should have effects" do
    @buff.effects.build(:ac => 4, :type => 'shield')
    @buff.effects.map { |eff| [eff.ac, eff.type] }.should == [[4, 'shield']]
  end

  it "should have an active scope" do
    character = Factory(:character)
    buffs = [true, false].map do |active|
      character.buffs.build(:active => active)
    end
    character.buffs.active.should == [buffs.first]
  end

end
