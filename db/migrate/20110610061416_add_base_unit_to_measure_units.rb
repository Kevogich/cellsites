class AddBaseUnitToMeasureUnits < ActiveRecord::Migration
  def self.up
    add_column :measure_units, :base_unit, :string
  end

  def self.down
    remove_column :measure_units, :base_unit
  end
end
