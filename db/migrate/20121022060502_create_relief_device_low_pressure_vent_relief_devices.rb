class CreateReliefDeviceLowPressureVentReliefDevices < ActiveRecord::Migration
  def self.up
    create_table :relief_device_low_pressure_vent_relief_devices do |t|
      t.integer :relief_device_sizing_id
      t.integer :sequence_no
      t.string :venttag
      t.string :protectiontype
      t.string :venttype
      t.string :pressuresize
      t.string :vacuumsize
      t.string :setpressure
      t.string :setvacumm
      t.string :pressurecapacity
      t.string :piping

      t.timestamps
    end
  end

  def self.down
    drop_table :relief_device_low_pressure_vent_relief_devices
  end
end
