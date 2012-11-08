class CreateColumnTraySpecifications < ActiveRecord::Migration
  def self.up
    create_table :column_tray_specifications do |t|
      t.integer :column_sizing_id

      t.string :zd_section_description
      t.integer :zd_tray_numbers
      t.integer :zd_tray_count

      t.float :vl_mass_flow_rate
      t.float :vl_temperature
      t.float :vl_pressure
      t.float :vl_density
      t.float :vl_molecular_weight
      t.float :vl_compressibility

      t.float :ll_mass_flow_rate
      t.float :ll_temperature
      t.float :ll_surface_tension
      t.float :ll_viscosity

      t.string :td_type_of_trays
      t.string :td_tray_manufacturer
      t.string :td_tray_model
      t.string :td_tray_spacing
      t.integer :td_no_of_passes
      t.string :td_tray_foaming_tendency
      t.float :td_max_rate_as_of_design
      t.float :td_min_rate_as_of_design
      t.float :td_design_rate_as_flood_rate
      t.string :td_tray_material
      t.string :td_valve_cap_material
      t.float :td_corrosion_allowance
      t.float :td_tray_thickness
      t.float :td_tray_diameter
      t.float :td_section_height
      t.float :td_pressure_drop_per_tray

      t.string :bd_packing_type
      t.string :bd_packing_manufacture
      t.string :bd_packing_material
      t.string :bd_random_packing_type
      t.integer :bd_random_packing_size
      t.float :bd_packing_factor
      t.float :bd_height_of_theoretical_plate
      t.float :bd_height_of_transfer_unit
      t.float :bd_tower_diameter
      t.float :bd_pressure_drop_per_ft_of_packing
      t.float :bd_bed_height

      t.timestamps
    end
  end

  def self.down
    drop_table :column_tray_specifications
  end
end
