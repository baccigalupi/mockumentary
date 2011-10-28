require File.dirname(__FILE__) + '/spec_helper'

class ActiveRecord::Base
  extend Mockumentary::ActiveRecord
end

describe Mockumentary::ActiveRecord do
  describe '.discover_mock_class' do
    it 'is called by mock_class if no mock class is set' do
      User.should_receive(:discover_mock_class!)
      User.mock_class
    end

    it 'calls Mockumentary.generate if there are no matching mock classes' do
      Mockery.should_receive(:generate).with(User)
      Mockery.stub(:classes).and_return([])
      User.instance_eval("@mock_class = nil")
      User.mock_class
    end

    it 'finds the Mockery related to itself' do
      User.mock_class.should == Mockery::User
    end
  end

  describe 'mock methods' do
    it '#mock calls #mock on the related AR class' do
      mock_user = User.mock(:foo => 'bar')
      mock_user.id.should be_nil
      mock_user.new_record.should == true
      mock_user.foo.should == 'bar'
      mock_user.name.should be_a(String)
    end

    it '#mock! calls #mock! on the related AR class' do
      mock_user = User.mock!(:bar => 'baz')
      mock_user.id.should be_a(Fixnum)
      mock_user.bar.should == 'baz'
      mock_user.new_record.should be_false
      mock_user.name.should be_a(String)
    end

    it '#mew calls #new on the related AR class' do
      mock_user = User.mew(:baz => 'zardoz')
      mock_user.baz.should == 'zardoz'
      mock_user.new_record.should be_true
      mock_user.name.should be_nil
    end
  end
end

