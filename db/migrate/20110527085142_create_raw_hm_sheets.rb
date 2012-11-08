class CreateRawHmSheets < ActiveRecord::Migration
  def self.up
    create_table :raw_hm_sheets do |t|
      
      t.integer :heat_and_material_balance_id
      
      t.integer :column_no
      t.integer :row_no
      t.string :cell_data

      t.timestamps
    end
  end

  def self.down
    drop_table :raw_hm_sheets
  end
end
