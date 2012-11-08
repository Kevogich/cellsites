class AddDecimalPlacesToMeasureUnits < ActiveRecord::Migration
  def self.up
    add_column :measure_units, :decimal_places, :integer
    MeasureUnit.update_all(:decimal_places => 4)
  end

  def self.down
    remove_column :measure_units, :decimal_places
  end
end
