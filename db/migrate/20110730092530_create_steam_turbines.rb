class CreateSteamTurbines < ActiveRecord::Migration
  def self.up
    create_table :steam_turbines do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :driver_type
      t.string :steam_turbine_tag
      
      t.integer :ssc_process_basis_id
      t.boolean :ssc_mininum
      t.string :ssc_min_stream_no
      t.float :ssc_min_steam_supply_pressure, :limit => 53    
      t.float :ssc_min_steam_supply_temperature, :limit => 53
      t.float :ssc_min_steam_saturation_temperature, :limit => 53
      t.float :ssc_min_steam_density, :limit => 53
      t.float :ssc_min_steam_entropy, :limit => 53     
      t.float :ssc_min_steam_enthalpy, :limit => 53  
      t.string :ssc_steam_phase_min
      t.boolean :ssc_normal
      t.string :ssc_nor_stream_no
      t.float :ssc_nor_steam_supply_pressure, :limit => 53    
      t.float :ssc_nor_steam_supply_temperature, :limit => 53
      t.float :ssc_nor_steam_saturation_temperature, :limit => 53
      t.float :ssc_nor_steam_density, :limit => 53
      t.float :ssc_nor_steam_entropy, :limit => 53     
      t.float :ssc_nor_steam_enthalpy, :limit => 53
      t.string :ssc_steam_phase_nor
      t.boolean :ssc_maximum
      t.string :ssc_max_stream_no
      t.float :ssc_max_steam_supply_pressure, :limit => 53    
      t.float :ssc_max_steam_supply_temperature, :limit => 53
      t.float :ssc_max_steam_saturation_temperature, :limit => 53
      t.float :ssc_max_steam_density, :limit => 53
      t.float :ssc_max_steam_entropy, :limit => 53     
      t.float :ssc_max_steam_enthalpy, :limit => 53
      t.string :ssc_steam_phase_max
      
      t.boolean :sec_mininum
      t.string :sec_min_stream_no
      t.float :sec_min_steam_exhaust_pressure, :limit => 53
      t.float :sec_min_steam_exhaust_temperature, :limit => 53
      t.float :sec_min_steam_saturation_temperature, :limit => 53
      t.float :sec_min_steam_density, :limit => 53
      t.float :sec_min_steam_entropy, :limit => 53     
      t.float :sec_min_steam_enthalpy, :limit => 53
      t.float :sec_min_water_entropy, :limit => 53
      t.float :sec_min_water_enthalpy, :limit => 53
      t.string :sec_steam_phase_min
      t.boolean :sec_normal
      t.string :sec_nor_stream_no
      t.float :sec_nor_steam_exhaust_pressure, :limit => 53
      t.float :sec_nor_steam_exhaust_temperature, :limit => 53
      t.float :sec_nor_steam_saturation_temperature, :limit => 53
      t.float :sec_nor_steam_density, :limit => 53
      t.float :sec_nor_steam_entropy, :limit => 53     
      t.float :sec_nor_steam_enthalpy, :limit => 53
      t.float :sec_nor_water_entropy, :limit => 53
      t.float :sec_nor_water_enthalpy, :limit => 53
      t.string :sec_steam_phase_nor
      t.boolean :sec_maximum
      t.string :sec_max_stream_no
      t.float :sec_max_steam_exhaust_pressure, :limit => 53
      t.float :sec_max_steam_exhaust_temperature, :limit => 53
      t.float :sec_max_steam_saturation_temperature, :limit => 53
      t.float :sec_max_steam_density, :limit => 53
      t.float :sec_max_steam_entropy, :limit => 53     
      t.float :sec_max_steam_enthalpy, :limit => 53
      t.float :sec_max_water_entropy, :limit => 53
      t.float :sec_max_water_enthalpy, :limit => 53
      t.string :sec_steam_phase_max
                  
      t.string :std_equipment_type
      t.string :std_equipment_tag
      t.float :std_capacity, :limit => 53
      t.float :std_differential_pressure, :limit => 53
      t.float :std_horsepower, :limit => 53
      t.float :std_speed, :limit => 53
      t.float :std_inlet_nozzle_diameter, :limit => 53
      t.float :std_exhaust_nozzle_diameter, :limit => 53
      t.float :std_max_velocity_at_inlet_nozzle, :limit => 53
      t.float :std_max_velocity_at_exhaust_nozzle, :limit => 53
      t.float :std_isentropic_enthalpy_change, :limit => 53
      t.integer :std_approximate_no_of_stages
      t.string :std_turbine_type
      t.float :std_theoretical_steam_rate, :limit => 53
      t.float :std_efficiency, :limit => 53
      t.float :std_actual_steam_rate, :limit => 53
      t.float :std_steam_flow_rate, :limit => 53
      
      t.string :std_ee_turbine_type
      t.float :std_ee_basic_efficiency, :limit => 53
      t.float :std_ee_degree_of_superheat, :limit => 53
      t.float :std_ee_superheat_efficiency_cf, :limit => 53
      t.float :std_ee_speed_efficiency_cf, :limit => 53
      t.float :std_ee_pressure_ratio_cf, :limit => 53
      t.float :std_ee_corrected_efficiency_cf, :limit => 53
      
      t.float :std_turbine_speed, :limit => 53
      t.float :std_no_of_stages, :limit => 53
      
      #Heuristics Review
      t.string :st_sizing_review_1
      t.string :st_sizing_review_2
      t.string :st_sizing_review_3
      t.string :st_sizing_review_4
      t.string :st_sizing_review_5
      t.string :st_sizing_review_6
      t.string :st_sizing_review_7
      t.string :st_notes
      
      
      t.integer :created_by
      t.integer :updated_by      

      t.timestamps
    end
  end

  def self.down
    drop_table :steam_turbines
  end
end
