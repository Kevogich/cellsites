class CreateHydraulicDischargeCircuitPipings < ActiveRecord::Migration
  def self.up
    create_table :hydraulic_discharge_circuit_pipings do |t|
      
      t.integer :hydraulic_discharge_id
      
      t.integer :discharge_maximum_path_id
      t.integer :discharge_normal_path_id
      t.integer :discharge_minimum_path_id
      
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
    drop_table :hydraulic_discharge_circuit_pipings
  end
end
