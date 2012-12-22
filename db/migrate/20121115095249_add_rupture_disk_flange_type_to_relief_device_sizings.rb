class AddRuptureDiskFlangeTypeToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :rupture_disk_flange_type, :string, :limit => 10
    add_column :relief_device_sizings, :open_vent_flange_type, :string, :limit => 10
    rename_column :relief_device_sizings, :flange_type, :pressure_relief_flange_type
  end

  def self.down
    remove_column :relief_device_sizings, :rupture_disk_flange_type
    remove_column :relief_device_sizings, :open_vent_flange_type
    rename_column :relief_device_sizings, :pressure_relief_flange_type, :flange_type
  end
end
