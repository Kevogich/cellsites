class CreateElectronicDatas < ActiveRecord::Migration
  def self.up
    create_table :electronic_datas do |t|
      #General
      t.integer :item_number
      t.string :item_text
      t.integer :tag_number
      t.string :tag_text
      t.integer :equipment_number
      t.string :equipment_text
      t.integer :number_required
      t.string :number_required_text

      #Basis of Selection

      t.integer :code_asme
      t.integer :code_asme_select
      t.string :code_asme_text
      t.integer :stamp_required
      t.integer :stamp_required_select
      t.integer :comply_with_api
      t.integer :comply_with_api_select
      t.integer :fire
      t.integer :fire_select
      t.string :fire_select_text
      t.integer :rupture_disk
      t.integer :rupture_disk_select

      #Value Design

      t.integer :design_type
      t.integer :design_type_select
      t.integer :nozzle_type
      t.integer :nozzle_type_select
      t.string :nozzle_type_text
      t.integer :bonnet_type
      t.integer :bonnet_type_select
      t.integer :seat_type
      t.integer :seat_type_select
      t.integer :seat_tightness
      t.integer :seat_tightness_select
      t.string :seat_tightness_text

      #Connections

      t.integer :inlet
      t.integer :inlet_size_select
      t.integer :inlet_rating_select
      t.integer :inlet_facing_select
      t.integer :outlet
      t.integer :outlet_size_select
      t.integer :outlet_rating_select
      t.integer :outlet_facing_select

      #materails

      t.integer :body
      t.string :body_text
      t.integer :bonnet
      t.string :bonnet_text
      t.integer :seal_nozzle
      t.integer :seal_nozzle_select
      t.string :disk_text
      t.integer :reailient_seat
      t.string :reailient_seat_text
      t.integer :guide
      t.string :guide_text
      t.integer :adjusting_ring
      t.string :adjusting_ring_select
      t.string :washer_text
      t.integer :spring
      t.string :spring_text
      t.integer :bellows
      t.string :bellows_text
      t.integer :balanced_pistion
      t.string :balanced_pistion_text
      t.integer :comply_nace_mro
      t.integer :comply_nace_mro
      t.integer :internal_gasket_material
      t.string :internal_gasket_material_text

      #accessories

      t.integer :cap
      t.integer :cap_select
      t.integer :lifting_lever
      t.integer :lifting_lever_select
      t.integer :test_gag
      t.integer :test_gag_select
      t.integer :bug_screen
      t.integer :bug_screen_select

      #Services Conditions

      t.integer :fluid_and_state
      t.float :fluid_and_state_text, :limit => 53
      t.integer :required_capacity_per_value
      t.float :required_capacity_per_value_text, :limit => 53
      t.integer :mass_flux_and_basis
      t.float :mass_flux_and_basis_text, :limit => 53
      t.integer :molecular_weight_specific_gravity
      t.float :molecular_weight_specific_gravity_text, :limit => 53
      t.integer :viscosity_at_flowing_temp
      t.float :viscosity_at_flowing_temp_text, :limit => 53
      t.integer :operating_pressure
      t.float :operating_pressure_text, :limit => 53
      t.integer :set_pressure
      t.float :set_pressure_text, :limit => 53
      t.integer :blow_down
      t.float :blow_down_text, :limit => 53
      t.integer :latent_heat_of_vaporization
      t.float :latent_heat_of_vaporization_text, :limit => 53
      t.integer :operating_temperature
      t.float :operating_temperature_text, :limit => 53
      t.integer :relieving_temperature
      t.float :relieving_temperature_text, :limit => 53
      t.integer :build_up_back_pressure
      t.float :build_up_back_pressure_text, :limit => 53
      t.integer :superimposed_back_pressure
      t.float :superimposed_back_pressure_text, :limit => 53
      t.integer :cold_differential_back_pressure
      t.float :cold_differential_back_pressure_text, :limit => 53
      t.integer :allowable_over_pressure
      t.float :allowable_over_pressure_text, :limit => 53
      t.integer :compressibility_factor
      t.float :compressibility_factor_text, :limit => 53
      t.integer :ratio_of_specific_heats
      t.float :ratio_of_specific_heats_text, :limit => 53

      #sizing and selection

      t.integer :calculated_ori_fi_ce_area
      t.string :calculated_ori_fi_ce_area_text
      t.integer :selected_effective_ori_fi_ce_area
      t.string :selected_effective_ori_fi_ce_area_text
      t.integer :ori_fi_ce_designation
      t.string :ori_fi_ce_designation_text
      t.integer :manufacturer
      t.string :manufacturer_text
      t.integer :model_number
      t.string :model_number_text
      t.integer :vendor_calculation_required
      t.integer :vendor_calculation_required_select

      t.integer :datasheet_id
      t.integer :item_tag_id
      t.integer :item_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :electronic_datas
  end
end
