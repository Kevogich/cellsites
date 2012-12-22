class AddDetailsToAttachment < ActiveRecord::Migration
  def self.up
    add_column :attachments, :item_tag_tab, :string
  end

  def self.down
    remove_column :attachments, :item_tag_tab
  end
end
