class AddNewFieldsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :hydraulic_sizing_overdesign_factor, :float, :limit => 53
    add_column :projects, :minimum_control_value_pressure_drop, :float, :limit => 53
    add_column :projects, :default_rated_liquid_pressure_recovery_factor, :float, :limit => 53
    rename_column :projects, :pump_design_safety_factor, :centrifugal_pump_design_safety_factor
    add_column :projects, :default_centrifugal_pump_efficiency, :float, :limit => 53
    add_column :projects, :centrifugal_pump_shut_off_factor, :float, :limit => 53
    add_column :projects, :positive_displacement_mechanical_efficiency, :float, :limit => 53
    add_column :projects, :positive_displacement_pump_design_safety_factor, :float, :limit => 53
    rename_column :projects, :compressor_safety_factor, :compressor_design_safety_factor
    rename_column :projects, :allowable_compressor_mawt, :allowable_centrifugal_compressor_mawt    
    add_column :projects, :allowable_compression_ratio_per_recip_comp_stage_start, :float, :limit => 53
    add_column :projects, :allowable_compression_ratio_per_recip_comp_stage_end, :float, :limit => 53
    add_column :projects, :hydraulic_power_recovery_turbine_efficiency, :float, :limit => 53
    add_column :projects, :hydraulic_power_recovery_turbine_design_safety_factor, :float, :limit => 53
    add_column :projects, :turbo_expander_efficiency, :float, :limit => 53
    add_column :projects, :default_optimal_reflux_ratio_factor, :float, :limit => 53
    add_column :projects, :default_vessel_design_g_lq_ratio, :float, :limit => 53
    add_column :projects, :minimum_exchanger_design_pressure, :float, :limit => 53
    add_column :projects, :maximum_collection_header_back_pressure, :float, :limit => 53
    add_column :projects, :minimum_ambient_design_temperature, :float, :limit => 53
  end

  def self.down
    remove_column :projects, :hydraulic_sizing_overdesign_factor
    remove_column :projects, :minimum_control_value_pressure_drop
    remove_column :projects, :default_rated_liquid_pressure_recovery_factor
    rename_column :projects, :centrifugal_pump_design_safety_factor, :pump_design_safety_factor
    remove_column :projects, :default_centrifugal_pump_efficiency
    remove_column :projects, :centrifugal_pump_shut_off_factor
    remove_column :projects, :positive_displacement_mechanical_efficiency
    remove_column :projects, :positive_displacement_pump_design_safety_factor
    rename_column :projects, :compressor_design_safety_factor, :compressor_safety_factor 
    rename_column :projects, :allowable_centrifugal_compressor_mawt, :allowable_compressor_mawt
    remove_column :projects, :allowable_compression_ratio_per_recip_comp_stage_start
    remove_column :projects, :allowable_compression_ratio_per_recip_comp_stage_end
    remove_column :projects, :hydraulic_power_recovery_turbine_efficiency
    remove_column :projects, :hydraulic_power_recovery_turbine_design_safety_factor
    remove_column :projects, :turbo_expander_efficiency
    remove_column :projects, :default_optimal_reflux_ratio_factor
    remove_column :projects, :default_vessel_design_g_lq_ratio
    remove_column :projects, :minimum_exchanger_design_pressure
    remove_column :projects, :maximum_collection_header_back_pressure
    remove_column :projects, :minimum_ambient_design_temperature
  end
end
