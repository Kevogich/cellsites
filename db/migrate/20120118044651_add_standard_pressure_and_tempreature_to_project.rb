class AddStandardPressureAndTempreatureToProject < ActiveRecord::Migration
  def self.up
	  add_column :projects, :standard_pressure, :float, :limit => 53
	  add_column :projects, :standard_temperature, :float, :limit => 53
  end

  def self.down
	  remove_column :projects, :standard_pressure
	  remove_column :projects, :standard_temperature
  end
end
