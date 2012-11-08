class AddFieldsToProject < ActiveRecord::Migration
  def self.up
     add_column :projects, :maximum_operating_pressure_allowance, :float, :limit => 53
     add_column :projects, :maximum_operating_temperature_allowance, :float, :limit => 53
     add_column :projects, :design_pressure_allowance, :float, :limit => 53
     add_column :projects, :design_temperature_allowance, :float, :limit => 53     
  end

  def self.down
    remove_column :projects, :maximum_operating_pressure_allowance
    remove_column :projects, :maximum_operating_temperature_allowance
    remove_column :projects, :design_pressure_allowance
    remove_column :projects, :design_temperature_allowance
  end
end
