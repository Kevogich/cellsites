class CreateSizingCriteriaCategories < ActiveRecord::Migration
  def self.up
    create_table :sizing_criteria_categories do |t|
      
      t.string :name
     
      t.integer :company_id
      
      t.integer :created_by
      t.integer :updated_by
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sizing_criteria_categories
  end
end
