class StorageTankSizing < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable

  validates_presence_of :storage_tank_tag, :project_id, :process_unit_id

  after_create :save_defaults
  
  #convert values
  def convert_values(multiply_factor,project)
    #Streams
    self.s_fs_pressure = (self.s_fs_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.s_fs_temperature = project.convert_temperature(:value => self.s_fs_temperature, :subtype => "General")
    self.s_fs_flow_rate = (self.s_fs_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.s_fs_density = (self.s_fs_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.s_fs_volume_flow_rate = (self.s_fs_volume_flow_rate.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
    self.s_es_pressure = (self.s_es_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.s_es_temperature = project.convert_temperature(:value => self.s_es_temperature, :subtype => "General")
    self.s_es_flow_rate = (self.s_es_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.s_es_density = (self.s_es_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.s_es_volume_flow_rate = (self.s_es_volume_flow_rate.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
       
    #Design Conditions    
    self.dc_maximum_liquid_surface_temperature = project.convert_temperature(:value => self.dc_maximum_liquid_surface_temperature, :subtype => "General")
    self.dc_minimum_liquid_surface_temperature = project.convert_temperature(:value => self.dc_minimum_liquid_surface_temperature, :subtype => "General")
    self.dc_liquid_storage_temperature = project.convert_temperature(:value => self.dc_liquid_storage_temperature, :subtype => "General")
    self.dc_tvp_at_maximum_liquid_surface_temperature = (self.dc_tvp_at_maximum_liquid_surface_temperature.to_f * multiply_factor["Pressure"]["Absolute"].to_f) if !multiply_factor["Pressure"].nil?
    self.dc_tvp_at_minimum_liquid_surface_temperature = (self.dc_tvp_at_minimum_liquid_surface_temperature.to_f * multiply_factor["Pressure"]["Absolute"].to_f) if !multiply_factor["Pressure"].nil?
    self.dc_tvp_at_storage_temperature = (self.dc_tvp_at_storage_temperature.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.dc_vacuum_vent_set_point = (self.dc_vacuum_vent_set_point.to_f * multiply_factor["Pressure"]["Absolute"].to_f) if !multiply_factor["Pressure"].nil?
    self.dc_storage_pressure = (self.dc_storage_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.dc_design_pressure = (self.dc_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.dc_design_temperature = project.convert_temperature(:value => self.dc_design_temperature, :subtype => "General")
    self.dc_design_vacuum_pressure = (self.dc_design_vacuum_pressure.to_f * multiply_factor["Pressure"]["Absolute"].to_f) if !multiply_factor["Pressure"].nil?
    self.dc_vacuum_temperature = project.convert_temperature(:value => self.dc_vacuum_temperature, :subtype => "General")
        
    #ATM/Low Pressure Storage
    self.atm_bottom_to_normal_fill_level = (self.atm_bottom_to_normal_fill_level.to_f * multiply_factor["Time"]["Hour"].to_f) if !multiply_factor["Time"].nil?
    self.atm_nfl_to_safe_fill_level = (self.atm_nfl_to_safe_fill_level.to_f * multiply_factor["Time"]["Minute"].to_f) if !multiply_factor["Time"].nil?
    self.atm_sfl_to_over_fill_level = (self.atm_sfl_to_over_fill_level.to_f * multiply_factor["Time"]["Minute"].to_f) if !multiply_factor["Time"].nil?
    self.atm_normal_capacity = (self.atm_normal_capacity.to_f * multiply_factor["Volume"]["General"].to_f) if !multiply_factor["Volume"].nil?
    self.atm_rated_capacity = (self.atm_rated_capacity.to_f * multiply_factor["Volume"]["General"].to_f) if !multiply_factor["Volume"].nil?
    self.atm_maximum_capacity = (self.atm_maximum_capacity.to_f * multiply_factor["Volume"]["General"].to_f) if !multiply_factor["Volume"].nil?

    self.atm_nominal_diameter = (self.atm_nominal_diameter.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_normal_fill_level = (self.atm_normal_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_safe_fill_level = (self.atm_safe_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_over_fill_level = (self.atm_over_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_available_vapor_space = (self.atm_available_vapor_space.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_calculated_height = (self.atm_nominal_height.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_nominal_height = (self.atm_nominal_height.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        
    #Pressure Storage
    self.ps_bottom_to_normal_fill_level = (self.ps_bottom_to_normal_fill_level.to_f * multiply_factor["Time"]["General"].to_f) if !multiply_factor["Time"].nil?
    self.ps_nfl_to_maximum_level = (self.ps_nfl_to_maximum_level.to_f * multiply_factor["Time"]["General"].to_f) if !multiply_factor["Time"].nil?
    self.ps_normal_capacity = (self.ps_normal_capacity.to_f * multiply_factor["Volume"]["General"].to_f) if !multiply_factor["Volume"].nil?
    self.ps_maximum_capacity = (self.ps_maximum_capacity.to_f * multiply_factor["Volume"]["General"].to_f) if !multiply_factor["Volume"].nil?
    self.ps_nominal_length = (self.ps_nominal_length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_nominal_depth = (self.ps_nominal_depth.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_normal_fill_level = (self.ps_normal_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_over_fill_level = (self.ps_over_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_available_vapor_space = (self.ps_available_vapor_space.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_nominal_diameter = (self.ps_nominal_diameter.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
       
    #Mechanical Design
    self.md_allowable_design_stress = (self.md_allowable_design_stress.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.md_shell_corrosion_allowance = (self.md_shell_corrosion_allowance.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_head_corrosion_allowance = (self.md_head_corrosion_allowance.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_tank_material_density = (self.md_tank_material_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.md_tank_content_density = (self.md_tank_content_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.md_bottom_corrosion_allowance = (self.md_bottom_corrosion_allowance.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_allowable_test_stress = (self.md_allowable_test_stress.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Differential"].nil?
    self.md_design_pressure = (self.md_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.md_design_temperature = (self.md_design_temperature.to_f * multiply_factor["Temperature"]["General"].to_f) if !multiply_factor["Temperature"].nil?
    self.md_minimum_temperature = (self.md_minimum_temperature.to_f * multiply_factor["Temperature"]["General"].to_f) if !multiply_factor["Temperature"].nil?
    self.md_hydrotest_pressure = (self.md_hydrotest_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.md_shell_diameter = (self.md_shell_diameter.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_shell_length = (self.md_shell_length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_liquid_level = (self.md_liquid_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_maximum_capacity = (self.md_maximum_capacity.to_f * multiply_factor["Volume"]["General"].to_f) if !multiply_factor["Volume"].nil?
    self.md_nominal_shell_thickness = (self.md_nominal_shell_thickness.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_nominal_head_thickness = (self.md_nominal_head_thickness.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.md_weight_empty_vessel = (self.md_weight_empty_vessel.to_f * multiply_factor["Weight"]["General"].to_f) if !multiply_factor["Weight"].nil?
    self.md_weight_full_vessel = (self.md_weight_full_vessel.to_f * multiply_factor["Weight"]["General"].to_f) if !multiply_factor["Weight"].nil?
    self.md_nominal_bottom_thickness = (self.md_nominal_bottom_thickness.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?

	#ATM/Lower pressure standardize
	self.atm_standard_nominal_diameter = (self.atm_standard_nominal_diameter.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_standard_selected_height = (self.atm_standard_selected_height.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_standard_normal_fill_level = (self.atm_standard_normal_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_standard_save_fill_level = (self.atm_standard_save_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_standard_overfill_level = (self.atm_standard_overfill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_standard_available_vapor_space = (self.atm_standard_available_vapor_space.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.atm_standard_freeboard = (self.atm_standard_freeboard.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?

	#pressure storage standardize
    self.ps_standard_nominal_length = (self.ps_standard_nominal_length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_standard_nominal_depth = (self.ps_standard_nominal_depth.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_standard_selected_diameter = (self.ps_standard_selected_diameter.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_standard_normal_fill_level = (self.ps_standard_normal_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_standard_save_fill_level = (self.ps_standard_save_fill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_standard_overfill_level = (self.ps_standard_overfill_level.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.ps_standard_available_vapor_space = (self.ps_standard_available_vapor_space.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    save
  end

  private

  def save_defaults
	  capacity = self.project.storage_tank_vapor_space_capacity_above_maximum_level
	  self.update_attributes(
		  :atm_vapor_space_capacity_above_maximum_level => capacity,
		  :ps_vpc_above_maximum_level => capacity
	  )
  end
end
