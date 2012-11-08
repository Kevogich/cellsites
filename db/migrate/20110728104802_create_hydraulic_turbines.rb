class CreateHydraulicTurbines < ActiveRecord::Migration
  def self.up
    create_table :hydraulic_turbines do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
     
      t.string :driver_type
      t.string :hydraulic_turbine_tag
      
      #suction
      t.integer :su_process_basis_id
      t.string  :su_suction_condition_basis 
      
      t.string :su_max_stream_no
      t.float :su_max_pressure, :limit => 53
      t.float :su_max_temperature, :limit => 53
      t.float :su_max_mass_vapor_fraction, :limit => 53
      t.float :su_max_mass_flow_rate, :limit => 53
      t.float :su_max_density, :limit => 53
      t.float :su_max_viscosity, :limit => 53
      t.float :su_max_vapor_pressure, :limit => 53
      
      t.string :su_nor_stream_no
      t.float :su_nor_pressure, :limit => 53
      t.float :su_nor_temperature, :limit => 53
      t.float :su_nor_mass_vapor_fraction, :limit => 53
      t.float :su_nor_mass_flow_rate, :limit => 53
      t.float :su_nor_density, :limit => 53
      t.float :su_nor_viscosity, :limit => 53
      t.float :su_nor_vapor_pressure, :limit => 53
      
      t.string :su_min_stream_no
      t.float :su_min_pressure, :limit => 53
      t.float :su_min_temperature, :limit => 53
      t.float :su_min_mass_vapor_fraction, :limit => 53
      t.float :su_min_mass_flow_rate, :limit => 53
      t.float :su_min_density, :limit => 53
      t.float :su_min_viscosity, :limit => 53
      t.float :su_min_vapor_pressure, :limit => 53
      
      t.float :su_fitting_dp_min, :limit => 53
      t.float :su_equipment_dp_min, :limit => 53
      t.float :su_control_valve_dp_min, :limit => 53
      t.float :su_orifice_dp_min, :limit => 53 
      t.float :su_total_suction_dp_min, :limit => 53
      t.float :su_pressure_at_suction_nozzle_min, :limit => 53
      t.float :su_max_upstream_pressure_min, :limit => 53
      t.float :su_max_pressure_at_suction_nozzle_min, :limit => 53
      
      t.float :su_fitting_dp_nor, :limit => 53
      t.float :su_equipment_dp_nor, :limit => 53
      t.float :su_control_valve_dp_nor, :limit => 53
      t.float :su_orifice_dp_nor, :limit => 53 
      t.float :su_total_suction_dp_nor, :limit => 53
      t.float :su_pressure_at_suction_nozzle_nor, :limit => 53
      t.float :su_max_upstream_pressure_nor, :limit => 53
      t.float :su_max_pressure_at_suction_nozzle_nor, :limit => 53
      
      t.float :su_fitting_dp_max, :limit => 53
      t.float :su_equipment_dp_max, :limit => 53
      t.float :su_control_valve_dp_max, :limit => 53
      t.float :su_orifice_dp_max, :limit => 53 
      t.float :su_total_suction_dp_max, :limit => 53
      t.float :su_pressure_at_suction_nozzle_max, :limit => 53
      t.float :su_max_upstream_pressure_max, :limit => 53
      t.float :su_max_pressure_at_suction_nozzle_max, :limit => 53
      
      #discharge      
      t.string  :dc_discharge_condition_basis 
      
      #hydraulic turbine design
      t.string :htd_red_equipment_type
      t.string :htd_red_equipment_tag
      t.float :htd_red_capacity, :limit => 53
      t.float :htd_red_differential_pressure, :limit => 53
      t.float :htd_red_horsepower, :limit => 53
      t.float :htd_red_speed, :limit => 53
      
      t.float :htd_td_pressure_at_suction_nozzle_min, :limit => 53
      t.float :htd_td_pressure_at_discharge_nozzle_min, :limit => 53
      t.float :htd_td_differential_pressure_min, :limit => 53
      t.float :htd_td_differential_head_min, :limit => 53
      t.float :htd_tap_flow_rate_min, :limit => 53
      t.float :htd_tap_sg_min, :limit => 53
      t.float :htd_tap_hydraulic_hp_min, :limit => 53
      t.float :htd_tap_efficiency_min, :limit => 53
      t.float :htd_tap_brake_horsepower_min, :limit => 53
      t.float :htd_pb_brake_horsepower_min, :limit => 53
      
      t.float :htd_td_pressure_at_suction_nozzle_nor, :limit => 53
      t.float :htd_td_pressure_at_discharge_nozzle_nor, :limit => 53
      t.float :htd_td_differential_pressure_nor, :limit => 53
      t.float :htd_td_differential_head_nor, :limit => 53
      t.float :htd_tap_flow_rate_nor, :limit => 53
      t.float :htd_tap_sg_nor, :limit => 53
      t.float :htd_tap_hydraulic_hp_nor, :limit => 53
      t.float :htd_tap_efficiency_nor, :limit => 53
      t.float :htd_tap_brake_horsepower_nor, :limit => 53
      t.float :htd_pb_brake_horsepower_nor, :limit => 53
      
      t.float :htd_td_pressure_at_suction_nozzle_max, :limit => 53
      t.float :htd_td_pressure_at_discharge_nozzle_max, :limit => 53
      t.float :htd_td_differential_pressure_max, :limit => 53
      t.float :htd_td_differential_head_max, :limit => 53
      t.float :htd_tap_flow_rate_max, :limit => 53
      t.float :htd_tap_sg_max, :limit => 53
      t.float :htd_tap_hydraulic_hp_max, :limit => 53
      t.float :htd_tap_efficiency_max, :limit => 53
      t.float :htd_tap_brake_horsepower_max, :limit => 53
      t.float :htd_pb_brake_horsepower_max, :limit => 53
      
      #Heuristics Review
      t.string :ht_sizing_review_1
      t.string :ht_sizing_review_2
      t.string :ht_sizing_review_3
      t.string :ht_sizing_review_4
      t.string :ht_sizing_review_5
      t.string :ht_sizing_review_6
      t.string :ht_sizing_review_7
      t.string :ht_notes
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :hydraulic_turbines
  end
end
