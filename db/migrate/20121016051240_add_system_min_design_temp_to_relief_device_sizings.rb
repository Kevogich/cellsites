class AddSystemMinDesignTempToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :system_min_design_temp, :float, :limit => 53
    add_column :relief_device_sizings, :system_max_design_temp, :float, :limit => 53
    add_column :relief_device_sizings, :inlet_pipe_material, :integer
    add_column :relief_device_sizings, :inlet_pipe_roughness, :float, :limit => 53
    add_column :relief_device_sizings, :circuit_pipe_material, :integer
    add_column :relief_device_sizings, :circuit_pipe_roughness, :float, :limit => 53
  end

  def self.down
    remove_column :relief_device_sizings, :system_min_design_temp
    remove_column :relief_device_sizings, :system_max_design_temp
    remove_column :relief_device_sizings, :inlet_pipe_material
    remove_column :relief_device_sizings, :inlet_pipe_roughness
    remove_column :relief_device_sizings, :circuit_pipe_material
    remove_column :relief_device_sizings, :circuit_pipe_roughness
  end
end
