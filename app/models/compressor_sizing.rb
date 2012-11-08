class CompressorSizing < ActiveRecord::Base  
  belongs_to :compressor_sizing_mode
  belongs_to :compressor_sizing_tag
  has_many :suction_pipings, :as => :suction_pipe, :dependent => :destroy
  has_many :compressor_sizing_discharges, :dependent => :destroy
  has_many :compressor_reciprocation_designs, :dependent => :destroy
  has_many :compressor_centrifugal_designs, :dependent => :destroy
    
  validates_presence_of :compressor_sizing_mode_id
    
  #before_save :attach_child_attrs #save_compressor_reciprocation_designs #, :save_compressor_centrifugal_designs
  after_create :save_defaults

  accepts_nested_attributes_for :suction_pipings, :allow_destroy => true, :reject_if => Proc.new {|attrs| attrs[:fitting].blank?}
  accepts_nested_attributes_for :compressor_sizing_discharges, :allow_destroy => true, :reject_if => Proc.new {|attrs| attrs[:process_basis_id].blank?}
  accepts_nested_attributes_for :compressor_centrifugal_designs, :allow_destroy => true
  accepts_nested_attributes_for :compressor_reciprocation_designs, :allow_destroy => true
  
 
  def compressor_reciprocation_designs=(crd_params)
   @crd_params = []
   crd_params.each do |i, crd_param|
      next if i == "#x#"
      crd_param[:_destroy] = 1 if crd_param[:delete] == "true"
      crd_param.delete(:delete)
      dp = crd_param[:compressor_reciprocation_design_pipings]
	  design_pipings = []
	  unless dp.nil?
		  dp.each do |i, cdp|
			  next if i == "#y#"
			  cdp[:_destroy] = 1 if cdp[:fitting].blank?
			  design_pipings << cdp
		  end if !dp.nil?
	  end
	  crd_param.delete(:compressor_reciprocation_design_pipings)
	  crd_param.merge!({:compressor_reciprocation_design_pipings_attributes => design_pipings})
	  @crd_params << crd_param
    end if !crd_params.nil?
	self.compressor_reciprocation_designs_attributes = @crd_params
  end
  
  
  def compressor_centrifugal_designs=(ccd_params)
   @ccd_params = []
   ccd_params.each do |i, ccd_param|
      next if i == "#x#"
	  ccd_param[:_destroy] = 1 if ccd_param[:delete] == "true"
	  ccd_param.delete(:delete)
	  dp = ccd_param[:compressor_centrifugal_design_pipings]
	  design_pipings = []
	  unless dp.nil?
		  dp.each do |i, cdp|
			  next if i == "#y#"
			  cdp[:_destroy] = 1 if cdp[:fitting].blank?
			  design_pipings << cdp
		  end if !dp.nil?
	  end
	  ccd_param.delete(:compressor_centrifugal_design_pipings)
	  ccd_param.merge!({:compressor_centrifugal_design_pipings_attributes => design_pipings})
	  @ccd_params << ccd_param
   end if !ccd_params.nil?
  self.compressor_centrifugal_designs_attributes = @ccd_params
  end

  def calculate_suction_dps
	  unit_decimals = self.compressor_sizing_tag.project.project_units
	  #assuming 51 for fitting type orifice
	  orifice_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 51])
	  #assuming 49 for fitting type equipment
	  equipment_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 49])
	  #assuming 52 for fitting type control valve
	  control_valve_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 52])

	  fitting_dp = self.suction_pipings.sum(:delta_p)

	  total_suction_dp = orifice_dp+equipment_dp+control_valve_dp+fitting_dp

	  self.update_attributes(:su_fitting_dP => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :su_equipment_dP => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :su_control_valve_dP => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :su_orifice_dP => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :su_total_suction_dP => total_suction_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i)
							)
  end

  def save_defaults
	  self.update_attributes(
		  :cd_max_allowable_discharge_pressure => self.compressor_sizing_tag.project.allowable_centrifugal_compressor_mawt,
		  :cd_standard_pressure => self.compressor_sizing_tag.project.standard_pressure,
		  :cd_standard_temperature=> self.compressor_sizing_tag.project.standard_temperature
	  )
  end


  #convert values
  def convert_values(multiply_factor,project)
    #Suction
    self.su_pressure = (self.su_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_temperature = project.convert_temperature(:value => self.su_temperature, :subtype => "General")
    self.su_mass_flow_rate = (self.su_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.su_vapor_density = (self.su_vapor_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.su_vapor_viscosity = (self.su_vapor_viscosity.to_f * multiply_factor["Viscosity"]["Dynamic"].to_f) if !multiply_factor["Viscosity"].nil?
    self.su_fitting_dP = (self.su_fitting_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_equipment_dP = (self.su_equipment_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_control_valve_dP = (self.su_control_valve_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_orifice_dP = (self.su_orifice_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_total_suction_dP = (self.su_total_suction_dP.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_pressure_at_suction_nozzle = (self.su_pressure_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    
    suction_pipings.where(:tab=>"suction").each do |suction_piping|
      suction_piping.pipe_id = (suction_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.length = (suction_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.elev = (suction_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.delta_p = (suction_piping.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?      
      suction_piping.save      
    end
    
    #Discharge
    compressor_sizing_discharges.each do |compressor_sizing_discharge|
      compressor_sizing_discharge.destination_pressure = (compressor_sizing_discharge.destination_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      compressor_sizing_discharge.fitting_dp = (compressor_sizing_discharge.fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      compressor_sizing_discharge.equipment_dp = (compressor_sizing_discharge.equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      compressor_sizing_discharge.control_valve_dp = (compressor_sizing_discharge.control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      compressor_sizing_discharge.orifice_dp = (compressor_sizing_discharge.orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      compressor_sizing_discharge.total_system_dp = (compressor_sizing_discharge.total_system_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      compressor_sizing_discharge.pressure_at_discharge_nozzle_dp = (compressor_sizing_discharge.pressure_at_discharge_nozzle_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
                    
      compressor_sizing_discharge.save
           
      compressor_sizing_discharge.discharge_circuit_piping.each do |dcp|
        dcp.pipe_id = (dcp.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
        dcp.length = (dcp.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        dcp.elev = (dcp.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        dcp.delta_p = (dcp.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        dcp.inlet_pressure = (dcp.inlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        
        dcp.save
      end
    end

    #Centrifugal Design
    self.cd_standard_pressure = (self.cd_standard_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.cd_standard_temperature = project.convert_temperature(:value => self.cd_standard_temperature, :subtype => "General")
    self.cd_press_at_suction_nozzle = (self.cd_press_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.cd_press_at_discharge_nozzle = (self.cd_press_at_discharge_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.cd_overall_differential_pressure = (self.cd_overall_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.cd_max_allowable_discharge_pressure = project.convert_temperature(:value => self.cd_max_allowable_discharge_pressure, :subtype => "General")

	compressor_centrifugal_designs.each do |cdesign|
		cdesign.differential_head          = (cdesign.differential_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
		cdesign.safety_factor              = (cdesign.safety_factor.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
		cdesign.required_differential_head = (cdesign.required_differential_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
		cdesign.suction_temperature        = project.convert_temperature(:value => cdesign.suction_temperature, :subtype => "General")
		cdesign.discharge_temperature      = project.convert_temperature(:value => cdesign.discharge_temperature, :subtype => "General")
		cdesign.flow_rate                  = (cdesign.flow_rate.to_f * multiply_factor["Volumetric Flow Rate"]["Vapor"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
		cdesign.gas_hp                      = (cdesign.gas_hp.to_f * multiply_factor["Horsepower"]["General"].to_f) if !multiply_factor["Horsepower"].nil?
		cdesign.mechanical_loss            = (cdesign.mechanical_loss.to_f * multiply_factor["Horsepower"]["General"].to_f) if !multiply_factor["Horsepower"].nil?
		cdesign.brake_horsepower           = (cdesign.brake_horsepower.to_f * multiply_factor["Horsepower"]["General"].to_f) if !multiply_factor["Horsepower"].nil?
		cdesign.normal_speed               = (cdesign.normal_speed.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?
		cdesign.speed                      = (cdesign.speed.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?
	end


    
    #Reciprocation Design
    self.rd_press_at_suction_nozzle = (self.rd_press_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.rd_press_at_discharge_nozzle = (self.rd_press_at_discharge_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.rd_overall_differential_pressure = (self.rd_overall_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.rd_max_allowable_discharge_pressure = (self.rd_max_allowable_discharge_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?


    #Settle Out
    
    
    save    
  end
end
