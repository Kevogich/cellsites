class CreatePumpSizingDischarges < ActiveRecord::Migration
  def self.up
    create_table :pump_sizing_discharges do |t|
      
      t.integer :pump_sizing_id
      t.boolean :design_circuit
      t.integer :process_basis_id
      t.string :destination_stream_no
      t.integer :psd_circuit_piping_id
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
    drop_table :pump_sizing_discharges
  end
end
