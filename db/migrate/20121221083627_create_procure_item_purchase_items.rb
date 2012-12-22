class CreateProcureItemPurchaseItems < ActiveRecord::Migration
  def self.up
    create_table :procure_item_purchase_items do |t|
      t.integer :procure_item_id
      t.string :item_no
      t.string :item_desc
      t.boolean :taxable
      t.integer :quantity
      t.integer :unit_price
      t.integer :total_price

      t.timestamps
    end
  end

  def self.down
    drop_table :procure_item_purchase_items
  end
end
