class AddDriverColumnsToPumpSizing < ActiveRecord::Migration
  def self.up
  	add_column :pump_sizings, :primary_driver_type, :string
  	add_column :pump_sizings, :primary_driver_tag, :string
  	add_column :pump_sizings, :secondary_driver_type, :string
  	add_column :pump_sizings, :secondary_driver_tag, :string
  end

  def self.down
  	remove_column :pump_sizings, :primary_driver_type
  	remove_column :pump_sizings, :primary_driver_tag
  	remove_column :pump_sizings, :secondary_driver_type
  	remove_column :pump_sizings, :secondary_driver_tag
  end
end
