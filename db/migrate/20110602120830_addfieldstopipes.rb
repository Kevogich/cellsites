class Addfieldstopipes < ActiveRecord::Migration
  def self.up
    add_column :pipes, :company_id, :integer
    add_column :pipes, :created_by, :integer
    add_column :pipes, :updated_by, :integer   
  end

  def self.down
    remove_column :pipes, :company_id
    remove_column :pipes, :created_by
    remove_column :pipes, :updated_by
  end
end
