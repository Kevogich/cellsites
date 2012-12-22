class CreateReliefDeviceSystemDescriptions < ActiveRecord::Migration
  def self.up
    create_table :relief_device_system_descriptions do |t|
      t.integer :relief_device_sizing_id
      t.integer :sequence_no
      t.string  :equipment_type
      t.string  :equipment_tag
      t.string  :section
      t.string  :description
      t.float   :design_pressure, :limit => 53
      t.float   :mawp, :limit => 53
      t.float   :inlet_pressure, :limit => 53
      t.float   :outlet_pressure, :limit => 53
      t.float   :equipment_dp, :limit => 53
      t.boolean   :prv_location
      t.float   :inlet_pressure_at_relief, :limit => 53
      t.timestamps
    end
  end

  def self.down
    drop_table :relief_device_system_descriptions
  end
end
