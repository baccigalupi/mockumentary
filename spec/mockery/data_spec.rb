require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary::Data do
  it 'nested classes should generate data' do
    Mockumentary::Data::Datetime.generate.should be_a(Time)
    Mockumentary::Data::FullName.generate.should be_a(String)
    Mockumentary::Data::FullName.generate.split.size.should == 2
  end

  it 'should generate from the correct class given a key' do
    name = Mockumentary::Data.generate(:full_name)
    name.should be_a(String)
    name.split.size.should == 2
  end
end 
