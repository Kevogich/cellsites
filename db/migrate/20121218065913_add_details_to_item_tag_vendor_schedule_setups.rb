class AddDetailsToItemTagVendorScheduleSetups < ActiveRecord::Migration
  def self.up
    add_column :item_tag_vendor_schedule_setups, :date, :string
  end

  def self.down
    remove_column :item_tag_vendor_schedule_setups, :date
  end
end
