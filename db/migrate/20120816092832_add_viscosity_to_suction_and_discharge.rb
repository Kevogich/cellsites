class AddViscosityToSuctionAndDischarge < ActiveRecord::Migration
  def self.up
  	add_column :suction_pipings, :viscosity, :float, :limit => 53
  	add_column :suction_pipings, :mass_flow_rate, :float, :limit => 53
  	add_column :discharge_circuit_pipings, :viscosity, :float, :limit => 53
  	add_column :discharge_circuit_pipings, :mass_flow_rate, :float, :limit => 53
  end

  def self.down
  	remove_column :suction_pipings, :viscosity
  	remove_column :suction_pipings, :mass_flow_rate
  	remove_column :discharge_circuit_pipings, :viscosity
  	remove_column :discharge_circuit_pipings, :mass_flow_rate
  end
end
