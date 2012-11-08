class CreateUnitUserHabtms < ActiveRecord::Migration
  def self.up
    create_table :units_users, :id => false do |t|
      t.references :unit, :user
    end
  end

  def self.down
    drop_table :units_users
  end
end
