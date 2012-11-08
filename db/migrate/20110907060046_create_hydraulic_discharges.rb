class CreateHydraulicDischarges < ActiveRecord::Migration
  def self.up
    create_table :hydraulic_discharges do |t|
      
      t.integer :hydraulic_turbine_id
      
      t.string :discharge_condition_basis
      t.integer :path
        
      t.boolean :design_circuit
      t.integer :process_basis_id
      t.string :destination_stream_no     
      t.float :destination_pressure, :limit=>53
      t.float :fitting_dp, :limit=>53
      t.float :equipment_dp, :limit=>53
      t.float :control_valve_dp, :limit=>53
      t.float :orifice_dp, :limit=>53
      t.float :total_system_dp, :limit=>53
      t.float :pressure_at_discharge_nozzle_dp, :limit=>53 

      t.timestamps
    end
  end

  def self.down
    drop_table :hydraulic_discharges
  end
end
