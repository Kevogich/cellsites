class ChangeConversionFactorMeasureunit < ActiveRecord::Migration
  def self.up
    change_column :measure_units, :conversion_factor, :float, :limit => 53
  end

  def self.down
    change_column :measure_units, :conversion_factor, :integer
  end
end
