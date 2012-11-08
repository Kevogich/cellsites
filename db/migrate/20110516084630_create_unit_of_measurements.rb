class CreateUnitOfMeasurements < ActiveRecord::Migration
  def self.up
    create_table :unit_of_measurements do |t|
      
      t.integer :company_id
      t.integer :project_id
      t.integer :measurement_id
      t.integer :measurement_sub_type_id
      t.integer :measure_unit_id
      
      t.string :measure_type
      
      t.integer :created_by
      t.integer :updated_by      

      t.timestamps
    end
  end

  def self.down
    drop_table :unit_of_measurements
  end
end
