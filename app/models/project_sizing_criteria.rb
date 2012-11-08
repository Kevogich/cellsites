class ProjectSizingCriteria < ActiveRecord::Base
  belongs_to :project
  belongs_to :sizing_criteria_category
  belongs_to :sizing_criteria
end
