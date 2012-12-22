class AddpressureReliefValveCountReconcileBodySizeApiToPressureReliefSystemDesignParameters < ActiveRecord::Migration
  def self.up
    add_column :pressure_relief_system_design_parameters, :pressure_relief_valve_count_reconcile_body_size_api, :boolean
  end

  def self.down
    remove_column :pressure_relief_system_design_parameters, :pressure_relief_valve_count_reconcile_body_size_api
  end
end
