class CreateHeatAndMaterialBalances < ActiveRecord::Migration
  def self.up
    create_table :heat_and_material_balances do |t|
      
      t.integer  :project_id
      t.string   :case
      
      t.string   :sheet_file_name
      t.string   :sheet_content_type
      t.integer  :sheet_file_size
      t.datetime :sheet_updated_at
      
      t.integer :excel_format

      t.timestamps
    end
  end

  def self.down
    drop_table :heat_and_material_balances
  end
end
