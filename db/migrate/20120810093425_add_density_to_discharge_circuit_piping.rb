class AddDensityToDischargeCircuitPiping < ActiveRecord::Migration
  def self.up
  	add_column :discharge_circuit_pipings, :density, :float, :limit => 53
  	add_column :suction_pipings, :density, :float, :limit => 53
  end

  def self.down
  	remove_column :discharge_circuit_pipings, :density
  	remove_column :suction_pipings, :density
  end
end
