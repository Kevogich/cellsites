class CreateTurboExpanders < ActiveRecord::Migration
  def self.up
    create_table :turbo_expanders do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :driver_type
      t.string :turbo_expander_tag
      
      t.integer :sic_process_basis_id
      t.boolean :sic_mininum
      t.string :sic_min_stream_no
      t.float :sic_min_stream_inlet_pressure, :limit => 53
      t.float :sic_min_stream_inlet_temperature, :limit => 53
      t.float :sic_min_stream_mass_vapor_fraction, :limit => 53
      t.float :sic_min_stream_saturation_temperature, :limit => 53
      t.float :sic_min_stream_flowrate, :limit => 53
      t.float :sic_min_stream_density, :limit => 53
      t.float :sic_min_stream_entropy, :limit => 53
      t.float :sic_min_stream_enthalpy, :limit => 53
      t.string :sic_steam_phase_min      
      t.boolean :sic_normal
      t.string :sic_nor_stream_no
      t.float :sic_nor_stream_inlet_pressure, :limit => 53
      t.float :sic_nor_stream_inlet_temperature, :limit => 53
      t.float :sic_nor_stream_mass_vapor_fraction, :limit => 53
      t.float :sic_nor_stream_saturation_temperature, :limit => 53
      t.float :sic_nor_stream_flowrate, :limit => 53
      t.float :sic_nor_stream_density, :limit => 53
      t.float :sic_nor_stream_entropy, :limit => 53
      t.float :sic_nor_stream_enthalpy, :limit => 53
      t.string :sic_steam_phase_nor
      t.boolean :sic_maximum
      t.string :sic_max_stream_no
      t.float :sic_max_stream_inlet_pressure, :limit => 53
      t.float :sic_max_stream_inlet_temperature, :limit => 53
      t.float :sic_max_stream_mass_vapor_fraction, :limit => 53
      t.float :sic_max_stream_saturation_temperature, :limit => 53
      t.float :sic_max_stream_flowrate, :limit => 53
      t.float :sic_max_stream_density, :limit => 53
      t.float :sic_max_stream_entropy, :limit => 53
      t.float :sic_max_stream_enthalpy, :limit => 53
      t.string :sic_steam_phase_max
      
      t.boolean :soc_mininum
      t.string :soc_min_stream_no
      t.float :soc_min_outlet_pressure, :limit => 53
      t.float :soc_min_outlet_temperature, :limit => 53
      t.float :soc_min_stream_saturation_temperature, :limit => 53
      t.float :soc_min_stream_mass_fraction, :limit => 53
      t.float :soc_min_stream_density, :limit => 53
      t.float :soc_min_stream_entropy, :limit => 53
      t.float :soc_min_stream_enthalpy, :limit => 53
      t.float :soc_min_stream_vapor_entropy, :limit => 53
      t.float :soc_min_stream_vapor_enthalpy, :limit => 53
      t.float :soc_min_stream_liquid_entropy, :limit => 53
      t.float :soc_min_stream_liquid_enthalpy, :limit => 53
      t.string :soc_steam_phase_min
      t.boolean :soc_normal
      t.string :soc_nor_stream_no
      t.float :soc_nor_outlet_pressure, :limit => 53
      t.float :soc_nor_outlet_temperature, :limit => 53
      t.float :soc_nor_stream_saturation_temperature, :limit => 53
      t.float :soc_nor_stream_mass_fraction, :limit => 53
      t.float :soc_nor_stream_density, :limit => 53
      t.float :soc_nor_stream_entropy, :limit => 53
      t.float :soc_nor_stream_enthalpy, :limit => 53
      t.float :soc_nor_stream_vapor_entropy, :limit => 53
      t.float :soc_nor_stream_vapor_enthalpy, :limit => 53
      t.float :soc_nor_stream_liquid_entropy, :limit => 53
      t.float :soc_nor_stream_liquid_enthalpy, :limit => 53
      t.string :soc_steam_phase_nor
      t.boolean :soc_maximum
      t.string :soc_max_stream_no
      t.float :soc_max_outlet_pressure, :limit => 53
      t.float :soc_max_outlet_temperature, :limit => 53
      t.float :soc_max_stream_saturation_temperature, :limit => 53
      t.float :soc_max_stream_mass_fraction, :limit => 53
      t.float :soc_max_stream_density, :limit => 53
      t.float :soc_max_stream_entropy, :limit => 53
      t.float :soc_max_stream_enthalpy, :limit => 53
      t.float :soc_max_stream_vapor_entropy, :limit => 53
      t.float :soc_max_stream_vapor_enthalpy, :limit => 53
      t.float :soc_max_stream_liquid_entropy, :limit => 53
      t.float :soc_max_stream_liquid_enthalpy, :limit => 53
      t.string :soc_steam_phase_max
      
      t.float :ed_basis_efficiency, :limit => 53
      t.float :ed_theoretical_enthalpy_change, :limit => 53
      t.float :ed_actual_enthalpy_change, :limit => 53
      t.string :ed_stream_no
      t.float :ed_actual_outlet_temperature, :limit => 53
      t.float :ed_actual_outlet_mass_vapor_fraction, :limit => 53
      t.float :ed_actual_outlet_stream_entropy, :limit => 53
      t.float :ed_actual_outlet_stream_enthalpy, :limit => 53
      t.float :ed_basis_flow_rate, :limit => 53
      t.float :ed_work_produced, :limit => 53
      t.float :ed_horsepower_produced, :limit => 53
      t.float :ed_mechanical_losses, :limit => 53
      t.float :ed_net_horsepower, :limit => 53
      t.string :ed_equipment_type
      t.string :ed_equipment_tag
      t.float :ed_capacity, :limit => 53
      t.float :ed_differential_pressure, :limit => 53
      t.float :ed_horsepower, :limit => 53
      t.float :ed_speed, :limit => 53
      #Removed
      t.float :ed_flow_rate, :limit => 53
      t.float :ed_sg, :limit => 53
      t.float :ed_hydraulic_hp, :limit => 53
      t.float :ed_efficiency, :limit => 53
      t.float :ed_brake_horsepower, :limit => 53
      t.float :ed_pb_brake_horsepower, :limit => 53
      
      #Heuristics Review
      t.string :te_sizing_review_1
      t.string :te_sizing_review_2
      t.string :te_sizing_review_3
      t.string :te_sizing_review_4
      t.string :te_sizing_review_5
      t.string :te_sizing_review_6
      t.string :te_sizing_review_7
      t.string :te_notes      
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :turbo_expanders
  end
end
