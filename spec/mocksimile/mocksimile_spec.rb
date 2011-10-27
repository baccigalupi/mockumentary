require File.dirname(__FILE__) + '/spec_helper'

describe Mocksimile do
  describe '.generate' do
    before do
      Mocksimile.generate('User', {
         :init => {:state => 'new'},
         :mock => {:full_name => :full_name},
         :save => {:state => 'saved'},
         :relationships => {
            :tasks => 'Task',
            :activities => 'Event',
            :activity_references => 'EventResource',
            :events => 'Event'
        }
      })
    end

    it 'should make a nested class' do
      defined?(Mocksimile::User).should == 'constant'
    end

    it 'should set the default init options' do
      Mocksimile::User.init_defaults.should == {
        :state => 'new'
      }
    end

    it 'should set the default mock options'  do
      Mocksimile::User.mock_defaults.should == {
        :full_name => :full_name
      }
    end

    it 'should set the default save options'  do
      Mocksimile::User.save_defaults.should == {
        :state => 'saved'
      }
    end

    it 'should set the relationships with appropriate lambdas' do
      Mocksimile::User.relationships.keys.should == [:tasks, :activities, :activity_references, :events]
      Mocksimile::User.relationships.values.map(&:class).uniq.should == [Proc]
      Mocksimile::User.relationships[:tasks].call.type.should == Mocksimile::Task
    end
  end

  describe 'usage' do
    before :all do
      RAILS_ROOT = FIXTURE_ROOT unless defined?(RAILS_ROOT)
      Mocksimile.load 
    end

    it 'should use the initialization default attributes' do
      user = Mocksimile::User.new
      user.new_record.should == true
      user.state.should == 'new'
    end

    it 'should use the mock default attributes' do
      user = Mocksimile::User.mock
      user.new_record.should == true
      user.state.should == 'new'
      user.name.should be_a(String)
      user.full_name.should be_a(String)
      user.full_name.split.size.should == 2
    end

    it 'should use the save default attributes' do
      user = Mocksimile::User.mock!
      user.new_record.should == false
      user.state.should == 'saved'
      user.name.should be_a(String)
      user.full_name.should be_a(String)
      user.created_at.should be_a(Time)
      user.updated_at.should be_a(Time)
      user.id.should be_a(Integer)
    end

    it 'relationships work' do
      user = Mocksimile::User.mock!
      user.events.mock!
      user.events.size.should == 1
      user.events.first.is_a?(Mocksimile::Event)
    end
  end
end
