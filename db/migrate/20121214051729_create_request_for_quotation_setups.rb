class CreateRequestForQuotationSetups < ActiveRecord::Migration
  def self.up
    create_table :request_for_quotation_setups do |t|
      t.integer :project_id
      t.integer :procure_rfq_section_id
      t.integer :item_type_id
      t.boolean :status
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :request_for_quotation_setups
  end
end
