require File.dirname(__FILE__) + '/spec_helper'

describe Mockumentary do
  before do
    RAILS_ROOT = FIXTURE_ROOT unless defined?(RAILS_ROOT)
  end

  describe '.load' do
    it 'should raise an error if it cannot find the config file' do
      Object.send(:remove_const, :RAILS_ROOT) if defined?(RAILS_ROOT)
      lambda { Mockumentary.load }.should raise_error(
        ArgumentError, "Could not find mockumentary.yml. Please include a path or define RAILS_ROOT"
      )
    end

    it 'should create Mocksimiles for each of the classes, when it finds the file' do
      Mockumentary.load
      defined?(Mocksimile::User).should be_true
      defined?(Mocksimile::Task).should be_true
      defined?(Mocksimile::Event).should be_true
      defined?(Mocksimile::EventResource).should be_true
      defined?(Mocksimile::Event::Follow).should be_true
    end
  end

  describe '.load_and_release' do
    it 'calls load on itself' do
      Mockumentary.should_receive(:load)
      Mockumentary.load_and_release
    end

    it 'calls release on Mocksimile' do
      Mockumentary.stub(:load)
      Mocksimile.should_receive(:release)
      Mockumentary.load_and_release
    end
  end
end 
