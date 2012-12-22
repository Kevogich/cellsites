class AddDischargePressureToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :discharge_pressure, :decimal
  end

  def self.down
    remove_column :relief_device_sizings, :discharge_pressure
  end
end
