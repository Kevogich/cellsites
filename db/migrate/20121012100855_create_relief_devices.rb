class CreateReliefDevices < ActiveRecord::Migration
  def self.up
    create_table :relief_devices do |t|
      t.integer :relief_device_sizing_id
      t.integer :sequence_no
      t.string :psvtag
      t.string :designation
      t.string :orificearea
      t.string :pressure
      t.string :psvtype
      t.string :subtype
      t.string :bodysize
      t.string :inletflange
      t.string :outletflange
      t.string :bodymatl
      t.string :springmatl
      t.string :bplimit

      t.timestamps
    end
  end

  def self.down
    drop_table :relief_devices
  end
end
