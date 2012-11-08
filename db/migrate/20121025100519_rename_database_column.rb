class RenameDatabaseColumn < ActiveRecord::Migration
  def self.up
    rename_column :relief_device_low_pressure_vent_relief_devices, :piping, :vacuumcapacity
  end

  def self.down
    rename_column :relief_device_low_pressure_vent_relief_devices, :vacuumcapacity, :piping
  end
end
