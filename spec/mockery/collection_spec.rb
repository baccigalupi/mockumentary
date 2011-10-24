require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary::Collection do
  describe '::Collection' do
    before do
      Mockumentary.generate(User)
      @collection = Mockumentary::Collection.new(Mockumentary::User)
    end

    it 'is enumerable' do
      @collection.should be_a(Enumerable)
    end

    it 'starts out empty' do
      @collection.should_not be_nil
      @collection.should be_empty
    end

    it 'mock a collection of new objects of a particular type' do
      @collection.mock(4).map(&:class).uniq.should == [Mockumentary::User]
      @collection.size.should == 4
      @collection.first.new_record?.should == true
      @collection.first.name.should be_a(String)
    end

    it 'mock! will do the same but mock the saving too' do
      @collection.mock!(2).map(&:new_record?).uniq.should == [false]
    end

    it '#build will mock an object into the collection' do
      @collection.build(:name => 'proto awesomeness')
      @collection.size.should == 1
      @collection.first.name.should == 'proto awesomeness'
      @collection.first.new_record?.should == true
    end

    it '#create will mock a saved object into the collection' do
      @collection.create(:name => 'awesome saviness')
      @collection.size.should == 1
      @collection.first.name.should == 'awesome saviness'
      @collection.first.new_record?.should == false
    end

    it '#create! will do the same as #create' do
      @collection.create!(:name => 'awesome saviness')
      @collection.size.should == 1
      @collection.first.name.should == 'awesome saviness'
      @collection.first.new_record?.should == false
    end

    it 'overrides the enum #delete to take in multiple records' do
      @collection.mock(4)
      first_two = @collection[0..1]
      @collection.delete(*(first_two))
      @collection.size.should == 2
      @collection.map(&:id).should_not include(first_two.map(&:id))
    end

    it '#delete_all, #destroy_all, #reset all clear the collection' do
      @collection.mock(2)
      @collection.size.should == 2
      @collection.delete_all
      @collection.size.should == 0

      @collection.mock(2)
      @collection.size.should == 2
      @collection.destroy_all
      @collection.size.should == 0


      @collection.mock(2)
      @collection.size.should == 2
      @collection.reset
      @collection.size.should == 0
    end

    it '#exist? compares by id (which doesn\'t make sense if you aren\'t using mock!)' do
      @collection.mock!(3)
      @collection.exist?(@collection.first).should be_true
      @collection.exist?(Mockumentary::User.mock!).should be_false
    end
  end  
end

describe Mockumentary::Mockery, 'collection mocking' do
  before do
    Mockumentary.generate(User)
    @user = Mockumentary::User.mock
  end

  it 'should default to empty collections' do
    user_tasks = @user.tasks
    user_tasks.should be_a(Mockumentary::Collection)
    user_tasks.should be_empty
  end
end