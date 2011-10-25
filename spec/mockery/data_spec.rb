require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary::Data do
  it 'should generate data via methods' do
    Mockumentary::Data.datetime.should be_a(Time)
    Mockumentary::Data.full_name.should be_a(String)
    Mockumentary::Data.full_name.split.size.should == 2
  end

  it 'should generate from the correct class given a key' do
    name = Mockumentary::Data.generate(:full_name)
    name.should be_a(String)
    name.split.size.should == 2
  end
end 
