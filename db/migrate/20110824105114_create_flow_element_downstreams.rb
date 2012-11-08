class CreateFlowElementDownstreams < ActiveRecord::Migration
  def self.up
    create_table :flow_element_downstreams do |t|
      
      t.integer :flow_element_sizing_id
      
      t.string :downstream_condition_basis      
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
      t.float :pressure_at_outlet_flange, :limit=>53

      t.timestamps
    end
  end

  def self.down
    drop_table :flow_element_downstreams
  end
end
