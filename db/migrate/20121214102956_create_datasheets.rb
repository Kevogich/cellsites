class CreateDatasheets < ActiveRecord::Migration
  def self.up
    create_table :datasheets do |t|
      t.string :datasheet_name
      t.integer :item_type_id
      t.integer :company_id

      t.timestamps
    end
  end

  def self.down
    drop_table :datasheets
  end
end
