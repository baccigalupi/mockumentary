class Event < ActiveRecord::Base
  belongs_to :actor, :class_name => 'User', :foreign_key => :user_id
  has_many :event_resources
end
