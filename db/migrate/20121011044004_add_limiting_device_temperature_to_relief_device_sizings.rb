class AddLimitingDeviceTemperatureToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :limiting_device_temperature, :string
    rename_column :relief_device_sizings, :limiting_device, :limiting_device_pressure
  end

  def self.down
    remove_column :relief_device_sizings, :limiting_device_temperature
  end
end
