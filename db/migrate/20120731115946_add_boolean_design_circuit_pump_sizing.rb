class AddBooleanDesignCircuitPumpSizing < ActiveRecord::Migration
  def self.up
  	add_column :pump_sizings, :selected_discharge_design_circuit, :integer
  end

  def self.down
  	remove_column :pump_sizings, :selected_discharge_design_circuit, :integer
  end
end
