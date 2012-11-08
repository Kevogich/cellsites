class CreateVesselSizings < ActiveRecord::Migration
  def self.up
    create_table :vessel_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :name
      
      t.integer :process_basis_id
      
      t.string :feed_stream_stream_no
      t.float :feed_stream_pressure, :limit => 53
      t.float :feed_stream_temperature, :limit => 53
      t.float :feed_stream_mass_vapor_fraction, :limit => 53
      t.float :feed_stream_flow_rate, :limit => 53
      t.float :feed_stream_density, :limit => 53
      t.float :feed_stream_viscosity, :limit => 53

      t.string :top_outlet_stream_stream_no
      t.float :top_outlet_stream_flow_rate, :limit => 53
      t.float :top_outlet_stream_mass_vapor_fraction, :limit => 53
      t.float :top_outlet_stream_pressure, :limit => 53
      t.float :top_outlet_stream_temperature, :limit => 53
      t.float :top_outlet_stream_density, :limit => 53
      t.float :top_outlet_stream_viscosity, :limit => 53
      
      t.string :bottom_outlet_stream_stream_no      
      t.float :bottom_outlet_stream_flow_rate, :limit => 53
      t.float :bottom_outlet_stream_mass_vapor_fraction, :limit => 53
      t.float :bottom_outlet_stream_pressure, :limit => 53
      t.float :bottom_outlet_stream_temperature, :limit => 53
      t.float :bottom_outlet_stream_density, :limit => 53
      t.float :bottom_outlet_stream_viscosity, :limit => 53

      #nozzle sizing
      t.string :ns_fn_no_of_nozzle
      t.string :ns_fn_inlet_device
      t.float :ns_fn_fluid_momentum_sizing_criteria, :limit => 53
      t.float :ns_fn_density, :limit => 53
      t.float :ns_fn_velocity, :limit => 53
      t.float :ns_fn_volumetric_rate, :limit => 53
      t.float :ns_fn_dmin, :limit => 53
      t.float :ns_fn_nozzle_size, :limit => 53
      t.string :ns_fn_nozzle_schedule
      t.float :ns_fn_nozzle_id, :limit => 53
      t.float :ns_fn_nozzle_od, :limit => 53
      t.string :ns_fn_ap_piping_segment
      t.string :ns_fn_ap_source
      t.string :ns_fn_ap_destination
      t.float :ns_fn_ap_pipe_size, :limit => 53
      t.string :ns_fn_ap_pipe_schedule
      t.float :ns_fn_ap_fluid_momentum

      t.string :ns_ton_no_of_nozzle
      t.float :ns_ton_fluid_momentum_sizing_criteria, :limit => 53
      t.float :ns_ton_density, :limit => 53
      t.float :ns_ton_velocity, :limit => 53
      t.float :ns_ton_volumetric_rate, :limit => 53
      t.float :ns_ton_dmin, :limit => 53
      t.float :ns_ton_nozzle_diameter, :limit => 53
      t.string :ns_ton_nozzle_schedule
      t.float :ns_ton_nozzle_id, :limit => 53
      t.float :ns_ton_nozzle_od, :limit => 53
      t.string :ns_ton_ap_piping_segment
      t.string :ns_ton_ap_source
      t.string :ns_ton_ap_destination
      t.float :ns_ton_ap_pipe_size, :limit => 53
      t.string :ns_ton_ap_pipe_schedule
      t.float :ns_ton_ap_fluid_momentum

      t.string :ns_bon_no_of_nozzle
      t.float :ns_bon_fluid_momentum_sizing_criteria, :limit => 53
      t.float :ns_bon_density, :limit => 53
      t.float :ns_bon_velocity, :limit => 53
      t.float :ns_bon_volumetric_rate, :limit => 53
      t.float :ns_bon_dmin, :limit => 53
      t.float :ns_bon_nozzle_diameter, :limit => 53
      t.string :ns_bon_nozzle_schedule
      t.float :ns_bon_nozzle_id, :limit => 53
      t.float :ns_bon_nozzle_od, :limit => 53
      t.string :ns_bon_ap_piping_segment
      t.string :ns_bon_ap_source
      t.string :ns_bon_ap_destination
      t.float :ns_bon_ap_pipe_size, :limit => 53
      t.string :ns_bon_ap_pipe_schedule
      t.float :ns_bon_ap_fluid_momentum

      t.string :ns_vortex_formation

      #Vertical Separator
      t.float :vs_ld, :limit => 53
      t.float :vs_liquid_hold_time, :limit => 53

      t.boolean :vs_include_wire_mesh
      t.boolean :vs_foaming_service

      t.string :vs_mist_extractor_type

      t.float :vs_dnm_vl_separation_factor, :limit => 53
      t.float :vs_dnm_vapor_velocity_factor_kv, :limit => 53
      t.float :vs_dnm_kv_derating_factor, :limit => 53
      t.float :vs_dnm_max_design_vapor_velocity_vmax, :limit => 53
      t.float :vs_dnm_dmin, :limit => 53
      t.float :vs_dnm_diameter, :limit => 53

      t.float :vs_dmd_k_factor, :limit => 53
      t.float :vs_dmd_allow_vapor_velocity, :limit => 53
      t.float :vs_dmd_design_velocity, :limit => 53
      t.float :vs_dmd_mesh_diameter, :limit => 53
      t.float :vs_dmd_est_press_drop, :limit => 53
      t.float :vs_dmd_diameter, :limit => 53

      t.float :vs_hnm_nozzle_to_top_tangent, :limit => 53
      t.float :vs_hnm_nozzle_height, :limit => 53
      t.float :vs_hnm_hll_to_nozzle, :limit => 53
      t.float :vs_hnm_additional_liquid_hold_up, :limit => 53
      t.float :vs_hnm_liquid_hold_up, :limit => 53
      t.float :vs_hnm_bottom_tangent_to_lll, :limit => 53
      t.float :vs_hnm_total_height, :limit => 53

      t.float :vs_hmd_demister_to_top_tangent, :limit => 53
      t.float :vs_hmd_demister_height, :limit => 53
      t.float :vs_hmd_nozzle_to_demister, :limit => 53
      t.float :vs_hmd_nozzle_height, :limit => 53
      t.float :vs_hmd_hll_to_nozzle, :limit => 53
      t.float :vs_hmd_additional_liquid_hold_up, :limit => 53
      t.float :vs_hmd_liquid_hold_up, :limit => 53
      t.float :vs_hmd_bottom_tangent_to_lll, :limit => 53
      t.float :vs_hmd_total_height, :limit => 53

      t.string :vs_notes
      
      #Horizontal Separator
      t.float :hs_ld, :limit => 53
      t.float :hs_liquid_surge_time, :limit => 53
      t.float :hs_vl_separation_factor, :limit => 53
      t.float :hs_vapor_velocity_factor_kv, :limit => 53
      t.float :hs_max_design_vapor_velocity_vmax, :limit => 53
      t.float :hs_vapor_flow_area, :limit => 53
      t.float :hs_liquid_flow_area, :limit => 53
      t.float :hs_dmin, :limit => 53
      t.float :hs_vessel_volume, :limit => 53
      t.float :hs_calculated_liquid_surge_time, :limit => 53      
      t.float :hs_horizontal_separator_diameter, :limit => 53
      t.float :hs_horizontal_separator_length, :limit => 53
      t.boolean :hs_consider_water_settling
      t.string :hs_water_stream
      t.float :hs_water_flowRate, :limit => 53
      t.float :hs_water_density, :limit => 53
      t.float :settling_zone_length, :limit => 53
      t.boolean :hs_wire_mesh_design_include
      t.float :hs_k_factor, :limit => 53
      t.float :hs_allow_vapor_velocity
      t.float :hs_design_velocity
      t.float :hs_mesh_diameter
      t.float :hs_est_press_drop
      t.string :hs_notes
      
      #Decanter
      t.float :dc_ld, :limit => 53
      t.float :dc_dispersed_phase, :limit => 53
      t.float :dc_settling_rate_of_light_phase, :limit => 53
      t.float :dc_settling_rate_of_heavy_phase, :limit => 53
      t.float :dc_area_interface, :limit => 53
      t.float :dc_cross_sectional_area_light, :limit => 53
      t.float :dc_cross_sectional_area_heavy, :limit => 53
      t.float :dc_coalescence_time, :limit => 53
      t.float :dc_reynolds_number_light, :limit => 53
      t.float :dc_reynolds_number_heavy, :limit => 53
      t.float :dc_diameter, :limit => 53
      t.float :dc_length, :limit => 53      
      t.string :dc_notes
      
      #Settler
      t.float :st_ld, :limit => 53
      t.float :st_light_phase_flowrate, :limit => 53
      t.float :st_heavy_phase_flowrate, :limit => 53
      t.float :st_light_phase_terminal_velocity, :limit => 53
      t.float :st_heavy_phase_terminal_velocity, :limit => 53
      t.float :st_light_phase_height, :limit => 53
      t.float :st_heavy_phase_height, :limit => 53
      t.float :st_interface_height, :limit => 53
      t.float :st_light_phase_residence_time, :limit => 53
      t.float :st_diameter, :limit => 53
      t.float :st_length, :limit => 53
      t.string :st_notes
      
      #Filter
      t.string :ft_filter_type
      t.string :ft_manufacture
      t.string :ft_model
      t.float :ft_filtration_rating_min, :limit => 53
      t.float :ft_filtration_rating_max, :limit => 53
      t.float :ft_filtration_efficiency, :limit => 53
      t.float :ft_max_allowable_dirty_dp, :limit => 53
      t.float :ft_normal_dp, :limit => 53
      t.float :ft_capcity, :limit => 53
      t.float :ft_pressure_rating, :limit => 53
      t.float :ft_temperature_rating, :limit => 53
      t.float :ft_shell_diameter, :limit => 53
      t.float :ft_shell_length, :limit => 53
      t.string :ft_microns
      t.string :ft_notes

      #Refactor
      t.string :re_design_code
      t.float :re_max_allowable_dp
      t.float :re_normal_dp
      t.float :re_capacity
      t.float :re_pressure_rating
      t.float :re_temperature_rating
      t.float :re_shell_diameter
      t.float :re_shell_length
      t.float :re_notes
      
      #Design Conditions
      t.string :dc_design_code
      t.string :dc_stamped
      t.float :dc_min_pressure_vessel_design_press, :limit => 53
      t.float :dc_normal_operating_pressure, :limit => 53
      t.float :dc_normal_operating_temperature, :limit => 53
      t.float :dc_maximum_operating_pressure, :limit => 53
      t.float :dc_maximum_operating_temperature, :limit => 53
      t.float :dc_max_possible_supply_pressure_to_vessel, :limit => 53
      t.boolean :dc_relief_to_collection_header_system
      t.float :dc_collection_system_back_pressure, :limit => 53
      t.string :dc_relief_device_type 
      t.float :dc_max_vacuum_pressure, :limit => 53
      t.float :dc_atmospheric_pressure, :limit => 53
      t.float :dc_max_design_temperature, :limit => 53
      t.float :dc_minimum_operating_temperature, :limit => 53
      t.float :dc_minimum_amb_design_temperature, :limit => 53
      t.boolean :dc_equipment_subject_to_steam_out
      t.boolean :dc_equipment_subject_to_dry_out
      t.float :dc_design_pressure, :limit => 53
      t.float :dc_design_temperature, :limit => 53
      t.float :dc_design_vacuum, :limit => 53
      t.float :dc_minimum_design_temperature, :limit => 53
      t.float :dc_test_pressure, :limit => 53
            
      #Mechanical Design
      t.float :md_design_pressure, :limit => 53      
      t.float :md_design_temperature, :limit => 53
      t.float :md_minimum_temperature, :limit => 53
      t.string :md_vessel_orientation     
      t.string :md_material_of_construction
      t.float :md_allowable_stress, :limit => 53
      t.float :md_shell_corrosion_allowance, :limit => 53
      t.string :md_head_type
      t.float :md_head_corrosion_allowance, :limit => 53
      t.float :md_shell_head_joint_efficiency, :limit => 53
      t.float :md_straight_flange, :limit => 53
      t.float :md_vessel_material_density, :limit => 53
      t.float :md_vessel_weight_allowance, :limit => 53
      t.float :md_vessel_content_density, :limit => 53
      t.string :md_vessel_type
      t.float :md_shell_diameter, :limit => 53
      t.float :md_shell_length, :limit => 53
      t.float :md_shell_thickness, :limit => 53
      t.float :md_head_thickness, :limit => 53
      t.float :md_weight_empty_vessel, :limit => 53
      t.float :md_weight_full_vessel, :limit => 53
      t.float :md_total_capacity, :limit => 53
      
      t.string :md_notes

      #Heuristics Review
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

      t.string :design_condition_review_1
      t.string :design_condition_review_2
      t.string :design_condition_review_3
      t.string :design_condition_review_4
      t.string :design_condition_review_5
      t.string :design_condition_review_6
      t.string :design_condition_review_7
      t.string :design_condition_review_8

      t.string :review_notes
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :vessel_sizings
  end
end
