class AddUnitTypeToMeasureUnits < ActiveRecord::Migration
  def self.up
    add_column :measure_units, :unit_type_id, :integer
    MeasureUnit.update_all(:unit_type_id => 2)
  end

  def self.down
    remove_column :measure_units, :unit_type_id
  end
end
