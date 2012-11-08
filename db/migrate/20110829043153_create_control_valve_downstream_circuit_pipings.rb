class CreateControlValveDownstreamCircuitPipings < ActiveRecord::Migration
  def self.up
    create_table :control_valve_downstream_circuit_pipings do |t|
      
      t.integer :control_valve_downstream_id
      
      t.integer :downstream_maximum_path_id
      t.integer :downstream_normal_path_id
      t.integer :downstream_minimum_path_id
      
      t.string :fitting
      t.string :fitting_tag
      t.string :pipe_size
      t.string :pipe_schedule
      t.float :pipe_id, :limit => 53
      t.float :per_flow, :limit => 53
      t.float :ds_cv, :limit => 53
      t.float :length, :limit => 53
      t.float :elev, :limit => 53
      t.float :delta_p_max, :limit => 53
      t.float :delta_p_nor, :limit => 53
      t.float :delta_p_min, :limit => 53
      t.float :inlet_pressure, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :control_valve_downstream_circuit_pipings
  end
end
