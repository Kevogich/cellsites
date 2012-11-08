class CreateMeasurementSubTypes < ActiveRecord::Migration
  def self.up
    create_table :measurement_sub_types do |t|
      
      t.string :name
      t.integer :measurement_id
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :measurement_sub_types
  end
end
