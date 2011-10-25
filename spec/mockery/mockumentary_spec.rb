require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary do
  describe '.generate' do
    before do
      Mockumentary.generate(User)
    end

    it 'creates a class in the Mockumentary namespace' do
      Mockumentary.send(:remove_const, :User) if defined?(Mockumentary::User)
      Mockumentary.generate(User)
      lambda { Mockumentary::User }.should_not raise_error
    end

    it 'created class is a Mockumentary::Mockery' do
      Mockumentary::User.ancestors.should include(Mockumentary::Mockery)
    end

    it "should not re-evaluate the class desclaration if the class already exists" do
      Mockumentary.should_not_receive(:class_eval)
      Mockumentary.generate(User)
    end

    it 'should introspect on the created class' do
      Mockumentary.send(:remove_const, :User) if defined?(Mockumentary::User)
      Mockumentary.generate(User)
      Mockumentary::User.mock_defaults.should == {:name => :string}
    end
  end

  describe '.instrospect' do
    before do
      Rails.stub(:root).and_return(FIXTURE_ROOT)
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

  describe '.dump' do
    before do
      Rails.stub(:root).and_return(FIXTURE_ROOT)
      Mockumentary.introspect
      @dir = "#{FIXTURE_ROOT}/config"
      @path = @dir + "/mockumentary.yml"
      File.delete(@path) if File.exist?(@path)

      class Mockumentary::User
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
