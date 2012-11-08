class CreateColumnSizings < ActiveRecord::Migration
  def self.up
    create_table :column_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :column_system
      
      t.integer :sd_process_basis_id
      t.float :sd_max_liquid_level, :limit=>53
      t.float :sd_bottom_density, :limit=>53
      t.float :sd_column_dp, :limit=>53
      t.float :sd_static_pressure, :limit=>53
      t.float :sd_stream_no_1
      t.float :sd_pressure_1
      t.float :sd_temperature_1
      t.float :sd_stream_no_2
      t.float :sd_pressure_2
      t.float :sd_temperature_2
      t.float :sd_stream_no_3
      t.float :sd_pressure_3
      t.float :sd_temperature_3
      t.float :sd_stream_no_4
      t.float :sd_pressure_4
      t.float :sd_temperature_4
      t.float :sd_stream_no_5
      t.float :sd_pressure_5
      t.float :sd_temperature_5
      t.float :sd_stream_no_6
      t.float :sd_pressure_6
      t.float :sd_temperature_6

      t.integer :sd_minimum_column_stages
      t.float :sd_minimum_reflux_ratio
      t.float :sd_optimal_reflux_ratio_factor
      t.float :sd_actual_reflux_ratio
      t.float :sd_optimal_stage_ratio
      t.integer :sd_no_of_theoretical_column_trays
      t.float :sd_no_of_trays_above_feed
      t.float :sd_no_of_trays_below_feed
      t.float :sd_overall_tray_efficiency
      t.float :sd_total_actual_tray
      t.string :sd_foaming_service
      t.float :sd_system_factor

      t.string :sd_column_type, :limit => "20"

      t.integer :ts_number_of_peak_loading_sections

      t.string :cd_ss_description_1
      t.string :cd_ss_tray_type_1
      t.integer :cd_ss_tcount_1
      t.float :cd_ss_tspacing_1
      t.string :cd_ss_hetp_1
      t.float :cd_ss_height_1
      t.float :cd_ss_diameter_1
      t.float :cd_ss_section_dp_1
      t.string :cd_ss_description_2
      t.string :cd_ss_tray_type_2
      t.integer :cd_ss_tcount_2
      t.float :cd_ss_tspacing_2
      t.string :cd_ss_hetp_2
      t.float :cd_ss_height_2
      t.float :cd_ss_diameter_2
      t.float :cd_ss_section_dp_2
      t.string :cd_ss_description_3
      t.string :cd_ss_tray_type_3
      t.integer :cd_ss_tcount_3
      t.float :cd_ss_tspacing_3
      t.string :cd_ss_hetp_3
      t.float :cd_ss_height_3
      t.float :cd_ss_diameter_3
      t.float :cd_ss_section_dp_3
      t.string :cd_ss_description_4
      t.string :cd_ss_tray_type_4
      t.integer :cd_ss_tcount_4
      t.float :cd_ss_tspacing_4
      t.string :cd_ss_hetp_4
      t.float :cd_ss_height_4
      t.float :cd_ss_diameter_4
      t.float :cd_ss_section_dp_4
      t.string :cd_ss_description_5
      t.string :cd_ss_tray_type_5
      t.integer :cd_ss_tcount_5
      t.float :cd_ss_tspacing_5
      t.string :cd_ss_hetp_5
      t.float :cd_ss_height_5
      t.float :cd_ss_diameter_5
      t.float :cd_ss_section_dp_5
      t.string :cd_ss_description_6
      t.string :cd_ss_tray_type_6
      t.integer :cd_ss_tcount_6
      t.float :cd_ss_tspacing_6
      t.string :cd_ss_hetp_6
      t.float :cd_ss_height_6
      t.float :cd_ss_diameter_6
      t.float :cd_ss_section_dp_6

      t.string :cd_cs_column_sections
      t.string :cd_cs_column_sections_text

      t.float :cd_top_vapor_disengagement_space
      t.float :cd_bottom_liquid_reservoir_space
      t.float :cd_feed_draw_nozzle_allowance
      t.float :cd_additional_height_factor
      t.float :cd_trayed_section_height
      t.float :cd_column_height

      t.string :cd_bottom_stream
      t.float :cd_bottom_product_rate
      t.float :cd_bottom_density
      t.float :cd_bottom_column_diameter
      t.float :cd_resident_time
      t.float :cd_max_liquid_level
      t.float :cd_static_pressure

      #TODO need review fields
      t.string :cd_mcs_basis
      t.float :cd_mcs_light_key_component
      t.float :cd_mcs_heavy_key_component
      t.float :cd_mcs_relative_volatility_top
      t.float :cd_mcs_relative_volatility_feed
      t.float :cd_mcs_relative_volatility_bottom
      t.float :cd_mcs_moles_of_lk_in_distillate
      t.float :cd_mcs_moles_of_lk_in_bottoms
      t.float :cd_mcs_moles_of_hk_in_distillate
      t.float :cd_mcs_moles_of_hk_in_bottoms
      t.float :cd_mcs_separation_factor
      t.float :cd_mcs_mean_relative_volatility
      t.float :cd_mcs_minimum_stages
      t.boolean :cd_mcs_includes_partial_condenser
      t.boolean :cd_mcs_includes_partial_reboiler

      t.string :cd_mrr_component_count
      t.float :cd_mrr_liquid_mole_fraction_of_feed
      t.float :cd_mrr_theta
      t.float :cd_mrr_minimum_reflux_ratio

      t.boolean :cd_osr_exclude_reboiler
      t.boolean :cd_osr_exclude_condenser
      t.string :cd_osr_correlations

      t.float :cd_win_equilibrium_k_value_light_key
      t.float :cd_win_equilibrium_k_value_heavy_key
      t.float :cd_win_exponential_b
      t.float :cd_win_bottom_product_rate_b
      t.float :cd_win_distillate_product_rate_d
      t.float :cd_win_minimum_stages

      t.float :cd_em_lov1
      t.float :cd_em_lov1_min
      t.float :cd_em_smin

      t.float :cd_nt_light_key_component
      t.float :cd_nt_heavy_key_component
      t.float :cd_nt_total_number_of_stages
      t.float :cd_nt_mole_fraction_of_hk_in_feed
      t.float :cd_nt_mole_fraction_of_lk_in_feed
      t.float :cd_nt_moles_fraction_of_lk_in_bottom
      t.float :cd_nt_moles_fraction_of_hk_in_distillate
      t.float :cd_nt_molar_flow_of_distillate
      t.float :cd_nt_molar_flow_of_bottoms
      t.float :cd_nt_nr_ns
      t.float :cd_nt_no_of_tray_above_feed
      t.float :cd_nt_no_of_tray_below_feed

      t.float :cd_cpe_avg_column_t
      t.float :cd_cpe_feed_viscosity
      t.float :cd_cpe_avg_volatility
      t.float :cd_cpe_relative_volatility
      t.float :cd_cpe_plate_efficiency



      t.string :c_design_code
      t.string :c_stamped
      t.float :c_min_pressure_vessel_design_press
      t.float :c_normal_operating_pressure
      t.float :c_normal_operating_temperature
      t.float :c_maximum_operating_pressure
      t.float :c_maximum_operating_temperature
      t.float :c_max_possible_supply_pressure_to_vessel
      t.boolean :c_relief_to_collection_header_system
      t.float :c_collection_system_back_pressure
      t.string :c_relief_device_type
      t.float :c_max_vacuum_pressure
      t.float :c_atmospheric_pressure
      t.float :c_max_temp_relief_press
      t.float :c_minimum_operating_temp
      t.float :c_minimum_amb_design_temp
      t.boolean :c_equipment_subject_to_steam_out
      t.boolean :c_equipment_subject_to_dry_out
      t.float :c_design_pressure
      t.float :c_design_temperature
      t.float :c_design_vacuum
      t.float :c_minimum_design_temperature
      t.float :c_test_pressure

      t.float :cdt_tc_design_pressure
      t.float :cdt_tc_design_temperature
      t.float :cdt_tc_minimum_temperature
      t.float :cdt_tc_material_of_construction
      t.float :cdt_tc_allowable_stress
      t.float :cdt_tc_shell_corrosion_allowance
      t.string :cdt_tc_head_type
      t.float :cdt_tc_head_corrosion_allowance
      t.float :cdt_tc_head_joint_efficiency
      t.float :cdt_tc_straight_flange
      t.float :cdt_tc_shell_thickness
      t.float :cdt_tc_head_thickness
      t.float :cdt_tc_shell_id
      t.float :cdt_bc_design_pressure
      t.float :cdt_bc_design_temperature
      t.float :cdt_bc_minimum_temperature
      t.float :cdt_bc_material_of_construction
      t.float :cdt_bc_allowable_stress
      t.float :cdt_bc_shell_corrosion_allowance
      t.string :cdt_bc_head_type
      t.float :cdt_bc_head_corrosion_allowance
      t.float :cdt_bc_head_joint_efficiency
      t.float :cdt_bc_straight_flange
      t.float :cdt_bc_shell_thickness
      t.float :cdt_bc_head_thickness
      t.float :cdt_bc_shell_id
      t.float :cdt_vessel_material_density
      t.float :cdt_vessel_weight_allowance
      t.float :cdt_vessel_content_density
      t.float :cdt_weight_empty_vessel
      t.float :cdt_weight_full_vessel

      #review
      t.string :sizing_review_tower_1, :limit => 3
      t.string :sizing_review_tower_2, :limit => 3
      t.string :sizing_review_tower_3, :limit => 3
      t.string :sizing_review_tower_4, :limit => 3
      t.string :sizing_review_tower_5, :limit => 3
      t.string :sizing_review_tower_6, :limit => 3
      t.string :sizing_review_tower_7, :limit => 3
      t.string :sizing_review_tower_8, :limit => 3
      t.string :sizing_review_tower_9, :limit => 3
      t.string :sizing_review_tower_10, :limit => 3
      t.string :sizing_review_tower_11, :limit => 3
      t.string :sizing_review_tower_12, :limit => 3
      t.string :sizing_review_tower_13, :limit => 3
      t.string :sizing_review_tower_14, :limit => 3

      t.string :sizing_review_tray_tower_1, :limit => 3
      t.string :sizing_review_tray_tower_2, :limit => 3
      t.string :sizing_review_tray_tower_3, :limit => 3
      t.string :sizing_review_tray_tower_4, :limit => 3
      t.string :sizing_review_tray_tower_5, :limit => 3
      t.string :sizing_review_tray_tower_6, :limit => 3
      t.string :sizing_review_tray_tower_7, :limit => 3
      t.string :sizing_review_tray_tower_8, :limit => 3

      t.string :sizing_review_packed_tower_1, :limit => 3
      t.string :sizing_review_packed_tower_2, :limit => 3
      t.string :sizing_review_packed_tower_3, :limit => 3
      t.string :sizing_review_packed_tower_4, :limit => 3
      t.string :sizing_review_packed_tower_5, :limit => 3
      t.string :sizing_review_packed_tower_6, :limit => 3
      t.string :sizing_review_packed_tower_7, :limit => 3
      t.string :sizing_review_packed_tower_8, :limit => 3
      t.string :sizing_review_packed_tower_9, :limit => 3
      t.string :sizing_review_packed_tower_10, :limit => 3

      t.string :review_notes

      #popups
      #reboiler type
      t.string :sd_rt_fluid_characteristics
      t.string :sd_rt_extent_of_fouling
      t.string :sd_rt_viscosity
      t.string :sd_rt_pressure
      t.string :sd_rt_area_required
      t.string :sd_rt_available_reboiler_types

      #column type
      t.boolean :sd_ct_chk_box_1
      t.boolean :sd_ct_chk_box_2
      t.boolean :sd_ct_chk_box_3
      t.boolean :sd_ct_chk_box_4
      t.boolean :sd_ct_chk_box_5
      t.boolean :sd_ct_chk_box_6
      t.boolean :sd_ct_chk_box_7
      t.boolean :sd_ct_chk_box_8
      t.boolean :sd_ct_chk_box_9
      t.boolean :sd_ct_chk_box_10
      t.boolean :sd_ct_chk_box_11
      t.boolean :sd_ct_chk_box_12
      t.boolean :sd_ct_chk_box_13
      t.string :sd_ct_column_type_selected, :limit => 20

      #condenser type
      t.string :sd_cont_cooling_medium, :limit => 13
      t.string :sd_cont_main_condenser_type, :limit => 21
      t.string :sd_cont_trim_condensing, :limit => 3

      #column section height
      t.integer :csh_no_of_sections
      t.float :csh_top_diameter
      t.float :csh_top_height
      t.float :csh_top_surface_area
      t.float :csh_top_volume
      t.float :csh_tz_1_diameter
      t.float :csh_tz_1_height
      t.float :csh_tz_1_surface_area
      t.float :csh_tz_1_volume
      t.float :csh_section_1_diameter
      t.float :csh_section_1_height
      t.float :csh_section_1_surface_area
      t.float :csh_section_1_volume
      t.float :csh_tz_2_diameter
      t.float :csh_tz_2_height
      t.float :csh_tz_2_surface_area
      t.float :csh_tz_2_volume
      t.float :csh_section_2_diameter
      t.float :csh_section_2_height
      t.float :csh_section_2_surface_area
      t.float :csh_section_2_volume
      t.float :csh_tz_3_diameter
      t.float :csh_tz_3_height
      t.float :csh_tz_3_surface_area
      t.float :csh_tz_3_volume
      t.float :csh_section_3_diameter
      t.float :csh_section_3_height
      t.float :csh_section_3_surface_area
      t.float :csh_section_3_volume
      t.float :csh_tz_4_diameter
      t.float :csh_tz_4_height
      t.float :csh_tz_4_surface_area
      t.float :csh_tz_4_volume
      t.float :csh_section_4_diameter
      t.float :csh_section_4_height
      t.float :csh_section_4_surface_area
      t.float :csh_section_4_volume
      t.float :csh_tz_5_diameter
      t.float :csh_tz_5_height
      t.float :csh_tz_5_surface_area
      t.float :csh_tz_5_volume
      t.float :csh_section_5_diameter
      t.float :csh_section_5_height
      t.float :csh_section_5_surface_area
      t.float :csh_section_5_volume
      t.float :csh_tz_6_diameter
      t.float :csh_tz_6_height
      t.float :csh_tz_6_surface_area
      t.float :csh_tz_6_volume
      t.float :csh_bottom_diameter
      t.float :csh_bottom_height
      t.float :csh_bottom_surface_area
      t.float :csh_bottom_volume
      t.float :csh_total

      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :column_sizings
  end
end
