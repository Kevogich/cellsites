class CreatePressureReliefSystemDesignParameters < ActiveRecord::Migration
  def self.up
    create_table :pressure_relief_system_design_parameters do |t|
      t.integer :project_id

      t.string :workflow_mode, :limit => 50
      t.string :cvf_1, :limit => 50
      t.string :cr_1, :limit => 50
      t.string :cfc_1, :limit => 50
      t.string :ef_1, :limit => 50
      t.string :ef_2, :limit => 50
      t.string :ef_3, :limit => 50
      t.string :ef_4, :limit => 50
      t.string :ef_5, :limit => 50
      t.string :ef_6, :limit => 50
      t.string :fac_1, :limit => 50
      t.string :fac_2, :limit => 50
      t.string :hetr_1, :limit => 50
      t.string :hetr_2, :limit => 50
      t.string :of_1, :limit => 50
      t.string :rrc_cvsb, :limit => 50
      t.string :rrc_trsb, :limit => 50
      t.string :ftb_vessel_alarm, :limit => 50
      t.string :ftb_column_alarm, :limit => 50
      t.integer :ffb_vessel_response_time
      t.integer :ffb_column_response_time
      t.string :ftb_vessel_level_basis, :limit => 50
      t.string :ftb_column_level_basis, :limit => 50
      t.boolean :fb_chb_1
      t.boolean :fb_chb_2
      t.string :fb_txt_1, :limit => 50
      t.string :fb_txt_2, :limit => 50
      t.string :fb_txt_3, :limit => 50
      t.string :fb_lb, :limit => 50
      t.float :fb_txt_4, :limit => 53
      t.float :fb_txt_5, :limit => 53
      t.float :fb_txt_6, :limit => 53
      t.float :fb_connected_pipe, :limit => 53
      t.string :fb_skirts
      t.float :fb_access_openings, :limit => 53
      t.float :fb_liquid_level_on_columns, :limit => 53
      t.float :fb_wetted_liquid_area, :limit => 53
      t.float :fb_wetted_liquid_area_spherical, :limit => 53
      t.string :fb_liquid_swell_in_wetted_surface_area_calculation, :limit => 50
      t.string :fb_drainage, :limit => 50
      t.string :fb_consider_relief_device_sizing, :limit => 53
      t.float :rdsb_vdc_vapor, :limit => 53
      t.float :rdsb_vdc_liquid_non_certified, :limit => 53
      t.float :rdsb_vdc_liquid_certified, :limit => 53
      t.float :rdsb_vdc_rupture_disk, :limit => 53
      t.string :prvcfb_vapor_back_pressure, :limit => 50
      t.string :prvcfb_liquid_back_pressure, :limit => 50
      t.string :prvcfb_liquid_over_pressure, :limit => 50
      t.string :prvcfb_low_pressure_vent_pressure, :limit => 50
      t.string :prvlsd, :limit => 50
      t.float :rdbp_maximum_flow_resistance, :limit => 53
      t.float :rdbp_uncertainty_factor, :limit => 53
      t.string :rfib_hydraulic_pressure_drop_basis, :limit => 50
      t.string :rfib_compressible_flow_model, :limit => 50
      t.float :inlet_pressure_drop_criteria, :limit => 50
      t.string :outlet_pressure_drop_criteria_conventional, :limit => 50
      t.float :outlet_pressure_drop_criteria_balanced_bellows, :limit => 53
      t.float :outlet_pressure_drop_criteria_pilot_operated, :limit => 53
      t.string :pressure_relief_valve_count, :limit => 50
      t.boolean :pressure_relief_valve_count_stagger_set_pressure
      t.string :valve_body_size_selection_basis
      t.string :largest_orifice_size_to_consider, :limit => 50
      t.float :flare_header_pressure, :limit => 53
      t.float :rupture_disk_selection_basis_rd_size, :limit => 53
      t.string :rupture_disk_selection_basis_rd_size1, :limit => 50
      t.float :rd_estimated_net_flow_area, :limit => 53
      t.float :vent_line_selection_basis_rd_size, :limit => 53
      t.string :vent_line_selection_basis_rd_size1, :limit => 50
      t.float :vl_estimated_net_flow_area, :limit => 53
      t.string :frangible_roof_design_for_relief_protection
      t.string :environmental_emission_standards
      t.string :tc_consider_fire_in_temperature_design

      t.timestamps
    end
  end

  def self.down
    drop_table :pressure_relief_system_design_parameters
  end
end
