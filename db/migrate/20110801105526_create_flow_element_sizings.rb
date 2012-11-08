class CreateFlowElementSizings < ActiveRecord::Migration
  def self.up
    create_table :flow_element_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :flow_element_tag      
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
      
      t.float :up_il_max_fitting_dp, :limit => 53
      t.float :up_il_max_equipment_dp, :limit => 53
      t.float :up_il_max_control_valve_dp, :limit => 53
      t.float :up_il_max_orifice_dp, :limit => 53
      t.float :up_il_max_total_suction_dp, :limit => 53
      t.float :up_il_max_pressure_at_inlet_flange_dp, :limit => 53
      
	    t.float :up_il_min_fitting_dp, :limit => 53
      t.float :up_il_min_equipment_dp, :limit => 53
      t.float :up_il_min_control_valve_dp, :limit => 53
      t.float :up_il_min_orifice_dp, :limit => 53
      t.float :up_il_min_total_suction_dp, :limit => 53
      t.float :up_il_min_pressure_at_inlet_flange_dp, :limit => 53

      t.float :up_il_nor_fitting_dp, :limit => 53
      t.float :up_il_nor_equipment_dp, :limit => 53
      t.float :up_il_nor_control_valve_dp, :limit => 53
      t.float :up_il_nor_orifice_dp, :limit => 53
      t.float :up_il_nor_total_suction_dp, :limit => 53
      t.float :up_il_nor_pressure_at_inlet_flange_dp, :limit => 53
      
      t.string :downstream_condition_basis 

      t.string :os_manufacturer
      t.string :os_model
      t.string :os_pipe_size
      t.string :os_pipe_schedule
      t.string :os_restriction_type
      t.string :os_orifice_type
      t.string :os_pipe_id
      t.string :os_orifice_diameter
      t.string :os_min_differential_pressure
      t.string :os_nor_differential_pressure
      t.string :os_max_differential_pressure
      t.string :os_min_pipe_reynolds_number
      t.string :os_nor_pipe_reynolds_number
      t.string :os_max_pipe_reynolds_number
      t.string :os_min_orifice_reynolds_number
      t.string :os_nor_orifice_reynolds_number
      t.string :os_max_orifice_reynolds_number
      t.string :os_min_beta_b
      t.string :os_nor_beta_b
      t.string :os_max_beta_b
      t.string :os_min_orifice_coefficient_co
      t.string :os_nor_orifice_coefficient_co
      t.string :os_max_orifice_coefficient_co
      t.string :os_min_orifice_diameter_d
      t.string :os_nor_orifice_diameter_d
      t.string :os_max_orifice_diameter_d
      t.string :os_min_orifice_range
      t.string :os_nor_orifice_range
      t.string :os_max_orifice_range
      t.string :os_notes
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :flow_element_sizings
  end
end
