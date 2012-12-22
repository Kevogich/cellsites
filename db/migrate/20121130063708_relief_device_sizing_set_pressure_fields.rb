class ReliefDeviceSizingSetPressureFields < ActiveRecord::Migration
  def self.up
    change_table :relief_device_sizings do |t|
      t.float :prv_system_design_pressure, :limit => 53
      t.float :rd_system_design_pressure, :limit => 53
      t.float :ov_system_design_pressure, :limit => 53
    end
  end

  def self.down
    remove_column :relief_device_sizings, :prv_system_design_pressure
    remove_column :relief_device_sizings, :rd_system_design_pressure
    remove_column :relief_device_sizings, :ov_system_design_pressure
  end
end
