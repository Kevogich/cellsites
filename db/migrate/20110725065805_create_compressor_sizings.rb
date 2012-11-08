class CreateCompressorSizings < ActiveRecord::Migration
  def self.up
    create_table :compressor_sizings do |t|
      
      t.integer :compressor_sizing_tag_id
      t.integer :compressor_sizing_mode_id
      t.boolean :selected_sizing
      
      #suction
      t.integer :process_basis_id
      t.string :su_stream_no
      t.float :su_pressure, :limit => 53
      t.float :su_temperature, :limit => 53
      t.float :su_mass_vapor_fraction, :limit => 53
      t.float :su_mass_flow_rate, :limit => 53      
      t.float :su_fitting_dP, :limit => 53
      t.float :su_equipment_dP, :limit => 53
      t.float :su_control_valve_dP, :limit => 53
      t.float :su_orifice_dP, :limit => 53      
      t.float :su_vapor_density, :limit => 53
      t.float :su_vapor_viscosity, :limit => 53
      t.float :su_vapor_mw, :limit => 53
      t.float :su_vapor_k, :limit => 53
      t.float :su_vapor_z, :limit => 53
      t.float :su_total_suction_dP, :limit => 53
      t.float :su_pressure_at_suction_nozzle, :limit => 53
           
      #discharge
      t.integer :dc_process_basis_id
      
      #centrifugal design
      t.string :cd_compression_path
      t.float :cd_standard_pressure, :limit => 53
      t.float :cd_standard_temperature, :limit => 53      
      t.float :cd_press_at_suction_nozzle, :limit => 53
      t.float :cd_press_at_discharge_nozzle, :limit => 53      
      t.float :cd_overall_differential_pressure, :limit => 53
      t.float :cd_overall_compression_ratio, :limit => 53
      t.float :cd_compression_ratio_per_section, :limit => 53
      t.float :cd_max_allowable_discharge_pressure, :limit => 53
           
      #reciprocation design
      t.string :rd_speed
      t.float :rd_over_efficiency, :limit => 53
      t.string :rd_compressor_lubrication
      t.float :rd_volumetric_cf, :limit => 53
      t.string :rd_gas_service
      t.float :rd_gs_volumetric_cf, :limit => 53
      t.string :rd_compression_path
      t.float :rd_standard_pressure, :limit => 53
      t.float :rd_standard_temperature, :limit => 53      
      t.float :rd_standard_compressibility, :limit => 53      
      t.float :rd_press_at_suction_nozzle, :limit => 53
      t.float :rd_press_at_discharge_nozzle, :limit => 53      
      t.float :rd_overall_differential_pressure, :limit => 53
      t.float :rd_overall_compression_ratio, :limit => 53
      t.float :rd_compression_ratio_per_section, :limit => 53
      t.float :rd_max_allowable_discharge_pressure, :limit => 53
          
      #settle out
      t.float :so_ss_total_volume, :limit => 53
      t.float :so_ss_total_moles, :limit => 53
      t.float :so_system_volume, :limit => 53
      t.float :so_system_mole, :limit => 53
      t.float :so_ds_total_volume, :limit => 53
      t.float :so_ds_total_moles, :limit => 53
      t.float :so_settle_out_pressure, :limit => 53
      t.float :so_settle_out_temperature, :limit => 53
      t.string :so_notes
      
      #Heuristics Review
      t.string :cs_sizing_review_1
      t.string :cs_sizing_review_2
      t.string :cs_sizing_review_3
      t.string :cs_sizing_review_4
      t.string :cs_sizing_review_5
      t.string :cs_sizing_review_6
      t.string :cs_sizing_review_7
      t.string :cs_sizing_review_8
      t.string :cs_sizing_review_9
      t.string :cs_sizing_review_10
      t.string :cs_sizing_review_11
      t.string :cs_sizing_review_12
      t.string :cs_notes
      
      t.integer :created_by
      t.integer :updated_by  

      t.timestamps
    end
  end

  def self.down
    drop_table :compressor_sizings
  end
end
