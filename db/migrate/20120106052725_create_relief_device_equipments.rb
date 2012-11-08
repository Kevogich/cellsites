class CreateReliefDeviceEquipments < ActiveRecord::Migration
  def self.up
    create_table :relief_device_equipments do |t|
		t.integer :relief_device_sizing_id       
		t.integer :sequence_no            
		t.string  :equipment_tag          
		t.string  :equipment_description  
		t.string  :equipment_type         
		t.string  :equipment_section      
		t.float   :design_pressure, :limit => 53        
      t.timestamps
    end
  end

  def self.down
    drop_table :relief_device_equipments
  end
end
