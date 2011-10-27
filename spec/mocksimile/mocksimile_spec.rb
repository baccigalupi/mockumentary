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
end
