class UserProjectSetting < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  
  validates_presence_of :client_id, :project_id, :process_unit_id
end
