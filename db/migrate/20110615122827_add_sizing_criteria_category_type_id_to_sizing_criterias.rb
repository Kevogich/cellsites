class AddSizingCriteriaCategoryTypeIdToSizingCriterias < ActiveRecord::Migration
  def self.up
    add_column :sizing_criterias, :sizing_criteria_category_type_id, :integer 
    add_column :project_sizing_criterias, :sizing_criteria_category_type_id, :integer    
  end

  def self.down
    remove_column :sizing_criterias, :sizing_criteria_category_type_id
    remove_column :project_sizing_criterias, :sizing_criteria_category_type_id
  end
end
