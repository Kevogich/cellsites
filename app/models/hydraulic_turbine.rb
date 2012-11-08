class HydraulicTurbine < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit

  has_many :hydraulic_turbine_circuit_pipings, :dependent => :destroy 
  has_many :hydraulic_discharges, :dependent => :destroy
  has_many :discharge_maximum, :class_name => 'HydraulicDischarge', :conditions => {:discharge_condition_basis => "maximum"}
  has_many :discharge_normal, :class_name => 'HydraulicDischarge', :conditions => {:discharge_condition_basis => "normal"}
  has_many :discharge_minimum, :class_name => 'HydraulicDischarge', :conditions => {:discharge_condition_basis => "minimum"}
  has_many :hprt_datas, :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable
  
  validates_presence_of :hydraulic_turbine_tag, :project_id, :process_unit_id, :su_process_basis_id
  
  after_save :save_hydraulic_turbine_circuit_pipings, :save_discharge_maximum, :save_discharge_normal, :save_discharge_minimum, :save_hprt_datas,
             :update_discharge_circuits_path
	    
  def hydraulic_turbine_circuit_pipings=(sp_params)
    @sp_params = sp_params
  end
  
  def save_hydraulic_turbine_circuit_pipings
    #raise @sp_params.to_yaml
    @sp_params.each do |i, sp_param|      
      sp = hydraulic_turbine_circuit_pipings.where(:id => sp_param[:id]).first     
      hydraulic_turbine_circuit_pipings.create(sp_param) if sp.nil? && !sp_param[:fitting].blank? #create
      sp.delete if !sp.nil? && sp_param[:fitting].blank? #delete
      sp.update_attributes(sp_param) if !sp.nil? && !sp_param[:fitting].blank? #update
    end if !@sp_params.nil?   
  end
    
  def discharge_maximum=(dmax_params)
    @dmax_params = dmax_params
  end
  
  def save_discharge_maximum
    @dmax_params.each do |i, dmax_param|      
      next if i == "#x#"
      dmax = hydraulic_discharges.where(:id => dmax_param[:id]).first
      dmax.delete if !dmax.nil? && dmax_param[:delete] == "true" #delete
      dmax_param.delete :delete
      hydraulic_discharges.create(dmax_param) if dmax.nil? #create
      dmax.update_attributes(dmax_param) if !dmax.nil? && !dmax.frozen? #update
    end if !@dmax_params.nil?  
  end
  
  def discharge_normal=(dnor_params)
    @dnor_params = dnor_params
  end

  def save_discharge_normal
    #raise @dnor_params.to_yaml
    @dnor_params.each do |i, dnor_param|      
      next if i == "#x#"
      dnor = hydraulic_discharges.where(:id => dnor_param[:id]).first
      dnor.delete if !dnor.nil? && dnor_param[:delete] == "true" #delete
      dnor_param.delete :delete
      hydraulic_discharges.create(dnor_param) if dnor.nil? #create
      dnor.update_attributes(dnor_param) if !dnor.nil? && !dnor.frozen? #update
    end if !@dnor_params.nil?  
  end
  
  def discharge_minimum=(dmin_params)    
    @dmin_params = dmin_params
  end
  
  def save_discharge_minimum
    #raise @dmin_params.to_yaml
    @dmin_params.each do |i, dmin_param|      
      next if i == "#x#"
      dmin = hydraulic_discharges.where(:id => dmin_param[:id]).first
      dmin.delete if !dmin.nil? && dmin_param[:delete] == "true" #delete
      dmin_param.delete :delete
      hydraulic_discharges.create(dmin_param) if dmin.nil? #create
      dmin.update_attributes(dmin_param) if !dmin.nil? && !dmin.frozen? #update
    end if !@dmin_params.nil?  
  end
  
  def hprt_datas=(hp_params)
    @hp_params = hp_params
  end
  
  def save_hprt_datas
    #raise @hp_params.to_yaml
    @hp_params.each do |i, hp_param|      
      hp = hprt_datas.where(:id => hp_param[:id]).first     
      hprt_datas.create(hp_param) if hp.nil? && !hp_param[:capacity].blank? #create
      hp.delete if !hp.nil? && hp_param[:capacity].blank? #delete
      hp.update_attributes(hp_param) if !hp.nil? && !hp_param[:capacity].blank? #update
    end if !@hp_params.nil? 
  end
  
  #TODO updated paths for discharge circuits
  def update_discharge_circuits_path    
    
    self.discharge_maximum.each do |discharge|      
      rs_hds = self.hydraulic_discharges.where(:path => discharge.path)
      path_ar = {}
      rs_hds.each do |hd|
        path_ar[hd.discharge_condition_basis] = hd.id
      end
      
      discharge.hydraulic_discharge_circuit_pipings.each do |dcp|
        dcp.discharge_maximum_path_id = path_ar['maximum']
        dcp.discharge_normal_path_id = path_ar['normal']  
        dcp.discharge_minimum_path_id = path_ar['minimum']
        dcp.save        
      end
    end   
    
  end
  
  #convert values
  def convert_values(multiply_factor,project)
    #Suction
    self.su_max_pressure         = (self.su_max_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_max_temperature      = project.convert_temperature(:value => self.su_max_temperature, :subtype => "General")
    self.su_max_mass_flow_rate   = (self.su_max_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.su_max_density          = (self.su_max_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.su_max_viscosity        = (self.su_max_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.su_max_vapor_pressure   = (self.su_max_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_nor_pressure         = (self.su_nor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_nor_temperature      = project.convert_temperature(:value => self.su_nor_temperature, :subtype => "General")
    self.su_nor_mass_flow_rate   = (self.su_nor_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.su_nor_density          = (self.su_nor_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.su_nor_viscosity        = (self.su_nor_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.su_nor_vapor_pressure   = (self.su_nor_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_min_pressure         = (self.su_min_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_min_temperature      = project.convert_temperature(:value => self.su_min_temperature, :subtype => "General")
    self.su_min_mass_flow_rate   = (self.su_min_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.su_min_density          = (self.su_min_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.su_min_viscosity        = (self.su_min_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.su_min_vapor_pressure   = (self.su_min_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?

    self.su_fitting_dp_max       = (self.su_fitting_dp_max.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_equipment_dp_max     = (self.su_equipment_dp_max.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_control_valve_dp_max = (self.su_control_valve_dp_max.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_orifice_dp_max       = (self.su_orifice_dp_max.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_total_suction_dp_max = (self.su_total_suction_dp_max.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?

    self.su_fitting_dp_min       = (self.su_fitting_dp_min.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_equipment_dp_min     = (self.su_equipment_dp_min.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_control_valve_dp_min = (self.su_control_valve_dp_min.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_orifice_dp_min       = (self.su_orifice_dp_min.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_total_suction_dp_min = (self.su_total_suction_dp_min.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?

    self.su_fitting_dp_nor       = (self.su_fitting_dp_nor.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_equipment_dp_nor     = (self.su_equipment_dp_nor.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_control_valve_dp_nor = (self.su_control_valve_dp_nor.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_orifice_dp_nor       = (self.su_orifice_dp_nor.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_total_suction_dp_nor = (self.su_total_suction_dp_nor.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?


    self.su_pressure_at_suction_nozzle_max = (self.su_pressure_at_suction_nozzle_max.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_max_upstream_pressure_max = (self.su_max_upstream_pressure_max.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.su_max_pressure_at_suction_nozzle_max = (self.su_max_pressure_at_suction_nozzle_max.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    
    hydraulic_turbine_circuit_pipings.each do |hydraulic_turbine_circuit_piping|
      hydraulic_turbine_circuit_piping.pipe_id = (hydraulic_turbine_circuit_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
      hydraulic_turbine_circuit_piping.length = (hydraulic_turbine_circuit_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      hydraulic_turbine_circuit_piping.elev = (hydraulic_turbine_circuit_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      hydraulic_turbine_circuit_piping.delta_p_max = (hydraulic_turbine_circuit_piping.delta_p_max.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_turbine_circuit_piping.outlet_pressure = (hydraulic_turbine_circuit_piping.outlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_turbine_circuit_piping.save
    end
    
    #Discharge
    hydraulic_discharges.each do |hydraulic_discharge|
      hydraulic_discharge.destination_pressure = (hydraulic_discharge.destination_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_discharge.fitting_dp = (hydraulic_discharge.fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_discharge.equipment_dp = (hydraulic_discharge.equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_discharge.control_valve_dp = (hydraulic_discharge.control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_discharge.orifice_dp = (hydraulic_discharge.orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_discharge.total_system_dp = (hydraulic_discharge.total_system_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      hydraulic_discharge.pressure_at_discharge_nozzle_dp = (hydraulic_discharge.pressure_at_discharge_nozzle_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
              
      hydraulic_discharge.save
      
      hydraulic_turbine_circuit_pipings do |hydraulic_turbine_circuit_piping|
        hydraulic_turbine_circuit_piping.pipe_id = (hydraulic_turbine_circuit_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
        hydraulic_turbine_circuit_piping.length = (hydraulic_turbine_circuit_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        hydraulic_turbine_circuit_piping.elev = (hydraulic_turbine_circuit_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        hydraulic_turbine_circuit_piping.delta_p = (hydraulic_turbine_circuit_piping.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        hydraulic_turbine_circuit_piping.inlet_pressure = (hydraulic_turbine_circuit_piping.inlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        
        hydraulic_turbine_circuit_piping.save
      end
    end
    
    #Hydraulic Turbine Design
    self.htd_red_capacity = (self.htd_red_capacity.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
    self.htd_red_differential_pressure = (self.htd_red_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.htd_red_horsepower = (self.htd_red_horsepower.to_f * multiply_factor["Power"]["General"].to_f) if !multiply_factor["Power"].nil?
    self.htd_red_speed = (self.htd_red_speed.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?

    self.htd_td_pressure_at_suction_nozzle_max = (self.htd_td_pressure_at_suction_nozzle_max.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.htd_td_pressure_at_discharge_nozzle_max = (self.htd_td_pressure_at_discharge_nozzle_max.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.htd_td_differential_pressure_max = (self.htd_td_differential_pressure_max.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.htd_td_differential_head_max = (self.htd_td_differential_head_max.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.htd_tap_flow_rate_max = (self.htd_tap_flow_rate_max.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
    self.htd_tap_hydraulic_hp_max = (self.htd_tap_hydraulic_hp_max.to_f * multiply_factor["Horsepower"]["General"].to_f) if !multiply_factor["Horsepower"].nil?
    self.htd_tap_brake_horsepower_max = (self.htd_tap_brake_horsepower_max.to_f * multiply_factor["Horsepower"]["General"].to_f) if !multiply_factor["Horsepower"].nil?

    #HPRT Curve
    hprt_datas.each do |hprt_data|
      hprt_data.capacity = (hprt_data.capacity.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
      hprt_data.system_loss = (hprt_data.system_loss.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      
      hprt_data.save
    end
    
    save    
  end


  #calculate fitting DP, Equipment DP, Control Valve DP, Orifice DP
  def calculate_and_save_delta_ps
	  #assuming 51 for fitting type orifice
	  orifice_dp = self.hydraulic_turbine_circuit_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 51])
	  #assuming 49 for fitting type equipment
	  equipment_dp = self.hydraulic_turbine_circuit_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 49])
	  #assuming 52 for fitting type control valve
	  control_valve_dp = self.hydraulic_turbine_circuit_pipings.sum(:delta_p, :conditions => ['fitting = ? ', 52])
	  fitting_dp = self.hydraulic_turbine_circuit_pipings.sum(:delta_p)
	  
	  self.update_attributes(:su_fitting_dp => fitting_dp.round(4),
							 :su_equipment_dp => equipment_dp.round(4),
							 :su_control_valve_dp => control_valve_dp.round(4),
							 :su_orifice_dp => orifice_dp.round(4)
							)

  end


end
