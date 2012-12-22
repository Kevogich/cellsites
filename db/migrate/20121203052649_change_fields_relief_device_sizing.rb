class ChangeFieldsReliefDeviceSizing < ActiveRecord::Migration
  def self.up
    change_column :relief_device_sizings, :limiting_device_pressure, :string
    change_column :relief_device_sizings, :limiting_device_temperature, :string
  end

  def self.down
    change_column :relief_device_sizings, :limiting_device_pressure, :float
    change_column :relief_device_sizings, :limiting_device_temperature, :float
  end
end
