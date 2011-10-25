class User < ActiveRecord::Base
  has_many :tasks
  has_many :activities, :class_name => 'Event'
  has_many :activity_references, 
    :class_name => 'EventResource', 
    :foreign_key => :resource_id, 
    :conditions => ['resource_type = ?', 'User']
  has_many :events, :through => :activity_references, :source => :event
end