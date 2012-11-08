class AddTwoPhaseToPressureRelief < ActiveRecord::Migration
  def self.up
    add_column :pressure_relief_system_design_parameters, :rdsb_vdc_two_phase, :float, :limit => 53
  end

  def self.down
    remove_column :pressure_relief_system_design_parameters, :rdsb_vdc_two_phase
  end
end
