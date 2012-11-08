class AddSystemDesignTemperatureToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :system_design_temperature, :decimal
  end

  def self.down
    remove_column :relief_device_sizings, :system_design_temperature
  end
end
