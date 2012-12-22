class CreateItemTagVendorScheduleSetups < ActiveRecord::Migration
  def self.up
    create_table :item_tag_vendor_schedule_setups do |t|
      t.integer :vendor_required_data
      t.string :quotation
      t.string :purchase
      t.string :as_built
      t.string :with_shipment
      t.integer :item_type_id
      t.integer :project_id
      t.integer :vendor_schedule_setup_id
      t.timestamps
    end
  end

  def self.down
    drop_table :item_tag_vendor_schedule_setups
  end
end
