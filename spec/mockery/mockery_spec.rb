require File.dirname(__FILE__) + '/spec_helper'

describe Mockery do
  describe 'basic behavior' do
    before do
      @model = Mockery.new
    end

    it 'will respond to any method without raising an error' do
      @model.fooey_bar.should be_nil
    end

    it 'can be loaded with a hash of options' do
      model = Mockery.new(:fooey_bar => 'zardoz')
      model.fooey_bar.should == 'zardoz'
    end

    it 'attributes can be set on individual items' do
      @model.fooey_bar = 'funktastic'
      @model.fooey_bar.should == 'funktastic'
    end
  end

  describe '.generate' do
    before do
      Mockery.generate(User)
    end

    it 'creates a class in the Mockumentary namespace' do
      Mockery.send(:remove_const, :User) if defined?(Mockery::User)
      Mockery.generate(User)
      lambda { Mockery::User }.should_not raise_error
    end

    it 'created class is a Mockumentary::Mockery' do
      Mockery::User.ancestors.should include(Mockery)
    end

    it "should not re-evaluate the class desclaration if the class already exists" do
      Mockumentary.should_not_receive(:class_eval)
      Mockery.generate(User)
    end

    it 'should introspect on the created class' do
      Mockery.send(:remove_const, :User) if defined?(Mockery::User)
      Mockery.generate(User)
      Mockery::User.mock_defaults.should == {:name => :string}
    end
  end



  describe 'mocking' do
    before do
      Mockery.generate(Event)
      Mockery.generate(User)
    end

    describe '.ar_class' do
      it 'should be the AR class that it was constructed with' do
        Mockery::User.ar_class.should == User
      end

      it 'setting it will cause introspection to occur' do
        Mockery::User.ar_class = Event
        Mockery::User.mock_defaults.should == Mockery::Event.mock_defaults
      end

      it 'can be inferred when it is nil' do
        Mockery::User.ar_class = nil
        Mockery::User.ar_class.should == User
      end
    end

    describe '.new' do
      it 'should not add any real attributes' do
        user = Mockery::User.new
        user.name.should be_nil
        user.created_at.should be_nil
        user.updated_at.should be_nil
        user.id.should be_nil
      end

      it 'should be a new record' do
        user = Mockery::User.new
        user.new_record?.should be_true
      end

      it 'can receive options that it will set on the instance' do
        user = Mockery::User.new(:name => 'foo bar')
        user.name.should == 'foo bar'
      end
    end

    describe '.mock' do 
      before do
        Mockery::User.ar_class = User
      end

      it 'should add faked attributes' do
        user = Mockery::User.mock
        user.name.should be_a(String)
        user.name.split.size.should == 3
      end

      it 'should not add an id, or other save attributes' do
        user = Mockery::User.mock
        user.id.should be_nil
        user.created_at.should be_nil
        user.updated_at.should be_nil
      end

      it 'should be a new record' do
        user = Mockery::User.mock
        user.new_record?.should be_true
      end

      it 'should accept initialization options' do
        user = Mockery::User.mock(:foo => 'bar')
        user.foo.should == 'bar'
      end
    end

    describe '.mock!' do
      it 'should add faked attributes' do
        user = Mockery::User.mock!
        user.name.should be_a(String)
      end

      it 'should create an incrementing id' do
        user = Mockery::User.mock!
        user.id.should be_a(Fixnum)
        Mockery::User.mock!.id.should == user.id + 1
      end

      it 'should build updated_at and created_at attributes' do
        user = Mockery::User.mock!
        user.created_at.should be_a(Time)
        user.updated_at.should be_a(Time)
      end

      it 'should not be a new record' do
        user = Mockery::User.mock!
        user.new_record?.should be_false
      end

      it 'should allow overrides with initialization options' do
        user = Mockery::User.mock!(:name => 'footy barf')
        user.name.should == 'footy barf'
      end
    end
  end

  describe 'overriding defaults' do
    before do
      Mockery.generate(User)
    end

    describe 'with mock options' do
      before do
        class Mockery::User
          def self.overrides
            { :mock => 
              { 
                :name => :full_name,
                :foo => 'not bar'
              } 
            }
          end
        end
      
        @user = Mockery::User.mock(:foo => 'bar') 
      end

      it 'should use the overrides instead of the defaults' do
        @user.name.split.size.should == 2 
      end
      
      it 'should not override initializaiton options' do
        @user.foo.should == 'bar' 
      end
    end

    describe 'with init options' do
      before do
        class Mockery::User
          def self.overrides
            { :init => 
              { 
                :state => 'new',
                :new_record => 'yup'
              } 
            }
          end
        end
      
        @user = Mockery::User.new(:state => 'jaded') 
      end

      it 'should use the overrieds instead of the defaults' do
        @user.new_record.should == 'yup'
      end

      it 'should options passed into new over those on the class' do
        @user.state.should == 'jaded'
      end
    end

    describe 'save options' do 
      before do
        class Mockery::User
          def self.overrides
            { :save => 
              { 
                :state => 'saved',
                :created_at => Time.now + 3.years
              } 
            }
          end
        end
      
        @user = Mockery::User.mock!(:state => 'jaded') 
      end

      it 'should use the overrides instead of the defaults' do
        @user.created_at.should > Time.now + 61.days
      end

      it 'should options passed into new over those on the class' do
        @user.state.should == 'jaded'
      end
    end
  end
end
