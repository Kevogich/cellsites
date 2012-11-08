class CreateCompanyUserUnitHabtms < ActiveRecord::Migration
  def self.up
    create_table :company_users_units, :id => false do |t|
      t.references :unit, :company_user
    end
  end

  def self.down
    drop_table :company_users_units
  end
end
