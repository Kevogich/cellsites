class CreateSizingCriterias < ActiveRecord::Migration
  def self.up
    create_table :sizing_criterias do |t|
      
      t.integer :sizing_criteria_category_id
      
      t.string :name
      t.string :code
      
      t.integer :velocity_min
      t.integer :velocity_max
      t.integer :velocity_sel
      
      t.integer :delta_per_100ft_min
      t.integer :delta_per_100ft_max
      t.integer :delta_per_100ft_sel
      
      t.string :user_notes
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :sizing_criterias
  end
end
