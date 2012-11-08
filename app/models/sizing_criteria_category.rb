class SizingCriteriaCategory < ActiveRecord::Base
  
  belongs_to :company
  has_many :sizing_criterias 
  has_many :sizing_criteria_category_types, :dependent => :destroy
  has_many :project_sizing_criterias
  has_many :line_sizings
  
  validates_presence_of :name, :company_id
end
