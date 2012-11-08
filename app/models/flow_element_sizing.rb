class FlowElementSizing < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit  
  has_many :suction_pipings, :as => :suction_pipe, :dependent => :destroy
  has_many :flow_element_downstreams, :dependent => :destroy
  has_many :downstream_maximum, :class_name => 'FlowElementDownstream', :conditions => {:downstream_condition_basis => "maximum"}
  has_many :downstream_normal, :class_name => 'FlowElementDownstream', :conditions => {:downstream_condition_basis => "normal"}
  has_many :downstream_minimum, :class_name => 'FlowElementDownstream', :conditions => {:downstream_condition_basis => "minimum"}
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable
  
  validates_presence_of :flow_element_tag, :project_id, :process_unit_id
  
  after_save :save_suction_pipings, :save_downstream_maximum, :save_downstream_normal, :save_downstream_minimum,
             :update_discharge_circuits_path  
  
  def downstreams=(ds_params)
    @ds_params = ds_params    
  end

  def suction_pipings=(sp_params)
    @sp_params = sp_params
  end
    
  def save_suction_pipings
    #raise @sp_params.to_yaml
    @sp_params.each do |i, sp_param|      
      sp = suction_pipings.where(:id => sp_param[:id]).first     
      suction_pipings.create(sp_param) if sp.nil? && !sp_param[:fitting].blank? #create
      sp.delete if !sp.nil? && sp_param[:fitting].blank? #delete
      sp.update_attributes(sp_param) if !sp.nil? && !sp_param[:fitting].blank? #update
    end if !@sp_params.nil?   
  end
  
  def downstream_maximum=(dmax_params)
    @dmax_params = dmax_params
  end
    
  def save_downstream_maximum
    #raise @dmax_params.to_yaml
    @dmax_params.each do |i, dmax_param|
      next if i == "#x#"
      dmax = flow_element_downstreams.where(:id => dmax_param[:id]).first      
      dmax.delete if !dmax.nil? && dmax_param[:delete] == "true" #delete      
      dmax_param.delete :delete
      flow_element_downstreams.create(dmax_param) if dmax.nil? #create
      dmax.update_attributes(dmax_param) if !dmax.nil? && !dmax.frozen? #update
    end if !@dmax_params.nil?   
  end
  
  def downstream_normal=(dnor_params)
    @dnor_params = dnor_params
  end
  
  def save_downstream_normal
    #raise @dn_params.to_yaml
    @dnor_params.each do |i, dnor_param|
      next if i == "#x#"
      dnor = flow_element_downstreams.where(:id => dnor_param[:id]).first
      dnor.delete if !dnor.nil? && dnor_param[:delete] == "true" #delete
      dnor_param.delete :delete
      flow_element_downstreams.create(dnor_param) if dnor.nil? #create      
      dnor.update_attributes(dnor_param) if !dnor.nil? && !dnor.frozen? #update
    end if !@dnor_params.nil?
  end  
  
  def downstream_minimum=(dmin_params)
    @dmin_params = dmin_params
  end
  
  def save_downstream_minimum
    #raise @dmin_params.to_yaml
    @dmin_params.each do |i, dmin_param|
      next if i == "#x#"
      dmin = flow_element_downstreams.where(:id => dmin_param[:id]).first
      dmin.delete if !dmin.nil? && dmin_param[:delete] == "true" #delete
      dmin_param.delete :delete
      flow_element_downstreams.create(dmin_param) if dmin.nil? #create      
      dmin.update_attributes(dmin_param) if !dmin.nil? && !dmin.frozen? #update
    end if !@dmin_params.nil?
  end
  
  #TODO updated paths for downstream circuits
  def update_discharge_circuits_path    
    
    self.downstream_maximum.each do |downstream|
      rs_fds = self.flow_element_downstreams.where(:path => downstream.path)
      path_ar = {}
      rs_fds.each do |fd|
        path_ar[fd.downstream_condition_basis] = fd.id
      end
      
      downstream.flow_element_downstream_circuit_pipings.each do |dcp|
        dcp.downstream_maximum_path_id = path_ar['maximum']
        dcp.downstream_normal_path_id = path_ar['normal']  
        dcp.downstream_minimum_path_id = path_ar['minimum']
        dcp.save        
      end
    end   
    
  end

  def calculate_and_save_delta_ps(params)

	  #assuming 51 for fitting type orifice
	  orifice_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 51])

	  #assuming 49 for fitting type equipment
	  equipment_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 49])

	  #assuming 52 for fitting type control valve
	  control_valve_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 52])

	  fitting_dp = self.suction_pipings.sum(:delta_p)
	  total_suction_dp = orifice_dp+equipment_dp+control_valve_dp+fitting_dp
	  unit_decimals = self.project.project_units
	  
	  if params[:up_condition_basis] == 'max'
		  self.update_attributes(:up_il_max_fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_max_equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_max_control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_max_orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_max_total_suction_dp => total_suction_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i)
								)
	  elsif params[:up_condition_basis] == 'min'
		  self.update_attributes(:up_il_min_fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_min_equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_min_control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_min_orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_min_total_suction_dp => total_suction_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i)
								)
      elsif params[:up_condition_basis] == 'nor'
		  self.update_attributes(:up_il_nor_fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_nor_equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_nor_control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_nor_orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_il_nor_total_suction_dp => total_suction_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i)
								)
	  end
  end
  
  #convert values
  def convert_values(multiply_factor,project)
    #Upstream
    self.up_max_pressure = (self.up_max_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_temperature = project.convert_temperature(:value => self.up_max_temperature, :subtype => "General")
    self.up_max_mass_flow_rate = (self.up_max_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["Differential"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.up_max_vp_density = (self.up_max_vp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_max_vp_viscosity = (self.up_max_vp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_max_lp_density = (self.up_max_lp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_max_lp_viscosity = (self.up_max_lp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_nor_pressure = (self.up_nor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_temperature = project.convert_temperature(:value => self.up_nor_temperature, :subtype => "General")
    self.up_nor_mass_flow_rate = (self.up_nor_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["Differential"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.up_nor_vp_density = (self.up_nor_vp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_nor_vp_viscosity = (self.up_nor_vp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_nor_lp_density = (self.up_nor_lp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_nor_lp_viscosity = (self.up_nor_lp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_min_pressure = (self.up_min_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_temperature = project.convert_temperature(:value => self.up_min_temperature, :subtype => "General")
    self.up_min_mass_flow_rate = (self.up_min_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["Differential"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.up_min_vp_density = (self.up_min_vp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_min_vp_viscosity = (self.up_min_vp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_min_lp_density = (self.up_min_lp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_min_lp_viscosity = (self.up_min_lp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    
    self.up_il_max_fitting_dp                  = (self.up_il_max_fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_max_equipment_dp                = (self.up_il_max_equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_max_control_valve_dp            = (self.up_il_max_control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_max_orifice_dp                  = (self.up_il_max_orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_max_total_suction_dp            = (self.up_il_max_total_suction_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_max_pressure_at_inlet_flange_dp = (self.up_il_max_pressure_at_inlet_flange_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    
    self.up_il_min_fitting_dp                  = (self.up_il_min_fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_min_equipment_dp                = (self.up_il_min_equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_min_control_valve_dp            = (self.up_il_min_control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_min_orifice_dp                  = (self.up_il_min_orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_min_total_suction_dp            = (self.up_il_min_total_suction_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_min_pressure_at_inlet_flange_dp = (self.up_il_min_pressure_at_inlet_flange_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?

    self.up_il_nor_fitting_dp                  = (self.up_il_nor_fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_nor_equipment_dp                = (self.up_il_nor_equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_nor_control_valve_dp            = (self.up_il_nor_control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_nor_orifice_dp                  = (self.up_il_nor_orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_nor_total_suction_dp            = (self.up_il_nor_total_suction_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_il_nor_pressure_at_inlet_flange_dp = (self.up_il_nor_pressure_at_inlet_flange_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?


    suction_pipings.where(:tab=>"upstream").each do |suction_piping|
      suction_piping.pipe_id = (suction_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.length = (suction_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.elev = (suction_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.delta_p = (suction_piping.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      suction_piping.outlet_pressure = (suction_piping.outlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      suction_piping.save      
    end
        
    #Downstream
    flow_element_downstreams.each do |flow_element_downstream|
      flow_element_downstream.destination_pressure = (flow_element_downstream.destination_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      flow_element_downstream.fitting_dp = (flow_element_downstream.fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      flow_element_downstream.equipment_dp = (flow_element_downstream.equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      flow_element_downstream.control_valve_dp = (flow_element_downstream.control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      flow_element_downstream.orifice_dp = (flow_element_downstream.orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      flow_element_downstream.total_system_dp = (flow_element_downstream.total_system_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      flow_element_downstream.pressure_at_outlet_flange = (flow_element_downstream.pressure_at_outlet_flange.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
              
      flow_element_downstream.save
      
      flow_element_downstream.flow_element_downstream_circuit_pipings do |flow_element_downstream_circuit_piping|
        flow_element_downstream_circuit_piping.pipe_id = (flow_element_downstream_circuit_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
        flow_element_downstream_circuit_piping.length = (flow_element_downstream_circuit_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        flow_element_downstream_circuit_piping.elev = (flow_element_downstream_circuit_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        flow_element_downstream_circuit_piping.delta_p = (flow_element_downstream_circuit_piping.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        flow_element_downstream_circuit_piping.inlet_pressure = (flow_element_downstream_circuit_piping.inlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        
        flow_element_downstream_circuit_piping.save
      end      
    end
    
    #Orifice Design
    self.os_pipe_id = (self.os_pipe_id.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.os_orifice_diameter = (self.os_orifice_diameter.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.os_min_differential_pressure = (self.os_min_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.os_nor_differential_pressure = (self.os_nor_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.os_max_differential_pressure = (self.os_max_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.os_min_orifice_diameter_d = (self.os_min_orifice_diameter_d.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.os_nor_orifice_diameter_d = (self.os_nor_orifice_diameter_d.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.os_max_orifice_diameter_d = (self.os_max_orifice_diameter_d.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    
    save
  end
end
