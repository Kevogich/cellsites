class AddLowPressureNoteToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :low_pressure_note, :text
    add_column :relief_device_sizings, :equipments_note, :text
  end

  def self.down
    remove_column :relief_device_sizings, :low_pressure_note
    remove_column :relief_device_sizings, :equipments_note
  end
end
