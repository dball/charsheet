describe Effect do

  before do
    @effect = Effect.new
  end

  it "should have a type" do
    @effect.type = 'morale'
    @effect.type.should == 'morale'
  end

  it "should have an operator" do
    @effect.operator = '+'
    @effect.operator.should == '+'
  end

  it "should have abilities" do
    Ability::ABILITIES.each do |ability|
      @effect.send("#{ability}=", 4)
      @effect.send(ability).should == 4
    end
  end

  it "should have ac bonus" do
    @effect.ac = 8
    @effect.ac.should == 8
  end

  it "should allow bonuses to be arbitrary expressions" do
    @effect.ac = 'cha + 4'
    @effect.ac.should == 'cha + 4'
    @effect.should be_valid
  end

  it "should not allow bonuses to be malicious code" do
    pending "sandboxing or parsing"
    @effect.ac = 'Model.delete_all'
    @effect.ac.should == 'Model.delete_all'
    @effect.should_not be_valid
  end

end
