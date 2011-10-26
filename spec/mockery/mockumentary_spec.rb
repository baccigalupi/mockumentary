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
end
