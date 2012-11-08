class AddLowPressureTankTagToReliefDeviceSizings < ActiveRecord::Migration
  def self.up
    add_column :relief_device_sizings, :low_pressure_tank_tag, :string
    add_column :relief_device_sizings, :low_pressure_tank_code, :string
    add_column :relief_device_sizings, :low_pressure_pressure_rating, :string
    add_column :relief_device_sizings, :low_pressure_vacuum_rating, :string
    add_column :relief_device_sizings, :low_pressure_set_pressure, :string
    add_column :relief_device_sizings, :low_pressure_set_vacuum, :string
    add_column :relief_device_sizings, :low_pressure_flashpoint_temp, :string
    add_column :relief_device_sizings, :low_pressure_fluid_temp, :string
    add_column :relief_device_sizings, :low_pressure_flashpoint, :string
    add_column :relief_device_sizings, :low_pressure_heatedtank, :string
    add_column :relief_device_sizings, :low_pressure_tankcapacity, :string
    add_column :relief_device_sizings, :low_pressure_crudeoilstorage, :string
    add_column :relief_device_sizings, :low_pressure_highviscousfluid, :string
    add_column :relief_device_sizings, :low_pressure_frangibleroof, :string
    add_column :relief_device_sizings, :low_pressure_operatingpressure, :string
    add_column :relief_device_sizings, :low_pressure_emissionstandards, :string
    add_column :relief_device_sizings, :low_pressure_fluidmw, :string
    add_column :relief_device_sizings, :low_pressure_dischargelocation, :string
    add_column :relief_device_sizings, :low_pressure_conservation_venttype, :string
    add_column :relief_device_sizings, :low_pressure_emergency_venttype, :string
    add_column :relief_device_sizings, :low_pressure_pipematerial, :string
    add_column :relief_device_sizings, :low_pressure_piperoughness, :string
  end

  def self.down
    remove_column :relief_device_sizings, :low_pressure_tank_tag
    remove_column :relief_device_sizings, :low_pressure_tank_code
    remove_column :relief_device_sizings, :low_pressure_pressure_rating
    remove_column :relief_device_sizings, :low_pressure_vacuum_rating
    remove_column :relief_device_sizings, :low_pressure_set_pressure
    remove_column :relief_device_sizings, :low_pressure_set_vacuum
    remove_column :relief_device_sizings, :low_pressure_flashpoint_temp
    remove_column :relief_device_sizings, :low_pressure_fluid_temp
    remove_column :relief_device_sizings, :low_pressure_flashpoint
    remove_column :relief_device_sizings, :low_pressure_heatedtank
    remove_column :relief_device_sizings, :low_pressure_tankcapacity
    remove_column :relief_device_sizings, :low_pressure_crudeoilstorage
    remove_column :relief_device_sizings, :low_pressure_highviscousfluid
    remove_column :relief_device_sizings, :low_pressure_frangibleroof
    remove_column :relief_device_sizings, :low_pressure_operatingpressure
    remove_column :relief_device_sizings, :low_pressure_emissionstandards
    remove_column :relief_device_sizings, :low_pressure_fluidmw
    remove_column :relief_device_sizings, :low_pressure_dischargelocation
    remove_column :relief_device_sizings, :low_pressure_conservation_venttype
    remove_column :relief_device_sizings, :low_pressure_emergency_venttype
    remove_column :relief_device_sizings, :low_pressure_pipematerial
    remove_column :relief_device_sizings, :low_pressure_piperoughness
  end
end
