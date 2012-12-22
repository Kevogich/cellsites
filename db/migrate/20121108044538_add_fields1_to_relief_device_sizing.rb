class AddFields1ToReliefDeviceSizing < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :sd_lowest_set_pressure, :float, :limit => 53
    add_column :relief_device_sizings, :sd_relief_pressure, :float, :limit => 53
    add_column :relief_device_sizings, :sd_recommended_set_pressure, :float, :limit => 53
    add_column :relief_device_sizings, :sd_limited_by, :string
  end

  def self.down
    remove_column :relief_device_sizings, :sd_lowest_pset
    remove_column :relief_device_sizings, :sd_relief_pressure
    remove_column :relief_device_sizings, :sd_recommended_set_pressure
    remove_column :relief_device_sizings, :sd_limited_by
  end
end
