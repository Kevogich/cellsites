class AddRupturePipeMaterialToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :rupture_pipe_material, :integer
    add_column :relief_device_sizings, :rupture_pipe_roughness, :float, :limit => 53
    add_column :relief_device_sizings, :open_vent_pipe_material, :integer
    add_column :relief_device_sizings, :open_vent_pipe_roughness, :float, :limit => 53
    add_column :relief_device_sizings, :low_pressure_vent_pipe_material, :integer
    add_column :relief_device_sizings, :low_pressure_vent_pipe_roughness, :float, :limit => 53
  end

  def self.down
    remove_column :relief_device_sizings, :rupture_pipe_material
    remove_column :relief_device_sizings, :rupture_pipe_roughness
    remove_column :relief_device_sizings, :open_vent_pipe_material
    remove_column :relief_device_sizings, :open_vent_pipe_roughness
    remove_column :relief_device_sizings, :low_pressure_vent_pipe_material
    remove_column :relief_device_sizings, :low_pressure_vent_pipe_roughness
  end
end
