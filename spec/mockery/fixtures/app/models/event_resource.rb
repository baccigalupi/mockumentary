class EventResource < ActiveRecord::Base
  belongs_to :event
  belongs_to :user_resource, :class_name => 'User', :foreign_key => :resource_id
  belongs_to :task_resource, :class_name => 'Task', :foreign_key => :resource_id

  def user
    user_resource if resource_type == 'User'
  end

  def task
    task_resource if resource_type == 'Task'
  end

  def resource=(r)
    if r.is_a?(User)
      self.user_resource = r 
    else
      self.task_resource = r
    end
    self.resource_type = r.class.to_s
    r
  end

  def resource
    user || task
  end
end