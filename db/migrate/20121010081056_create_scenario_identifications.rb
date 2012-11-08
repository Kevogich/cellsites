class CreateScenarioIdentifications < ActiveRecord::Migration
  def self.up
    create_table :scenario_identifications do |t|
      t.integer :scenario_summary_id
      t.string :scenario_analysis_method, :limit => 50
      t.string :applicability, :limit => 50
      t.string :documentation_by, :limit => 50
      t.text   :comments

      #scenario calculation
      t.string :relief_rate_calculation_method, :limit => 50
      t.float  :sc_set_pressure, :limit => 53
      t.float  :sc_over_pressure, :limit => 53
      t.float  :sc_relief_pressure, :limit => 53
      t.float  :sc_relief_rate, :limit => 53

      t.string :rc_case
      t.string :rc_stream
      t.float  :rc_pressure, :limit => 53
      t.float  :rc_temperature, :limit => 53
      t.float  :rc_mass_vapor_fraction, :limit => 53
      t.float  :rc_vapor_density, :limit => 53
      t.float  :rc_vapor_viscosity, :limit => 53
      t.float  :rc_vapor_k, :limit => 53
      t.float  :rc_vapor_mw, :limit => 53
      t.float  :rc_vapor_z, :limit => 53
      t.float  :rc_liquid_density, :limit => 53
      t.float  :rc_liquid_viscosity, :limit => 53
      t.float  :rc_liquid_vapor_pressure, :limit => 53
      t.float  :rc_liquid_surface_tension, :limit => 53
      t.float  :rc_liquid_latent_heat, :limit => 53
      t.float  :rc_liquid_mw, :limit => 53

      t.string :dc_case
      t.string :dc_stream
      t.float  :dc_pressure, :limit => 53
      t.float  :dc_temperature, :limit => 53
      t.float  :dc_mass_vapor_fraction, :limit => 53
      t.float  :dc_vapor_density, :limit => 53
      t.float  :dc_vapor_viscosity, :limit => 53
      t.float  :dc_vapor_k, :limit => 53
      t.float  :dc_vapor_mw, :limit => 53
      t.float  :dc_vapor_z, :limit => 53
      t.float  :dc_liquid_density, :limit => 53
      t.float  :dc_liquid_viscosity, :limit => 53
      t.float  :dc_liquid_vapor_pressure, :limit => 53
      t.float  :dc_liquid_surface_tension, :limit => 53
      t.float  :dc_liquid_latent_heat, :limit => 53
      t.float  :dc_liquid_mw, :limit => 53

      t.text   :sc_comments

      #required capacity
      t.string :relief_capacity_calculation_method, :limit => 100
      t.string :hem_process_basis_a, :limit => 100
      t.string :hem_process_basis_b, :limit => 100
      t.string :hem_process_basis_c, :limit => 100
      t.string :hem_stream_a, :limit => 100
      t.string :hem_stream_b, :limit => 100
      t.string :hem_stream_c, :limit => 100
      t.float  :hem_pressure_a, :limit => 53
      t.float  :hem_pressure_b, :limit => 53
      t.float  :hem_pressure_c, :limit => 53
      t.float  :hem_mass_vapor_fraction_a, :limit => 53
      t.float  :hem_mass_vapor_fraction_b, :limit => 53
      t.float  :hem_mass_vapor_fraction_c, :limit => 53
      t.float  :hem_liquid_density_a, :limit => 53
      t.float  :hem_liquid_density_b, :limit => 53
      t.float  :hem_liquid_density_c, :limit => 53
      t.float  :hem_vapor_density_a, :limit => 53
      t.float  :hem_vapor_density_b, :limit => 53
      t.float  :hem_vapor_density_c, :limit => 53
      t.float  :hem_liquid_viscosity_a, :limit => 53
      t.float  :hem_liquid_viscosity_b, :limit => 53
      t.float  :hem_liquid_viscosity_c, :limit => 53
      t.float  :hem_vapor_viscosity_a, :limit => 53
      t.float  :hem_vapor_viscosity_b, :limit => 53
      t.float  :hem_vapor_viscosity_c, :limit => 53

      t.boolean :rc_consider_rupture_disk_on_inlet_side

      t.float  :rc_flow_rate, :limit => 53
      t.float  :rc_relieving_pressure, :limit => 53
      t.float  :rc_total_back_pressure, :limit => 53
      t.float  :rc_relieving_temperature, :limit => 53
      t.float  :rc_specific_gravity, :limit => 53
      t.float  :rc_viscosity, :limit => 53
      t.float  :rc_reynolds_number, :limit => 53
      t.float  :rc_coefficient, :limit => 53
      t.float  :rc_coefficient_of_subcritical_flow, :limit => 53
      t.float  :rc_maximum_mass_flux, :limit => 53
      t.float  :rc_back_pressure_correction_factor, :limit => 53
      t.string :rc_back_pressure_correction_factor_list
      t.float  :rc_combination_correction_factor, :limit => 53
      t.float  :rc_discharge_coefficient, :limit => 53
      t.string :rc_discharge_coefficient_list, :limit => 50
      t.float  :rc_napier_correction_factor, :limit => 53
      t.float  :rc_superheat_correction_factor, :limit => 53
      t.float  :rc_overpressure_correction_factor, :limit => 53
      t.string :rc_overpressure_correction_factor_list, :limit => 50
      t.float  :rc_viscosity_correction_factor, :limit => 53
      t.float  :rc_liquid_back_pressure_correction_factor, :limit => 53
      t.string :rc_liquid_back_pressure_correction_factor_list, :limit => 50
      t.float  :rc_effective_discharge_area, :limit => 53
      t.float  :rc_effective_diameter, :limit => 53
      t.float  :rc_available_valve_capacity, :limit => 53
      t.string :rc_piping_material
      t.float  :rc_pipe_roughness, :limit => 53
      t.float  :rc_minimum_required_pipe_id, :limit => 53
      t.float  :rc_minimum_required_pipe_id, :limit => 53
      t.float  :rc_minimum_required_net_flow_area, :limit => 53
      t.string :rc_nominal_pipe_diameter, :limit => 100
      t.string :rc_pipe_schedule, :limit => 100
      t.float  :rc_nominal_pipe_relief_area, :limit => 53
      t.float  :rc_available_relief_path_capacity, :limit => 53
      t.text   :rc_comments

      t.timestamps
    end
  end

  def self.down
    drop_table :scenario_identifications
  end
end
