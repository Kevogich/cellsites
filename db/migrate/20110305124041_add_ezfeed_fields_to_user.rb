class AddEzfeedFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :group_id, :integer
    add_column :users, :title_id, :integer
    add_column :users, :official_title, :string
    add_column :users, :location, :string
    add_column :users, :address, :string
    add_column :users, :official_tel, :string
    add_column :users, :cell, :string
    add_column :users, :fax, :string
    add_column :users, :access_type_id, :integer
  end

  def self.down
    remove_column :users, :access_type_id
    remove_column :users, :fax
    remove_column :users, :cell
    remove_column :users, :official_tel
    remove_column :users, :address
    remove_column :users, :location
    remove_column :users, :official_title
    remove_column :users, :title_id
    remove_column :users, :group_id
  end
end
