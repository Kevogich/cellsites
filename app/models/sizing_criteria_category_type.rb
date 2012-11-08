class SizingCriteriaCategoryType < ActiveRecord::Base
  belongs_to :sizing_criteria_category
  has_many :sizing_criterias,  :dependent => :destroy
  has_many :project_sizing_criterias, :dependent => :destroy
  has_many :line_sizings
  
  validates_presence_of :name, :sizing_criteria_category_id
end
