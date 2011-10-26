require File.dirname(__FILE__) + '/spec_helper'

describe Mocksimile do
  describe '.generate' do
    before do
      Mocksimile.generate('User', {
         :init => {:state => 'new'},
         :mock => {:full_name => :full_name},
         :save => {:state => 'saved'}
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
  end
end
