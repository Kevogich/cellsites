class AddPressueReliefValveLocationToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :pressure_relief_valve_location, :string, :limit => 50
    add_column :relief_device_sizings, :rupture_disk_location, :string, :limit => 50
    add_column :relief_device_sizings, :open_vent_location, :string, :limit => 50
    remove_column :relief_device_locations, :location_use
    remove_column :relief_device_rupture_locations, :location_use
    remove_column :relief_device_open_vent_locations, :location_use
  end

  def self.down
    remove_column :relief_device_sizings, :pressure_relief_valve_location
    remove_column :relief_device_sizings, :rupture_disk_location
    remove_column :relief_device_sizings, :open_vent_location
    add_column :relief_device_locations, :location_use, :string
    add_column :relief_device_rupture_locations, :location_use, :string
    add_column :relief_device_open_vent_locations, :location_use, :string
  end
end
