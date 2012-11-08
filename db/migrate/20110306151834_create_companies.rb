class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name
      t.string :license
      t.integer :admin_id
      t.string :contact_person
      t.string :phone
      t.string :email
      t.string :website
      t.integer :users_limit
      t.integer :clients_limit

      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
