class ModifyPressureToReliefDevice < ActiveRecord::Migration
  def self.up
    change_column :relief_devices, :orificearea, :float, :limit => 53
    change_column :relief_devices, :pressure, :float, :limit => 53
    change_column :relief_devices, :bplimit, :float, :limit => 53
    change_column :relief_device_locations, :size, :float, :limit => 53
    change_column :relief_device_rupture_disks, :bodysize, :float, :limit => 53
    change_column :relief_device_rupture_disks, :enfa, :float, :limit => 53
    change_column :relief_device_rupture_disks, :burstpressure, :float, :limit => 53
    change_column :relief_device_rupture_locations, :size, :float, :limit => 53
    change_column :relief_device_open_vent_relief_devices, :bodysize, :float, :limit => 53
    change_column :relief_device_open_vent_relief_devices, :netflowarea, :float, :limit => 53
    change_column :relief_device_open_vent_locations, :size, :float, :limit => 53
    change_column :relief_device_low_pressure_vent_relief_devices, :pressuresize, :float, :limit => 53
    change_column :relief_device_low_pressure_vent_relief_devices, :vacuumsize, :float, :limit => 53
    change_column :relief_device_low_pressure_vent_relief_devices, :setpressure, :float, :limit => 53
    change_column :relief_device_low_pressure_vent_relief_devices, :setvacumm, :float, :limit => 53
    change_column :relief_device_low_pressure_vent_relief_devices, :pressurecapacity, :float, :limit => 53
    change_column :relief_device_low_pressure_vent_relief_devices, :vacuumcapacity, :float, :limit => 53
    change_column :relief_device_sizings, :limiting_device_pressure, :float, :limit => 53
    change_column :relief_device_sizings, :system_design_temperature, :float, :limit => 53
    change_column :relief_device_sizings, :limiting_device_temperature, :float, :limit => 53
    change_column :relief_device_sizings, :system_min_design_temp, :float, :limit => 53
    change_column :relief_device_sizings, :system_max_design_temp, :float, :limit => 53
    change_column :relief_device_sizings, :low_pressure_set_pressure, :float, :limit => 53
    change_column :relief_device_sizings, :low_pressure_set_vacuum, :float, :limit => 53
    change_column :relief_device_sizings, :low_pressure_flashpoint_temp, :float, :limit => 53
    change_column :relief_device_sizings, :low_pressure_fluid_temp, :float, :limit => 53
    change_column :relief_device_sizings, :low_pressure_pressure_rating, :float, :limit => 53
    change_column :relief_device_sizings, :low_pressure_vacuum_rating, :float, :limit => 53
    change_column :relief_device_sizings, :low_pressure_tankcapacity, :float, :limit => 53
  end

  def self.down
    change_column :projects, :barometric_pressure, :string
    change_column :relief_devices, :orificearea, :string
    change_column :relief_devices, :pressure, :string
    change_column :relief_devices, :bplimit, :string
    change_column :relief_device_locations, :size, :string
    change_column :relief_device_rupture_disks, :bodysize, :string
    change_column :relief_device_rupture_disks, :enfa, :string
    change_column :relief_device_rupture_disks, :burstpressure, :string
    change_column :relief_device_rupture_locations, :size, :string
    change_column :relief_device_open_vent_relief_devices, :bodysize, :string
    change_column :relief_device_open_vent_relief_devices, :netflowarea, :string
    change_column :relief_device_open_vent_locations, :size, :string
    change_column :relief_device_low_pressure_vent_relief_devices, :pressuresize, :string
    change_column :relief_device_low_pressure_vent_relief_devices, :vacuumsize, :string
    change_column :relief_device_low_pressure_vent_relief_devices, :setpressure, :string
    change_column :relief_device_low_pressure_vent_relief_devices, :setvacumm, :string
    change_column :relief_device_low_pressure_vent_relief_devices, :pressurecapacity, :string
    change_column :relief_device_low_pressure_vent_relief_devices, :vacuumcapacity, :string
    change_column :relief_device_sizings, :limiting_device_pressure, :string
    change_column :relief_device_sizings, :system_design_temperature, :string
    change_column :relief_device_sizings, :limiting_device_temperature, :string
    change_column :relief_device_sizings, :system_min_design_temp, :string
    change_column :relief_device_sizings, :system_max_design_temp, :string
    change_column :relief_device_sizings, :low_pressure_set_pressure, :string
    change_column :relief_device_sizings, :low_pressure_set_vacuum, :string
    change_column :relief_device_sizings, :low_pressure_flashpoint_temp, :string
    change_column :relief_device_sizings, :low_pressure_fluid_temp, :string
    change_column :relief_device_sizings, :low_pressure_pressure_rating, :string
    change_column :relief_device_sizings, :low_pressure_vacuum_rating, :string
    change_column :relief_device_sizings, :low_pressure_tankcapacity, :string
  end
end
