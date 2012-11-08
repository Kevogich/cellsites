class AddFields4to8ToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :cases_str, :string
    add_column :projects, :vapor_flow_model, :string
    add_column :projects, :two_phase_flow_model, :string
    add_column :projects, :barometric_pressure, :string
    add_column :projects, :pipe_size_overdesign_factor, :string
    add_column :projects, :control_flow_bias_min, :string
    add_column :projects, :control_flow_bias_normal, :string
    add_column :projects, :control_flow_bias_max, :string
    add_column :projects, :default_pressure_drop_ratio_factor, :string
    add_column :projects, :pump_design_safety_factor, :string
    add_column :projects, :default_pump_efficiency_factor, :string
    add_column :projects, :pump_shutoff_factor, :string
    add_column :projects, :compression_path, :string
    add_column :projects, :compressor_safety_factor, :string
    add_column :projects, :allowable_compressor_mawt, :string
    add_column :projects, :default_vessel_design_ld_ratio, :string
    add_column :projects, :min_pressure_vessel_design_pressure, :string
    add_column :projects, :min_collection_header_back_pressure, :string
    add_column :projects, :test_pressure_factor, :string
    add_column :projects, :k_factor_for_wire_mesh_design, :string
    add_column :projects, :restriction_orifice_meter_default_type, :string

  end

  def self.down
    remove_column :projects, :cases_str
    remove_column :projects, :vapor_flow_model
    remove_column :projects, :two_phase_flow_model
    remove_column :projects, :barometric_pressure
    remove_column :projects, :pipe_size_overdesign_factor
    remove_column :projects, :control_flow_bias_min
    remove_column :projects, :control_flow_bias_normal
    remove_column :projects, :control_flow_bias_max
    remove_column :projects, :default_pressure_drop_ratio_factor
    remove_column :projects, :pump_design_safety_factor
    remove_column :projects, :default_pump_efficiency_factor
    remove_column :projects, :pump_shutoff_factor
    remove_column :projects, :compression_path
    remove_column :projects, :compressor_safety_factor
    remove_column :projects, :allowable_compressor_mawt
    remove_column :projects, :default_vessel_design_ld_ratio
    remove_column :projects, :min_pressure_vessel_design_pressure
    remove_column :projects, :min_collection_header_back_pressure
    remove_column :projects, :test_pressure_factor
    remove_column :projects, :k_factor_for_wire_mesh_design
    remove_column :projects, :restriction_orifice_meter_default_type

  end
end
