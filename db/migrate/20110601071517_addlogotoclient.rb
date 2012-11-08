class Addlogotoclient < ActiveRecord::Migration
  def self.up
    add_column :clients, :logo_file_name, :string
    add_column :clients, :logo_content_type, :string
    add_column :clients, :loga_file_size, :integer
  end

  def self.down
    remove_column :clients, :logo_file_name
    remove_column :clients, :logo_content_type
    remove_column :clients, :logo_file_size
  end
end
