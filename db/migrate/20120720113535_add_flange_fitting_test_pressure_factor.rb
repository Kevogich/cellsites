class AddFlangeFittingTestPressureFactor < ActiveRecord::Migration
  def self.up
  	add_column :projects, :flange_fitting_test_pressure_factor, :float, :limit => 53
  	add_column :projects, :default_flow_element_pressure_drop, :float, :limit => 53
  end

  def self.down
  	remove_column :projects, :flange_fitting_test_pressure_factor
  	remove_column :projects, :default_flow_element_pressure_drop
  end
end
