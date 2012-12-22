class AddLowPressureLeakPointReliefDeviceSizing < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :low_pressure_leak_point, :float, :limit => 53, :default => 0
  end

  def self.down
    remove_column :relief_device_sizings, :low_pressure_leak_point
  end
end
