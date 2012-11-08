class CreateMeasureUnits < ActiveRecord::Migration
  def self.up
    create_table :measure_units do |t|
      
      t.string :unit_name
      t.string :unit
      t.string :measurement_id      
      
      t.integer :company_id
      t.integer :user_id
      
      t.integer :created_by
      t.integer :updated_by
            

      t.timestamps
    end
  end

  def self.down
    drop_table :measure_units
  end
end
