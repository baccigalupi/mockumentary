require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary::Mockery do
  before do
    @model = Mockumentary::Mockery.new
  end

  describe 'basic behavior' do
    it 'will respond to any method without raising an error' do
      @model.fooey_bar.should be_nil
    end

    it 'can be loaded with a hash of options' do
      model = Mockumentary::Mockery.new(:fooey_bar => 'zardoz')
      model.fooey_bar.should == 'zardoz'
    end

    it 'attributes can be set on individual items' do
      @model.fooey_bar = 'funktastic'
      @model.fooey_bar.should == 'funktastic'
    end
  end

  describe 'mocking' do
    before do
      Mockumentary.generate(Event)
      Mockumentary.generate(User)
    end

    describe '.ar_class' do
      it 'should be the AR class that it was constructed with' do
        Mockumentary::User.ar_class.should == User
      end

      it 'setting it will cause introspection to occur' do
        Mockumentary::User.ar_class = Event
        Mockumentary::User.mock_defaults.should == Mockumentary::Event.mock_defaults
      end

      it 'can be inferred when it is nil' do
        Mockumentary::User.ar_class = nil
        Mockumentary::User.ar_class.should == User
      end
    end

    describe '.new' do
      it 'should not add any real attributes' do
        user = Mockumentary::User.new
        user.name.should be_nil
        user.created_at.should be_nil
        user.updated_at.should be_nil
        user.id.should be_nil
      end

      it 'should be a new record' do
        user = Mockumentary::User.new
        user.new_record?.should be_true
      end

      it 'can receive options that it will set on the instance' do
        user = Mockumentary::User.new(:name => 'foo bar')
        user.name.should == 'foo bar'
      end
    end

    describe '.mock' do 
      before do
        Mockumentary::User.ar_class = User
      end

      it 'should add faked attributes' do
        user = Mockumentary::User.mock
        user.name.should be_a(String)
        user.name.split.size.should == 3
      end

      it 'should not add an id, or other save attributes' do
        user = Mockumentary::User.mock
        user.id.should be_nil
        user.created_at.should be_nil
        user.updated_at.should be_nil
      end

      it 'should be a new record' do
        user = Mockumentary::User.mock
        user.new_record?.should be_true
      end

      it 'should accept initialization options' do
        user = Mockumentary::User.mock(:foo => 'bar')
        user.foo.should == 'bar'
      end
    end

    describe '.mock!' do
      it 'should add faked attributes' do
        user = Mockumentary::User.mock!
        user.name.should be_a(String)
      end

      it 'should create an incrementing id' do
        user = Mockumentary::User.mock!
        user.id.should be_a(Fixnum)
        Mockumentary::User.mock!.id.should == user.id + 1
      end

      it 'should build updated_at and created_at attributes' do
        user = Mockumentary::User.mock!
        user.created_at.should be_a(Time)
        user.updated_at.should be_a(Time)
      end

      it 'should not be a new record' do
        user = Mockumentary::User.mock!
        user.new_record?.should be_false
      end

      it 'should allow overrides with initialization options' do
        user = Mockumentary::User.mock!(:name => 'footy barf')
        user.name.should == 'footy barf'
      end
    end
  end
end
