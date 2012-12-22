class CreateProjectVendorLists < ActiveRecord::Migration
  def self.up
    create_table :project_vendor_lists do |t|
      t.integer :vendor_list_id
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :project_vendor_lists
  end
end
