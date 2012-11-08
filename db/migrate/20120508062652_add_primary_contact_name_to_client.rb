class AddPrimaryContactNameToClient < ActiveRecord::Migration
  def self.up
	  add_column :clients, :primary_contact_name, :string
  end

  def self.down
	  remove_column :clients, :primary_contact_name
  end
end
