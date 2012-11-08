class CreateReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    create_table :relief_device_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
	  t.string  :relief_device_type
	  t.string 	:system_description
	  t.string 	:system_hmb_basis
	  t.string 	:limiting_device
	  t.float 	:system_design_pressure, :limit => 53
	  t.integer :created_by
	  t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :relief_device_sizings
  end
end
