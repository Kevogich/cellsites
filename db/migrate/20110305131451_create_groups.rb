class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.references :company
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
