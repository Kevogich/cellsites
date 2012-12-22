class ProjectItemType < ActiveRecord::Base
  belongs_to :project
  belongs_to :item_type
end
