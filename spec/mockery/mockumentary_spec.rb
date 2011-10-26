require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary do
  describe '.introspect' do
    before do
      Rails.stub(:root).and_return(FIXTURE_ROOT)

      @classes = []
      Mockery.stub(:generate) do |args|
        @classes << args
      end
    end
    
    it 'calls Mockery.generate for each of the first level active record objects found' do
      Mockumentary.introspect
      @classes.should include User, Event, EventResource, Task
    end

    it 'calls Mockery.generate on nested models' do
      Mockumentary.introspect
      @classes.should include Event::Follow
    end
  end

  describe '.dump' do
    before do
      Rails.stub(:root).and_return(FIXTURE_ROOT)
      Mockumentary.introspect
      @dir = "#{FIXTURE_ROOT}/config"
      @path = @dir + "/mockumentary.yml"
      File.delete(@path) if File.exist?(@path)

      class Mockery::User
        def self.overrides
          {
            :init => {:state => 'new'},
            :mock => {:full_name => :full_name},
            :save => {:state => 'saved'}
          }
        end
      end

      Mockumentary.dump
      @hash = YAML.load(File.read(@path))
    end

    it 'will create a new file to the Rails.root config path' do
      File.exist?(@path).should be_true
    end

    it 'will have an entry for each class' do
      @hash.keys.should include 'User', 'Event', 'EventResource', 'Task', 'Event::Follow'
    end

    it 'each class will have an init hash that combines that classes overrides with init_defaults' do
      @hash['User'][:init].should == {
        :state => 'new',
        :new_record => true
      }
    end

    it 'each class will have a mock hash that combines overrieds with defaults' do
      @hash['User'][:mock].should == {
        :name => :string,
        :full_name => :full_name
      }
    end

    it 'each class will have a save hash that combines overrides with defaults' do
      save_hash = @hash['User'][:save]
      save_hash[:state].should == 'saved'
      save_hash[:created_at].should == :datetime
      save_hash[:updated_at].should == :datetime
      save_hash[:new_record].should == false
      save_hash[:id].should == :uid
    end
  end
end
