class CreateReliefDeviceLocations < ActiveRecord::Migration
  def self.up
    create_table :relief_device_locations do |t|
      t.integer :relief_device_sizing_id
      t.integer :sequence_no
      t.string  :location
      t.string  :limiting_fitting
      t.string  :size
      t.string  :contact_fluid_phase
      t.string  :acidic_conditions
      t.string  :high_temp_conditions
      t.string  :h2s_environment
      t.string  :acceptability
      t.boolean  :location_use

      t.timestamps
    end
  end

  def self.down
    drop_table :relief_device_locations
  end
end
