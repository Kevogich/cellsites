class AddDetailsToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :item_tag_tab, :string
  end

  def self.down
    remove_column :comments, :item_tag_tab
  end
end
