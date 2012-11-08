class CreateReliefDeviceRuptureDisks < ActiveRecord::Migration
  def self.up
    create_table :relief_device_rupture_disks do |t|
      t.integer :relief_device_sizing_id
      t.integer :sequence_no
      t.string :rdtag
      t.string :bodysize
      t.string :enfa
      t.string :inletflange
      t.string :outletflange
      t.string :burstpressure
      t.string :kr
      t.string :uncertaintyf
      t.string :nonfdesign

      t.timestamps
    end
  end

  def self.down
    drop_table :relief_device_rupture_disks
  end
end
