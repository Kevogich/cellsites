class AddDischargeLocationToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :discharge_location, :string, :limit => 50
    add_column :relief_device_sizings, :flange_type, :string, :limit => 20
  end

  def self.down
    remove_column :relief_device_sizings, :discharge_location
    remove_column :relief_device_sizings, :flange_type
  end
end