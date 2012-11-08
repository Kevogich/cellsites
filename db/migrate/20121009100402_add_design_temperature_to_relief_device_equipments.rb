class AddDesignTemperatureToReliefDeviceEquipments < ActiveRecord::Migration
  def self.up
    add_column :relief_device_equipments, :design_temperature, :decimal
  end

  def self.down
    remove_column :relief_device_equipments, :design_temperature
  end
end
