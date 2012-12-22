class ProjectKbKpFields < ActiveRecord::Migration
  def self.up
    add_column :pressure_relief_system_design_parameters, :kb_at_over_pressure_between_api_values, :boolean
    add_column :pressure_relief_system_design_parameters, :kp_at_over_pressure_lower_than_10p, :boolean
  end

  def self.down
    remove_column :pressure_relief_system_design_parameters, :kb_at_over_pressure_between_api_values
    remove_column :pressure_relief_system_design_parameters, :kp_at_over_pressure_lower_than_10p
  end
end
