class CreateProcureItems < ActiveRecord::Migration
  def self.up
    create_table :procure_items do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      t.integer :item_type_id
      t.string :item_tag
      t.string :po_number
      t.string :vendor
      t.integer :total_price
      t.string :created_by
      t.date :transmitted_on
      t.string :applicable_to
      t.string :form_standard
      t.string :selection_type
      t.string :billing_name
      t.text :billing_address
      t.string :shipping_name
      t.text :shipping_address
      t.string :purchase_order_no
      t.date :purchase_order_issue_date
      t.date :shipment_delivery_date
      t.date :purchase_order_issue_date1
      t.string :currency
      t.string :form_of_payment
      t.string :purchasing_agent
      t.string :number_of_pieces
      t.string :gross_shipment_weight
      t.string :modes_of_transportation
      t.integer :subtotal
      t.integer :state_sales_tax
      t.integer :federal_sales_tax
      t.integer :shipping_handing
      t.integer :insurance
      t.integer :value_added_tax
      t.integer :tariff
      t.integer :clearing_cost
      t.integer :total
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :procure_items
  end
end
