require 'spec_helper'

describe Library do

  before do
    @library = Library.new
  end

  it "should have races" do
    @library.races.build(:name => 'dwarf', :size => 'medium', :speed => 30)
    @library.races.build(:name => 'elf', :size => 'medium', :speed => 30)
    @library.races.map(&:name).should == %w(dwarf elf)
  end

  it "should have cclasses" do
    @library.cclasses.build(Factory.attributes_for(:cclass, :name => 'rogue'))
    @library.cclasses.build(Factory.attributes_for(:cclass, :name => 'fighter'))
    @library.cclasses.map(&:name).should == %w(rogue fighter)
  end

end
