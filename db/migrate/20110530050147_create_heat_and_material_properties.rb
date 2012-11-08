class CreateHeatAndMaterialProperties < ActiveRecord::Migration
  def self.up
    create_table :heat_and_material_properties do |t|
      
      t.integer :heat_and_material_balance_id
      
      t.string :phase
      t.string :property
      t.string :unit
      
      t.timestamps
    end
  end

  def self.down
    drop_table :heat_and_material_properties
  end
end
