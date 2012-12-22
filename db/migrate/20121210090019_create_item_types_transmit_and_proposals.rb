class CreateItemTypesTransmitAndProposals < ActiveRecord::Migration
  def self.up
    create_table :item_types_transmit_and_proposals do |t|
      t.string :item_tag
      t.string :req
      t.string :select_vendor
      t.integer :price
      t.string :by
      t.string :reviewer
      t.string :approver
      t.integer :item_type_id
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      t.timestamps
    end
  end

  def self.down
    drop_table :item_types_transmit_and_proposals
  end
end
