class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.integer :company_id
      t.string :name
      t.string :client_type
      t.string :address
      t.string :email
      t.string :phone

      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end
