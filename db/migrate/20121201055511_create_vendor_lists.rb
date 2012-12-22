class CreateVendorLists < ActiveRecord::Migration
  def self.up
    create_table :vendor_lists do |t|
      t.string :vendor_name
      t.string :item_type
      t.string :status
      t.string :rating
      t.string :representative
      t.string :address
      t.string :city
      t.string :country
      t.integer :office_phone
      t.integer :cell_phone
      t.integer :fax
      t.string :email
      t.integer :company_id
      t.timestamps
    end
  end

  def self.down
    drop_table :vendor_lists
  end
end
