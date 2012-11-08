class CreateDownstreams < ActiveRecord::Migration
  def self.up
    create_table :downstreams do |t|
      
      t.integer :downstream_design_id
      t.string :downstream_design_type
      
      t.boolean :design_path
      t.string :destination_stream
      t.string :destination_pressure
      t.string :fitting_dp
      t.string :equipment_dp
      t.string :control_valve_dp
      t.string :orifice_dp
      t.string :total_system_dp
      t.string :press_at_outlet_flange

      t.timestamps
    end
  end

  def self.down
    drop_table :downstreams
  end
end
