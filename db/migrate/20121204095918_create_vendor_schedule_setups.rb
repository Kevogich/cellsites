class CreateVendorScheduleSetups < ActiveRecord::Migration
  def self.up
    create_table :vendor_schedule_setups do |t|
      t.integer :vendor_required_data
      t.string :quotation
      t.string :purchase
      t.string :as_built
      t.string :with_shipment
      t.integer :item_type_id
      t.integer :project_id
      t.timestamps

  end

  def self.down
    drop_table :vendor_schedule_setups
  end
  end
  end
