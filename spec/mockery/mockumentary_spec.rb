require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary do
  describe '.generate' do
    before do
      Mockumentary.generate(User)
    end

    it 'creates a class in the Mockumentary namespace' do
      Mockumentary.send(:remove_const, :User) if defined?(Mockumentary::User)
      Mockumentary.generate(User)
      defined?(Mockumentary::User).should be_true
    end

    it 'created class is a Mockumentary::Mockery' do
      Mockumentary::User.ancestors.should include(Mockumentary::Mockery)
    end

    it 'creates a reference to the mocked class' do
      Mockumentary::User::CLASS.should == User
    end

    it "should not re-evaluate the class desclaration if the class already exists" do
      Mockumentary.should_not_receive(:class_eval)
      Mockumentary.generate(User)
    end

    it 'should call .mockify on the created class' do
      Mockumentary::User.should_receive(:mockify)
      Mockumentary.generate(User)
    end
  end

  describe '.instrospect' do
    before do
      Rails.stub(:root).and_return(File.dirname(__FILE__) + "/fixtures")
      Mockumentary.send(:remove_const, :User) if defined?(Mockumentary::User)
      Mockumentary.send(:remove_const, :Event) if defined?(Mockumentary::Event)
      Mockumentary.send(:remove_const, :EventResource) if defined?(Mockumentary::EventResource)
      Mockumentary.send(:remove_const, :Task) if defined?(Mockumentary::Task)
      Mockumentary::Event.send(:remove_const, :Follow) if defined?(Mockumentary::Event::Follow)
    end

    it 'generates for all first level models' do
      Mockumentary.introspect
      defined?(Mockumentary::User).should == 'constant'
      defined?(Mockumentary::Event).should == 'constant'
      defined?(Mockumentary::EventResource).should == 'constant'
      defined?(Mockumentary::Task).should == 'constant'
    end

    it 'generates recursively for deeper models' do
      Mockumentary.introspect
      defined?(Mockumentary::Event::Follow).should == 'constant'
    end
  end
end
