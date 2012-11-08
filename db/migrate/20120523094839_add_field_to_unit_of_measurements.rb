class AddFieldToUnitOfMeasurements < ActiveRecord::Migration
  def self.up
	  add_column :unit_of_measurements, :previous_measure_unit_id, :integer
  end

  def self.down
	  remove_column :unit_of_measurements, :previous_measure_unit_id
  end
end
