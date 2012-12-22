class AddDetailsToItemTypesTransmitAndProposal < ActiveRecord::Migration
  def self.up
    add_column :item_types_transmit_and_proposals, :applicable_to, :string
    add_column :item_types_transmit_and_proposals, :form_standard, :string
    add_column :item_types_transmit_and_proposals, :selection_type, :string
  end

  def self.down
    remove_column :item_types_transmit_and_proposals, :selection_type
    remove_column :item_types_transmit_and_proposals, :form_standard
    remove_column :item_types_transmit_and_proposals, :applicable_to
  end
end
