class CreateStorageTankSizings < ActiveRecord::Migration
  def self.up
    create_table :storage_tank_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :storage_tank_tag
      
      t.integer :s_process_basis_id
      t.string :s_fs_stream_no
      t.float :s_fs_pressure, :limit=>53
      t.float :s_fs_temperature, :limit=>53
      t.string :s_fs_phase
      t.float :s_fs_flow_rate, :limit=>53
      t.float :s_fs_density, :limit=>53
      t.float :s_fs_volume_flow_rate, :limit=>53
      t.string :s_es_stream_no
      t.float :s_es_pressure, :limit=>53
      t.float :s_es_temperature, :limit=>53
      t.string :s_es_phase
      t.float :s_es_flow_rate, :limit=>53
      t.float :s_es_density, :limit=>53
      t.float :s_es_volume_flow_rate, :limit=>53
      
      t.string :dc_refrigerated_design
      t.string :dc_representative_chemical
      t.float :dc_maximum_liquid_surface_temperature, :limit=>53
      t.float :dc_minimum_liquid_surface_temperature, :limit=>53
      t.float :dc_liquid_storage_temperature, :limit=>53
      t.float :dc_tvp_at_maximum_liquid_surface_temperature, :limit=>53
      t.float :dc_tvp_at_minimum_liquid_surface_temperature, :limit=>53
      t.float :dc_tvp_at_storage_temperature, :limit=>53
      t.float :dc_vacuum_vent_set_point, :limit=>53
      t.float :dc_storage_pressure, :limit=>53
      t.float :dc_design_pressure, :limit=>53
      t.float :dc_design_temperature, :limit=>53
      t.float :dc_design_vacuum_pressure, :limit=>53
      t.float :dc_vacuum_temperature, :limit=>53

      t.string :dc_fixed_roof_recommendation
      t.string :dc_floating_roof_recommendation
      t.string :dc_tank_type_recommendation
      
      t.integer :atm_bottom_to_normal_fill_level
      t.integer :atm_nfl_to_safe_fill_level
      t.integer :atm_sfl_to_over_fill_level
      t.integer :atm_vapor_space_capacity_above_maximum_level
      t.float :atm_normal_capacity, :limit=>53
      t.float :atm_rated_capacity, :limit=>53
      t.float :atm_maximum_capacity, :limit=>53
      t.float :atm_nominal_diameter, :limit=>53
      t.float :atm_normal_fill_level, :limit=>53
      t.integer :atm_normal_fill_level_percent
      t.float :atm_safe_fill_level, :limit=>53
      t.integer :atm_safe_fill_level_percent
      t.float :atm_over_fill_level, :limit=>53
      t.integer :atm_over_fill_level_percent
      t.float :atm_available_vapor_space, :limit=>53
      t.integer :atm_available_vapor_space_percent
      t.float :atm_calculated_height, :limit=>53
      t.float :atm_nominal_height, :limit=>53      
      t.string :atm_capacity_basis
      t.string :atm_storage_tank_type
      t.string :atm_design_codes
      t.string :atm_frangible_roof
      t.string :atm_vapor_recovery_system
      
      t.string :atm_tank_type_recommendation

      t.string :ps_storage_tank_type
      t.string :ps_capacity_basis
      t.string :ps_design_codes
      t.integer :ps_bottom_to_normal_fill_level
      t.integer :ps_nfl_to_maximum_level
      t.integer :ps_vpc_above_maximum_level
      t.float :ps_normal_capacity, :limit => 53
      t.float :ps_maximum_capacity, :limit => 53
      t.float :ps_nominal_length, :limit => 53
      t.float :ps_nominal_depth, :limit => 53
      t.float :ps_normal_fill_level, :limit=>53      
      t.float :ps_normal_fill_level_percent      
      t.float :ps_over_fill_level, :limit=>53
      t.float :ps_over_fill_level_percent
      t.float :ps_available_vapor_space, :limit=>53
      t.float :ps_available_vapor_space_percent
      t.float :ps_calculated_diameter, :limit=>53
      t.float :ps_nominal_diameter, :limit=>53
      
      t.string :md_tank_type
      t.string :md_tank_orientation
      t.string :md_material_of_contruction
      t.float :md_allowable_design_stress, :limit=>53
      t.float :md_shell_corrosion_allowance, :limit=>53
      t.string :md_head_type
      t.string :md_head_corrosion_allowance
      t.float :md_head_joint_efficiency, :limit=>53
      t.float :md_straight_flange, :limit=>53
      t.float :md_tank_material_density, :limit=>53
      t.float :md_tank_weight_allowance, :limit=>53
      t.float :md_tank_content_density, :limit=>53
      t.float :md_bottom_corrosion_allowance, :limit=>53
      t.float :md_allowable_test_stress, :limit=>53
      t.string :md_design_code
      t.float :md_design_pressure, :limit=>53
      t.float :md_design_temperature, :limit=>53
      t.float :md_minimum_temperature, :limit=>53
      t.float :md_hydrotest_pressure, :limit=>53
      t.float :md_shell_diameter, :limit=>53
      t.float :md_shell_length, :limit=>53
      t.float :md_liquid_level, :limit=>53
      t.float :md_maximum_capacity, :limit=>53
      t.float :md_nominal_shell_thickness, :limit=>53
      t.float :md_nominal_head_thickness, :limit=>53
      t.float :md_weight_empty_vessel, :limit=>53
      t.float :md_weight_full_vessel, :limit=>53
      t.float :md_nominal_bottom_thickness, :limit=>53
      
      #ATM/Low Pressure Storage Standardize
      t.float :atm_standard_nominal_diameter, :limit=>53
      t.float :atm_standard_selected_height, :limit=>53
      t.float :atm_standard_normal_fill_level, :limit=>53
      t.float :atm_standard_save_fill_level, :limit=>53
      t.float :atm_standard_overfill_level, :limit=>53
      t.float :atm_standard_available_vapor_space, :limit=>53
      t.float :atm_standard_freeboard, :limit=>53
      
      #Pressure Storage Standardize
      t.float :ps_standard_nominal_length, :limit=>53
      t.float :ps_standard_nominal_depth, :limit=>53
      t.float :ps_standard_selected_diameter, :limit=>53
      t.float :ps_standard_normal_fill_level, :limit=>53
      t.float :ps_standard_save_fill_level, :limit=>53
      t.float :ps_standard_overfill_level, :limit=>53
      t.float :ps_standard_available_vapor_space, :limit=>53
      t.float :ps_standard_freeboard, :limit=>53

      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :storage_tank_sizings
  end
end
