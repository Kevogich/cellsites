class CreatePumpSizings < ActiveRecord::Migration
  def self.up
    create_table :pump_sizings do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :centrifugal_pump_tag
      
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
      
      t.float :su_density, :limit => 53
      t.float :su_viscosity, :limit => 53
      t.float :su_specific_heat_capacity, :limit => 53
      t.float :su_vapor_pressure, :limit => 53
      t.float :su_critical_pressure, :limit => 53
      t.float :su_total_suction_dP, :limit => 53
      t.float :su_pressure_at_suction_nozzle, :limit => 53
      t.float :su_max_upstream_pressure, :limit => 53
      t.float :su_max_pressure_at_suction_nozzle, :limit => 53
     
      #discharge
            
      #centrifugal design
      t.float :cd_press_at_suction_nozzle, :limit => 53
      t.float :cd_press_at_discharge_nozzle, :limit => 53
      t.float :cd_differential_pressure, :limit => 53
      t.float :cd_differential_head, :limit => 53
      t.float :cd_safety_factor, :limit => 53
      t.float :cd_required_differential_head, :limit => 53
      t.float :cd_shut_off_factor, :limit => 53
      t.float :cd_shut_off_head, :limit => 53
      t.float :cd_max_suction_pressure, :limit => 53
      t.float :cd_shut_off_pressure, :limit => 53
      t.float :cd_np_press_at_suction_nozzle, :limit => 53
      t.float :cd_vapor_pressure, :limit => 53
      t.float :cd_npsha, :limit => 53
      t.boolean :cd_compressible_liquid, :limit => 53
      t.float :cd_temp_at_discharge_nozzle, :limit => 53
      t.float :cd_density_at_discharge_nozzle, :limit => 53
      t.float :cd_required_compression_head, :limit => 53
      t.float :cd_flow_rate, :limit => 53
      t.float :cd_s_g, :limit => 53
      t.float :cd_hydraulic_hp, :limit => 53
      t.float :cd_efficiency, :limit => 53
      t.float :cd_brake_horsepower, :limit => 53
      
      #reciprocating design
      t.string :rd_manufacturer
      t.string :rd_model_size
      t.integer :rd_no_of_cylinders
      t.string :rd_type
      t.float :rd_bore, :limit => 53
      t.float :rd_stroke, :limit => 53
      t.float :rd_rod_diameter, :limit => 53
      t.float :rd_piston_speed, :limit => 53
      t.float :rd_leakage_factor_s, :limit => 53
      t.float :rd_volume_ratio_r, :limit => 53
      t.boolean :rd_compressible_liquid
      t.float :rd_temp_at_discharge_nozzle, :limit => 53
      t.float :rd_density_at_discharge_nozzle, :limit => 53
      t.float :rd_compression_head, :limit => 53
      t.float :rd_press_at_suction_nozzle, :limit =>53
      t.float :rd_press_at_discharge_nozzle, :limit => 53
      t.float :rd_vapor_pressure, :limit => 53
      t.float :rd_acceleration_head, :limit => 53
      t.float :rd_npsha, :limit => 53
      t.float :rd_differential_pressure, :limit => 53
      t.float :rd_differential_head, :limit => 53
      t.float :rd_piston_displacement, :limit => 53
      t.float :rd_volumetric_efficiency, :limit => 53
      t.float :rd_rated_discharge_capacity, :limit => 53
      t.float :rd_hydraulic_hp, :limit => 53
      t.float :rd_mechanical_efficiency, :limit => 53
      t.float :rd_brake_horsepower, :limit => 53
      
      #Liquid Acceleration Head
      t.float :rd_liquid_capacity, :limit => 53
      t.float :rd_length_of_suction_pipe, :limit => 53
      t.string :rd_diameter_of_suction_pipe
      t.float :rd_speed_of_rotation, :limit => 53
      t.string :rd_pump_type
      t.float :rd_c, :limit => 53
      t.string :rd_fluid_service_type
      t.float :rd_k, :limit => 53
      t.float :rd_velocity, :limit => 53
      t.float :rd_head, :limit => 53
      
      #Pump Curve
      t.string :pc_manufacturer
      t.string :pc_model
      t.string :pc_curve_no
      t.string :pc_impeller_1
      t.string :pc_impeller_2
      t.string :pc_impeller_3
      t.string :pc_impeller_4
            
      #CV summary
      
      #FE summary
      
      #Pump Heuristics Validation
      t.string :ph_sizing_review_1
      t.string :ph_sizing_review_2
      t.string :ph_sizing_review_3
      t.string :ph_sizing_review_4
      t.string :ph_sizing_review_5
      t.string :ph_sizing_review_6
      t.string :ph_sizing_review_7
      t.string :ph_notes
      
      t.integer :created_by
      t.integer :updated_by      

      t.timestamps
    end
  end

  def self.down
    drop_table :pump_sizings
  end
end
