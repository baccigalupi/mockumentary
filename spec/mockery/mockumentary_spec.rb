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
end
