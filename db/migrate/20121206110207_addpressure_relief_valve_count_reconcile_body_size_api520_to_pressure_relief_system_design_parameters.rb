class AddpressureReliefValveCountReconcileBodySizeApi520ToPressureReliefSystemDesignParameters < ActiveRecord::Migration
  def self.up
    add_column :pressure_relief_system_design_parameters, :pressure_relief_valve_count_reconcile_body_size_api520, :boolean
  end

  def self.down
    remove_column :pressure_relief_system_design_parameters, :pressure_relief_valve_count_reconcile_body_size_api520
  end
end
