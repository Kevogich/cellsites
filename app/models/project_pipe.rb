class ProjectPipe < ActiveRecord::Base
  belongs_to :project
  belongs_to :pipe
end
