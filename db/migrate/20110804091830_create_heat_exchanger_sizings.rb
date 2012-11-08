class CreateHeatExchangerSizings < ActiveRecord::Migration
  def self.up
    create_table :heat_exchanger_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id

      t.string :exchanger_tag

      t.integer :sd_process_basis_id
      t.string :sd_exchanger_type
      t.string :sd_st_stream_no_hot_in
      t.float :sd_st_pressure_hot_in
      t.float :sd_st_temperature_hot_in
      t.string :sd_st_stream_no_hot_out
      t.float :sd_st_pressure_hot_out
      t.float :sd_st_temperature_hot_out
      t.string :sd_st_stream_no_cold_in
      t.float :sd_st_pressure_cold_in
      t.float :sd_st_temperature_cold_in
      t.string :sd_st_stream_no_cold_out
      t.float :sd_st_pressure_cold_out
      t.float :sd_st_temperature_cold_out
      t.string :sd_ac_stream_no_hot_in
      t.float :sd_ac_pressure_hot_in
      t.float :sd_ac_temperature_hot_in
      t.string :sd_ac_stream_no_hot_out
      t.float :sd_ac_pressure_hot_out
      t.float :sd_ac_temperature_hot_out
      t.string :sd_pf_stream_no_hot_in
      t.float :sd_pf_pressure_hot_in
      t.float :sd_pf_temperature_hot_in
      t.string :sd_pf_stream_no_hot_out
      t.float :sd_pf_pressure_hot_out
      t.float :sd_pf_temperature_hot_out
      t.string :sd_pf_stream_no_cold_in
      t.float :sd_pf_pressure_cold_in
      t.float :sd_pf_temperature_cold_in
      t.string :sd_pf_stream_no_cold_out
      t.float :sd_pf_pressure_cold_out
      t.float :sd_pf_temperature_cold_out
      t.string :sd_fh_stream_no_cold_in
      t.float :sd_fh_pressure_cold_in
      t.float :sd_fh_temperature_cold_in
      t.string :sd_fh_stream_no_cold_out
      t.float :sd_fh_pressure_cold_out
      t.float :sd_fh_temperature_cold_out

      t.string :ss_hi_stream_no
      t.string :ss_ho_stream_no
      t.string :ss_ci_stream_no
      t.string :ss_co_stream_no
      t.float :ss_hi_pressure
      t.float :ss_ho_pressure
      t.float :ss_ci_pressure
      t.float :ss_co_pressure
      t.float :ss_hi_temperature
      t.float :ss_ho_temperature
      t.float :ss_ci_temperature
      t.float :ss_co_temperature
      t.float :ss_hi_mass_vapor_fraction
      t.float :ss_ho_mass_vapor_fraction
      t.float :ss_ci_mass_vapor_fraction
      t.float :ss_co_mass_vapor_fraction
      t.float :ss_hi_liquid_flow_rate
      t.float :ss_ho_liquid_flow_rate
      t.float :ss_ci_liquid_flow_rate
      t.float :ss_co_liquid_flow_rate
      t.float :ss_hi_liquid_density
      t.float :ss_ho_liquid_density
      t.float :ss_ci_liquid_density
      t.float :ss_co_liquid_density
      t.float :ss_hi_liquid_viscosity
      t.float :ss_ho_liquid_viscosity
      t.float :ss_ci_liquid_viscosity
      t.float :ss_co_liquid_viscosity
      t.float :ss_hi_liquid_specific_heat_capacity
      t.float :ss_ho_liquid_specific_heat_capacity
      t.float :ss_ci_liquid_specific_heat_capacity
      t.float :ss_co_liquid_specific_heat_capacity
      t.float :ss_hi_liquid_thermal_conductivity
      t.float :ss_ho_liquid_thermal_conductivity
      t.float :ss_ci_liquid_thermal_conductivity
      t.float :ss_co_liquid_thermal_conductivity
      t.float :ss_hi_liquid_latent_heat
      t.float :ss_ho_liquid_latent_heat
      t.float :ss_ci_liquid_latent_heat
      t.float :ss_co_liquid_latent_heat
      t.float :ss_hi_liquid_surface_tension
      t.float :ss_ho_liquid_surface_tension
      t.float :ss_ci_liquid_surface_tension
      t.float :ss_co_liquid_surface_tension
      t.float :ss_hi_liquid_expansion_coefficient
      t.float :ss_ho_liquid_expansion_coefficient
      t.float :ss_ci_liquid_expansion_coefficient
      t.float :ss_co_liquid_expansion_coefficient
      t.float :ss_hi_liquid_bubblepoint_temperature
      t.float :ss_ho_liquid_bubblepoint_temperature
      t.float :ss_ci_liquid_bubblepoint_temperature
      t.float :ss_co_liquid_bubblepoint_temperature
      t.float :ss_hi_vapor_flow_rate
      t.float :ss_ho_vapor_flow_rate
      t.float :ss_ci_vapor_flow_rate
      t.float :ss_co_vapor_flow_rate
      t.float :ss_hi_vapor_mw
      t.float :ss_ho_vapor_mw
      t.float :ss_ci_vapor_mw
      t.float :ss_co_vapor_mw
      t.float :ss_hi_vapor_z
      t.float :ss_ho_vapor_z
      t.float :ss_ci_vapor_z
      t.float :ss_co_vapor_z
      t.float :ss_hi_vapor_k
      t.float :ss_ho_vapor_k
      t.float :ss_ci_vapor_k
      t.float :ss_co_vapor_k
      t.float :ss_hi_vapor_viscosity
      t.float :ss_ho_vapor_viscosity
      t.float :ss_ci_vapor_viscosity
      t.float :ss_co_vapor_viscosity
      t.float :ss_hi_vapor_specific_heat_capacity
      t.float :ss_ho_vapor_specific_heat_capacity
      t.float :ss_ci_vapor_specific_heat_capacity
      t.float :ss_co_vapor_specific_heat_capacity
      t.float :ss_hi_vapor_thermal_conductivity
      t.float :ss_ho_vapor_thermal_conductivity
      t.float :ss_ci_vapor_thermal_conductivity
      t.float :ss_co_vapor_thermal_conductivity
      t.float :ss_hi_vapor_dewpoint_temperature
      t.float :ss_ho_vapor_dewpoint_temperature
      t.float :ss_ci_vapor_dewpoint_temperature
      t.float :ss_co_vapor_dewpoint_temperature

      #shell & Tube
      t.string :st_exchanger_flow_type
      t.string :st_exchanger_type
      t.string :st_exchanger_fo_shell_side
      t.string :st_exchanger_fo_tube_side
      t.float :st_tube_od
      t.float :st_tube_thickness
      t.float :st_tube_length
      t.string :st_tube_id, :limit => 25
      t.string :st_tube_material, :limit => 25
      t.string :st_tube_pitch, :limit => 25
      t.float :st_metal_resistance
      t.float :st_fouling_resistance_shell_side
      t.float :st_fouling_resistance_tube_side
      t.float :st_film_resistance_shell_side
      t.float :st_film_resistance_tube_side
      t.float :st_heat_duty
      t.float :st_metal_temperature
      t.float :st_lmtd
      t.float :st_f_factor
      t.float :st_corrected_lmtd
      t.integer :st_required_no_of_tubes
      t.float :st_estimated_shell_inner_diameter
      t.float :st_allowable_pressure_drop_shell_side
      t.float :st_calculated_pressure_drop_shell_side
      t.float :st_allowable_pressure_drop_tube_side
      t.float :st_calculated_pressure_drop_tube_side
      t.float :st_allowable_velocity_shell_side
      t.float :st_calculated_velocity_shell_side
      t.float :st_allowable_velocity_tube_side
      t.float :st_calculated_velocity_tube_side
      t.float :st_calculated_overall_service_u
      t.float :st_calculated_overall_clean_u
      t.integer :st_baffle_type
      t.float :st_baffle_cut
      t.float :st_baffle_spacing
      t.float :st_pitch_ratio
      t.string :st_tube_type
      t.string :st_heat_transfer_area
      t.string :st_shell_tube_pass

      # aerial cooler
      t.string :ac_exchanger_flow_type
      t.string :ac_exchanger_type
      t.string :ac_orientation
      t.string :ac_exchanger_tt_tube_type
      t.float :ac_d_tube_od
      t.float :ac_d_tube_thickness
      t.float :ac_d_tube_length
      t.string :ac_d_tube_id, :limit => 25
      t.string :ac_d_tube_material, :limit => 25
      t.string :ac_d_tube_pitch, :limit => 25
      t.float :ac_htc_metal_resistance
      t.float :ac_htc_fouling_resistance_tube_side
      t.float :ac_htc_film_resistance_tube_side
      t.float :ac_htc_film_resistance_air_side
      t.float :ac_f_fin_height
      t.string :ac_f_fin_spacing
      t.float :ac_dps_heat_duty
      t.float :ac_htc_metal_temperature
      t.float :ac_dps_f_factor
      t.float :ac_dps_corrected_lmtb
     t.integer :ac_d_no_of_tubes
      t.float :ac_pd_allowable_pressure_drop_tube_side
      t.float :ac_pd_calculated_pressure_drop_tube_side
      t.float :ac_dps_lmtd, :string
      t.float :ac_as_air_quantity_item
      t.float :ac_as_air_quantity_fan
      t.float :ac_as_air_temperature_in
      t.float :ac_as_air_temperature_out
      t.string :ac_as_altitude, :limit => 25
      t.integer :ac_uc_no_of_units
      t.integer :ac_uc_no_of_bays_unit
      t.integer :ac_uc_no_of_bundle_bay
      t.string :ac_d_heat_transfer_area, :limit => 25
      t.string :ac_d_bare_tube_area, :limit => 25
      t.string :ac_d_finned_tube_area, :limit => 25
      t.integer :ac_d_no_of_tube_row
      t.integer :ac_d_no_of_tube_pass
      t.float :ac_d_rows_pass
      t.string :ac_htc_overall_service_u_bare, :limit => 25
      t.string :ac_htc_overall_clean_u_bare, :limit => 25
      t.string :ac_htc_overall_u_extended, :limit => 25
      t.float :ac_v_allowable_velocity_tube_side
      t.float :ac_v_calculated_velocity_tube_side
      t.string :ac_f_type, :limit => 25
      t.string :ac_f_material, :limit => 25
      t.string :ac_f_fin_thickness, :limit => 25
      t.string :ac_fan_diameter, :limit => 25
      t.string :ac_fan_fan_bay, :limit => 25
      t.string :ac_fan_power_fan, :limit => 25
      t.string :ac_d_orientation

      #Fired Heater
      t.float :fh_dps_total_heat_duty
      t.float :fh_dps_thermal_efficiency_nte
      t.float :fh_dps_total_available_heat_duty
      t.string :fh_tube_material
      t.string :fh_fired_heater_sections
      t.string :fh_fired_equipment_type
      t.string :fh_direct_fired_type
      t.string :fh_dps_rs_service ,:limit => 25
      t.string :fh_dps_cs_service ,:limit => 25
      t.string :fh_dps_rs_heat_absorption, :limit => 25
      t.string :fh_dps_cs_heat_absorption, :limit => 25
      t.float :fh_dps_rs_allowable_pressure_drop_clean
      t.float :fh_dps_cs_allowable_pressure_drop_clean
      t.float :fh_dps_rs_calculated_pressure_drop_clean
      t.float :fh_dps_cs_calculated_pressure_drop_clean
      t.float :fh_dps_rs_allowable_pressure_drop_fouled
      t.float :fh_dps_cs_allowable_pressure_drop_fouled
      t.float :fh_dps_rs_calculated_pressure_drop_fouled
      t.float :fh_dps_cs_calculated_pressure_drop_fouled
      t.float :fh_dps_rs_avg_radiant_flux_density_allowable
      t.float :fh_dps_cs_avg_radiant_flux_density_allowable
      t.float :fh_dps_rs_avg_radiant_flux_density_calc
      t.float :fh_dps_cs_avg_radiant_flux_density_calc
      t.float :fh_dps_rs_max_radiant_flux_density_calc
      t.float :fh_dps_cs_max_radiant_flux_density_calc
      t.float :fh_dps_rs_conv_section_flux_density_bare_tube
      t.float :fh_dps_cs_conv_section_flux_density_bare_tube
      t.float :fh_dps_rs_velocity_limitations
      t.float :fh_dps_cs_velocity_limitations
      t.float :fh_dps_rs_process_fluid_mass_velocity
      t.float :fh_dps_cs_process_fluid_mass_velocity
      t.float :fh_dps_rs_max_allowable_inside_film_temp
      t.float :fh_dps_cs_max_allowable_inside_film_temp
      t.float :fh_dps_rs_max_calculated_inside_film_temp
      t.float :fh_dps_cs_max_calculated_inside_film_temp
      t.float :fh_dps_rs_fouling_factor
      t.float :fh_dps_cs_fouling_factor
      t.float :fh_dps_rs_cooking_allowance
      t.float :fh_dps_cs_cooking_allowance
      t.float :fh_d_rs_tube_orientation
      t.float :fh_d_cs_tube_orientation
      t.string :fh_d_rs_tube_material, :limit => 25
      t.string :fh_d_cs_tube_material, :limit => 25
      t.float :fh_d_rs_tube_od
      t.float :fh_d_cs_tube_od
      t.float :fh_d_rs_tube_thickness
      t.float :fh_d_cs_tube_thickness
      t.string :fh_d_rs_tube_id, :limit => 25
      t.string :fh_d_cs_tube_id, :limit => 25
      t.float :fh_d_rs_no_of_passes
      t.float :fh_d_cs_no_of_passes
      t.float :fh_d_rs_total_no_of_tubes
      t.float :fh_d_cs_total_no_of_tubes
      t.float :fh_d_rs_no_of_bare_tube
      t.float :fh_d_cs_no_of_bare_tube
      t.float :fh_d_rs_total_exposed_area_bare_tubes
      t.float :fh_d_cs_total_exposed_area_bare_tubes
      t.integer :fh_d_rs_tubes_per_row
      t.integer :fh_d_cs_tubes_per_row
      t.float :fh_d_rs_overall_tube_length
      t.float :fh_d_cs_overall_tube_length
      t.float :fh_d_rs_effective_tube_length
      t.float :fh_d_cs_effective_tube_length
      t.float :fh_d_rs_tube_spacing
      t.float :fh_d_cs_tube_spacing
      t.string :fh_d_rs_tube_layout, :limit => 25
      t.string :fh_d_cs_tube_layout, :limit => 25
      t.string :fh_d_rs_type, :limit => 25
      t.string :fh_d_cs_type, :limit => 25
      t.string :fh_d_rs_material, :limit => 25
      t.string :fh_d_cs_material, :limit => 25
      t.float :fh_d_rs_fin_height
      t.float :fh_d_cs_fin_height
      t.float :fh_d_rs_fin_spacing
      t.float :fh_d_cs_fin_spacing
      t.float :fh_d_rs_fin_thickness
      t.float :fh_d_cs_fin_thickness
      t.float :fh_d_rs_max_tip_temperature
      t.float :fh_d_cs_max_tip_temperature
      t.integer :fh_d_rs_no_of_extended_surface_tube
      t.integer :fh_d_cs_no_of_extended_surface_tube
      t.float :fh_d_rs_total_exposed_area
      t.float :fh_d_cs_total_exposed_area
      t.float :fh_d_rs_extension_ratio
      t.float :fh_d_cs_extension_ratio
      t.string :fh_cd_draft_type
      t.string :fh_cd_fc_fuel
      t.string :fh_cd_ac_air_pressure
      t.string :fh_cd_fc_fuel_mw
      t.string :fh_cd_ac_air_temperature
      t.string :fh_cd_fc_hhv
      t.string :fh_cd_ac_relative_humidity
      t.string :fh_cd_fc_lhv
      t.string :fh_cd_ac_dry_air_required
      t.string :fh_cd_fc_pressure_at_burner
      t.string :fh_cd_ac_humid_air_required
      t.string :fh_cd_fc_temperature_at_burner
      t.string :fh_cd_c_excess_air
      t.string :fh_cd_c_calculated_heat_release_lhv
      t.string :fh_cd_c_fuel_efficiency
      t.string :fh_cd_c_heat_loss_in_radiant_section
      t.string :fh_cd_c_flue_gas_temp_existing_radiant_section
      t.string :fh_cd_c_flue_gas_temp_existing_convection_section
      t.string :fh_cd_c_flue_gas_temp_existing_air_pre_heater
      t.string :fh_cd_c_flue_gas_quantity

      #plate and frame
      t.string :pf_ps_heat_duty, :limit => 25
      t.string :pf_md_manufacture, :limit => 25
      t.float :pf_ps_lmtd
      t.float :pf_md_model_number
      t.string :pf_ps_flow_orientation, :limit => 25
      t.float :pf_md_frame_size
      t.float :pf_ps_corrected_lmtd
      t.integer :pf_md_no_of_units
      t.float :pf_ps_calculated_overall_service_u
      t.float :pf_md_no_of_plates_per_unit
      t.float :pf_ps_calculated_overall_clean_u
      t.float :pf_md_surface_area_per_plate
      t.float :pf_ps_heat_transfer_area
      t.float :pf_md_surface_area_per_unit
      t.integer :pf_dc_hs_no_of_passes
      t.integer :pf_dc_cs_no_of_passes
      t.integer :pf_dc_hs_passages_per_pass
      t.integer :pf_dc_cs_passages_per_pass
      t.float :pf_dc_hs_allowable_pressure_drop
      t.float :pf_dc_cs_allowable_pressure_drop
      t.float :pf_dc_hs_calculated_pressure_drop
      t.float :pf_dc_cs_calculated_pressure_drop
      t.float :pf_dc_hs_fouling_resistance
      t.float :pf_dc_cs_fouling_resistance


      #design conditions
      t.string :dc_design_code
      t.string :dc_stamped
      t.float :dc_min_pressure_vessel_design_press
      t.float :dc_normal_operating_pressure_shell
      t.float :dc_normal_operating_pressure_tube
      t.float :dc_normal_operating_temperature_shell
      t.float :dc_normal_operating_temperature_tube
      t.float :dc_maximum_operating_pressure_shell
      t.float :dc_maximum_operating_pressure_tube
      t.float :dc_maximum_operating_temperature_shell
      t.float :dc_maximum_operating_temperature_tube
      t.float :dc_max_possible_supply_pressure_to_vessel_shell
      t.float :dc_max_possible_supply_pressure_to_vessel_tube
      t.boolean :dc_relief_to_collection_header_system
      t.float :dc_collection_system_back_pressure
      t.string :dc_relief_device_type
      t.float :dc_max_vacuum_pressure_shell
      t.float :dc_max_vacuum_pressure_tube
      t.float :dc_atmospheric_pressure_shell
      t.float :dc_atmospheric_pressure_tube
      t.float :dc_max_temp_relief_press_shell
      t.float :dc_max_temp_relief_press_tube
      t.float :dc_minimum_operating_temp_shell
      t.float :dc_minimum_operating_temp_tube
      t.float :dc_minimum_amb_design_temp_shell
      t.float :dc_minimum_amb_design_temp_tube
      t.boolean :dc_equipment_subject_to_stream_out
      t.boolean :dc_equipment_subject_to_dry_out
      t.float :dc_design_pressure_shell
      t.float :dc_design_pressure_tube
      t.float :dc_design_temperature_shell
      t.float :dc_design_temperature_tube
      t.float :dc_design_vacuum_shell
      t.float :dc_design_vacuum_tube
      t.float :dc_minimum_design_temp_shell
      t.float :dc_minimum_design_temp_tube
      t.float :dc_test_pressure_shell
      t.float :dc_test_pressure_tube

      #mechanical-design
      t.float :md_design_pressure
      t.float :md_design_temperature
      t.float :md_minimum_temperature
      t.string :md_s_material_of_construction
      t.string :md_c_material_of_construction
      t.float :md_s_allowable_stress
      t.float :md_c_allowable_stress
      t.float :md_s_shell_corrosion_allowance
      t.float :md_c_shell_corrosion_allowance
      t.string :md_s_head_type
      t.string :md_c_head_type
      t.integer :md_s_head_corrosion_allowance
      t.integer :md_c_head_corrosion_allowance
      t.float :md_s_head_joint_efficiency
      t.float :md_c_head_joint_efficiency
      t.float :md_s_straight_flange
      t.float :md_c_straight_flange
      t.float :md_shell_inner_diameter
      t.float :md_shell_outer_diameter
      t.float :md_shell_thickness
      t.float :md_head_thickness


      #review
      t.string :sizing_review_1
      t.string :sizing_review_2
      t.string :sizing_review_3
      t.string :sizing_review_4
      t.string :sizing_review_5
      t.string :sizing_review_6
      t.string :sizing_review_7
      t.string :sizing_review_8
      t.string :sizing_review_9
      t.string :sizing_review_10
      t.string :sizing_review_11
      t.string :sizing_review_12
      t.string :sizing_review_13
      t.string :sizing_review_14

      t.string :review_notes

      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :heat_exchanger_sizings
  end
end
