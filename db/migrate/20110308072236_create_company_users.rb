class CreateCompanyUsers < ActiveRecord::Migration
  def self.up
    create_table :company_users do |t|
      t.references :company, :user, :group, :title
      t.string :official_title
      t.string :location
      t.string :address
      t.string :official_tel
      t.string :cell
      t.string :fax
      t.integer :access_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :company_users
  end
end
