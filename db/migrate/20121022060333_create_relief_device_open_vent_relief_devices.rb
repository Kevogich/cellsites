class CreateReliefDeviceOpenVentReliefDevices < ActiveRecord::Migration
  def self.up
    create_table :relief_device_open_vent_relief_devices do |t|
      t.integer :relief_device_sizing_id
      t.integer :sequence_no
      t.string :optag
      t.string :bodysize
      t.string :pipesch
      t.string :netflowarea
      t.string :inletflange
      t.string :outletflange

      t.timestamps
    end
  end

  def self.down
    drop_table :relief_device_open_vent_relief_devices
  end
end
