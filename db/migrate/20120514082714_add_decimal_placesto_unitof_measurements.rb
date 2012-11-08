class AddDecimalPlacestoUnitofMeasurements < ActiveRecord::Migration
  def self.up
    add_column :unit_of_measurements, :decimal_places, :integer
  end

  def self.down
    remove_column :unit_of_measurements, :decimal_places
  end
end
