class CreateControlValveSizings < ActiveRecord::Migration
  def self.up
    create_table :control_valve_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :control_valve_tag
      
      t.integer :up_process_basis_id
      t.string :upstream_condition_basis
      
      t.string :up_max_stream_no
      t.float :up_max_pressure, :limit => 53
      t.float :up_max_temperature, :limit => 53
      t.string :up_max_stream_phase
      t.float :up_max_mass_vapor_fraction, :limit => 53
      t.float :up_max_mass_flow_rate, :limit => 53
      t.float :up_max_vp_density, :limit => 53
      t.float :up_max_vp_viscosity, :limit => 53
      t.float :up_max_vp_mw, :limit => 53
      t.float :up_max_vp_cp_cv, :limit => 53
      t.float :up_max_vp_z, :limit => 53
      t.float :up_max_lp_density, :limit => 53
      t.float :up_max_lp_viscosity, :limit => 53
      t.float :up_max_lp_surface_tension, :limit => 53
      t.float :up_max_lp_critical_pressure, :limit => 53
      t.float :up_max_lp_vapor_pressure, :limit => 53
      
      t.string :up_nor_stream_no
      t.float :up_nor_pressure, :limit => 53
      t.float :up_nor_temperature, :limit => 53
      t.string :up_nor_stream_phase
      t.float :up_nor_mass_vapor_fraction, :limit => 53
      t.float :up_nor_mass_flow_rate, :limit => 53
      t.float :up_nor_vp_density, :limit => 53
      t.float :up_nor_vp_viscosity, :limit => 53
      t.float :up_nor_vp_mw, :limit => 53
      t.float :up_nor_vp_cp_cv, :limit => 53
      t.float :up_nor_vp_z, :limit => 53
      t.float :up_nor_lp_density, :limit => 53
      t.float :up_nor_lp_viscosity, :limit => 53
      t.float :up_nor_lp_surface_tension, :limit => 53
      t.float :up_nor_lp_critical_pressure, :limit => 53
      t.float :up_nor_lp_vapor_pressure, :limit => 53
      
      t.string :up_min_stream_no
      t.float :up_min_pressure, :limit => 53
      t.float :up_min_temperature, :limit => 53
      t.string :up_min_stream_phase
      t.float :up_min_mass_vapor_fraction, :limit => 53
      t.float :up_min_mass_flow_rate, :limit => 53
      t.float :up_min_vp_density, :limit => 53
      t.float :up_min_vp_viscosity, :limit => 53
      t.float :up_min_vp_mw, :limit => 53
      t.float :up_min_vp_cp_cv, :limit => 53
      t.float :up_min_vp_z, :limit => 53
      t.float :up_min_lp_density, :limit => 53
      t.float :up_min_lp_viscosity, :limit => 53
      t.float :up_min_lp_surface_tension, :limit => 53
      t.float :up_min_lp_critical_pressure, :limit => 53
      t.float :up_min_lp_vapor_pressure, :limit => 53
            
      t.float :up_max_fitting_dp, :limit => 53
      t.float :up_max_equipment_dp, :limit => 53
      t.float :up_max_control_valve_dp, :limit => 53
      t.float :up_max_orifice_dp, :limit => 53
      t.float :up_max_total_upstream_dp, :limit => 53
      t.float :up_max_pressure_at_inlet_flange, :limit => 53      

      t.float :up_min_fitting_dp, :limit => 53
      t.float :up_min_equipment_dp, :limit => 53
      t.float :up_min_control_valve_dp, :limit => 53
      t.float :up_min_orifice_dp, :limit => 53
      t.float :up_min_total_upstream_dp, :limit => 53
      t.float :up_min_pressure_at_inlet_flange, :limit => 53      

 	  t.float :up_nor_fitting_dp, :limit => 53
      t.float :up_nor_equipment_dp, :limit => 53
      t.float :up_nor_control_valve_dp, :limit => 53
      t.float :up_nor_orifice_dp, :limit => 53
      t.float :up_nor_total_upstream_dp, :limit => 53
      t.float :up_nor_pressure_at_inlet_flange, :limit => 53      

      t.string :downstream_condition_basis
      
      t.string :cvs_manufacturer
      t.string :cvs_model
      t.string :cvs_line_size
      t.string :cvs_line_schedule
      t.float :cvs_cv_body_size, :limit => 53
      t.float :cvs_trim_size, :limit => 53
      t.string :cvs_travel
      t.string :cvs_flow_characteristics
      t.float :cvs_valve_flow_coefficient, :limit => 53
      t.float :cvs_valve_pressure_drop_ratio, :limit => 53
      t.float :cvs_valve_liquid_recovery_factor, :limit => 53
      t.float :cvs_valve_style_modifier, :limit => 53
      t.string :cvs_attached_fittings_reducer
      t.float :cvs_piping_geometric_factor, :limit => 53
      t.float :cvs_min_differential_pressure, :limit => 53
      t.float :cvs_nor_differential_pressure, :limit => 53
      t.float :cvs_max_differential_pressure, :limit => 53
      t.float :cvs_min_reynolds_number_factor, :limit => 53
      t.float :cvs_nor_reynolds_number_factor, :limit => 53
      t.float :cvs_max_reynolds_number_factor, :limit => 53
      t.float :cvs_min_required_flow_coefficient, :limit => 53
      t.float :cvs_nor_required_flow_coefficient, :limit => 53
      t.float :cvs_max_required_flow_coefficient, :limit => 53
      t.float :cvs_min_travel_percentage, :limit => 53
      t.float :cvs_nor_travel_percentage, :limit => 53
      t.float :cvs_max_travel_percentage, :limit => 53
      t.string :cvs_min_choke_condition
      t.string :cvs_nor_choke_condition
      t.string :cvs_max_choke_condition
      
      t.boolean :cvb_include_bypass
      t.boolean :cvb_control_valve
      t.boolean :cvb_bypass_sizing_basis
      t.string :cvb_bypass_tag
      t.string :cvb_valve_type
      t.string :cvb_line_size
      t.string :cvb_line_schedule
      t.float :cvb_flow_coefficient, :limit => 53
      t.float :cvb_body_size, :limit => 53
      t.string :cvb_administrative_controls
      t.string :cvb_notes
      
      t.integer :created_by
      t.integer :updated_by      

      t.timestamps
    end
  end

  def self.down
    drop_table :control_valve_sizings
  end
end
