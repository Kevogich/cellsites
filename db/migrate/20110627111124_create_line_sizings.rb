class CreateLineSizings < ActiveRecord::Migration
  def self.up
    create_table :line_sizings do |t|
      
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :line_number
      
      #stream properties
            
      t.integer :process_basis_id
      
      t.string :stream_no
      t.string :description
      t.float :pressure, :limit => 53
      t.float :vapour_fraction, :limit => 53
      t.float :temperature, :limit => 53
      t.float :flowrate, :limit => 53
            
      t.float :vapor_density, :limit => 53
      t.float :vapor_viscosity, :limit => 53
      t.float :vapor_mw, :limit => 53
      t.float :vapor_cp_cv, :limit => 53
      t.float :vapor_z, :limit => 53
      
      t.float :liquid_density, :limit => 53
      t.float :liquid_viscosity, :limit => 53
      t.float :liquid_surface_tension, :limit => 53
      t.float :liquid_mw, :limit => 53
      t.integer :downstream_vaporization_id
        
      #sizing criteria values
      t.integer :sizing_criteria_category_id
      t.integer :sizing_criteria_category_type_id
      t.integer :sizing_criteria_id
      t.float :system_equivalent_length
      t.float :system_maximum_deltaP
      t.integer :pipe_id
      t.float :pipe_roughness, :limit => 53 
      t.boolean :include_design_factor, :default => false
      t.string :dc_calculate_type
      t.string :sizing_criteria_notes
      t.string :sc_pipe_schedule
      t.string :sc_flow_regime
               
      t.float :sc_required_id, :limit => 53
      t.float :sc_proposed_id, :limit => 53
      t.float :sc_pipe_size, :limit => 53
      t.float :sc_calculated_system_dp, :limit => 53
      t.float :sc_calculated_velocity, :limit => 53
      t.float :sc_system_equivalent_length, :limit => 53
      t.float :sc_pressure_loss_percentage, :limit => 53
      t.float :sc_erosion_corrosion_index, :limit => 53
      t.float :sc_fluid_momentum, :limit => 53      
      
      #Design Conditions
      t.string :dc_source_item_type
      t.string :dc_source_item_tag
      t.float :dc_source_design_pressure, :limit => 53
      t.float :dc_source_design_temperature, :limit => 53
      t.float :dc_source_statice_frictional_dp, :limit => 53
      t.string :dc_destination_item_type
      t.string :dc_destination_item_tag
      t.float :dc_destination_design_pressure, :limit => 53
      t.float :dc_destination_design_temperature, :limit => 53
      t.float :dc_destination_statice_frictional_dp, :limit => 53
      t.string :dc_design_basis
      t.float :dc_maximum_operating_pressure, :limit => 53
      t.float :dc_maximum_operating_temperature, :limit => 53
      t.float :dc_pressure_allowance, :limit => 53
      t.float :dc_temperature_allowance, :limit => 53
      t.float :dc_design_pressure, :limit => 53
      t.float :dc_design_temperature, :limit => 53
      t.float :dc_design_vaccum, :limit => 53
      t.float :dc_min_design_temperature, :limit => 53
      t.float :dc_spt_design_perssure, :limit => 53
      t.float :dc_spt_design_temperature, :limit => 53
      t.float :dc_spt_minimum_temperature, :limit => 53
      t.float :dc_spt_material_of_construction, :limit => 53
      t.float :dc_spt_allowable_stress, :limit => 53
      t.float :dc_spt_lweld_joint_factor, :limit => 53
      t.float :dc_spt_coefficient_y, :limit => 53
      t.float :dc_spt_mechanical_thickness_allowance, :limit => 53
      t.float :dc_spt_erosion_corrosion_allowance, :limit => 53
      t.float :dc_spt_pressure_design_thickness, :limit => 53
      t.float :dc_spt_minimum_required_thickness, :limit => 53
      t.string :dc_pc_tracing
      t.float :dc_pc_design_pressure, :limit => 53
      t.float :dc_pc_design_temperature, :limit => 53
      t.string :dc_pc_material_group
      t.string :dc_pc_material_designation
      t.string :dc_pc_material_description
      t.string :dc_pc_flange_class
      t.float :dc_pc_flange_pressure_rating, :limit => 53
      t.float :dc_pc_flange_temperature_rating, :limit => 53
      t.string :dc_pc_flange_facing
      t.string :dc_pc_insulation_type
      t.string :dc_pc_insulation_material
      t.float :dc_pc_insulation_thickness, :limit => 53
      t.float :dc_pc_flange_rating_notes, :limit => 53
            
      t.string :reviewer
      t.string :approver
      t.integer :created_by
      t.integer :updated_by
      
      t.integer :version_no
      t.timestamps
    end
  end

  def self.down
    drop_table :line_sizings
  end
end
