class CreateSizingCriteriaCategoryTypes < ActiveRecord::Migration
  def self.up
    create_table :sizing_criteria_category_types do |t|
      
      t.integer :sizing_criteria_category_id
      
      t.string :name
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :sizing_criteria_category_types
  end
end
