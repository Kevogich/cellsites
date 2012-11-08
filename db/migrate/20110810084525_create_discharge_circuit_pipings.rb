class CreateDischargeCircuitPipings < ActiveRecord::Migration
  def self.up
    create_table :discharge_circuit_pipings do |t|
      
      t.integer :discharge_circuit_pipings_id
      t.string :discharge_circuit_pipings_type
      
      t.string :fitting
      t.string :fitting_tag
      t.string :pipe_size
      t.string :pipe_schedule
      t.float :pipe_id, :limit => 53
      t.float :per_flow, :limit => 53
      t.float :ds_cv, :limit => 53
      t.float :length, :limit => 53
      t.float :elev, :limit => 53
      t.float :delta_p, :limit => 53
      t.float :inlet_pressure, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :discharge_circuit_pipings
  end
end
