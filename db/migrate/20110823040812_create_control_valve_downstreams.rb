class CreateControlValveDownstreams < ActiveRecord::Migration
  def self.up
    create_table :control_valve_downstreams do |t|
      
      t.integer :control_valve_sizing_id
      
      t.string :downstream_condition_basis
      t.integer :path
      
      t.boolean :design_circuit
      t.integer :process_basis_id
      t.integer :path
      t.string :destination_stream_no      
      t.float :destination_pressure, :limit=>53
      t.float :fitting_dp, :limit=>53
      t.float :equipment_dp, :limit=>53
      t.float :control_valve_dp, :limit=>53
      t.float :orifice_dp, :limit=>53
      t.float :total_system_dp, :limit=>53
      t.float :pressure_at_outlet_flange, :limit=>53      

      t.timestamps
    end
  end

  def self.down
    drop_table :control_valve_downstreams
  end
end
