class ControlValveSizing < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :suction_pipings, :as => :suction_pipe, :dependent => :destroy
  has_many :control_valve_downstreams, :dependent => :destroy
  has_many :downstream_maximum, :class_name => 'ControlValveDownstream', :conditions => {:downstream_condition_basis => "maximum"}
  has_many :downstream_normal, :class_name => 'ControlValveDownstream', :conditions => {:downstream_condition_basis => "normal"}
  has_many :downstream_minimum, :class_name => 'ControlValveDownstream', :conditions => {:downstream_condition_basis => "minimum"}
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable

  validates_presence_of :control_valve_tag, :project_id, :process_unit_id
  
  after_save :save_suction_pipings, :save_downstream_maximum, :save_downstream_normal, :save_downstream_minimum, :update_downstream_circuits_path
    
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
  
  def control_valve_downstreams=(cvd_params)
    @cvd_params = cvd_params
  end
  
  def downstream_maximum=(dmax_params)
    @dmax_params = dmax_params
  end
    
  def save_downstream_maximum
    #raise @dmax_params.to_yaml
    @dmax_params.each do |i, dmax_param|
      next if i == "#x#"
      dmax = control_valve_downstreams.where(:id => dmax_param[:id]).first      
      dmax.delete if !dmax.nil? && dmax_param[:delete] == "true" #delete      
      dmax_param.delete :delete
      control_valve_downstreams.create(dmax_param) if dmax.nil? #create
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
      dnor = control_valve_downstreams.where(:id => dnor_param[:id]).first
      dnor.delete if !dnor.nil? && dnor_param[:delete] == "true" #delete
      dnor_param.delete :delete
      control_valve_downstreams.create(dnor_param) if dnor.nil? #create      
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
      dmin = control_valve_downstreams.where(:id => dmin_param[:id]).first
      dmin.delete if !dmin.nil? && dmin_param[:delete] == "true" #delete
      dmin_param.delete :delete
      control_valve_downstreams.create(dmin_param) if dmin.nil? #create      
      dmin.update_attributes(dmin_param) if !dmin.nil? && !dmin.frozen? #update
    end if !@dmin_params.nil?
  end

  #condition_basis is maxmum, minimum, or normal
  def self.cvfe_inlet_side_hydraulics_liquid(flow_element,pipings,condition_basis)
	  project = flow_element.project
	  log = CustomLogger.new("cvfe_inlet_side_hydraulics_liquid")

	  pipeid                     = (1..100).to_a
	  length                     = (1..100).to_a
	  flow_percentage            = (1..100).to_a
	  reynold_number             = (1..100).to_a
	  ft                         = (1..100).to_a
	  kfi                        = (1..100).to_a
	  doverdi                    = (1..100).to_a
	  nre                        = (1..100).to_a
	  kfii                       = (1..100).to_a
	  kfd                        = (1..100).to_a
	  f                          = (1..100).to_a
	  kff                        = (1..100).to_a
	  doverdii                   = (1..100).to_a
	  elevation                  = (1..100).to_a
	  pressure_drop              = (1..100).to_a

	  pi = 3.14159265358979

	  barometric_pressure = project.barometric_pressure
	  pipe_roughness = project.pipes[0].roughness_recommended
	  e = pipe_roughness
	  circuit_pipings = pipings
	  count = circuit_pipings.length

	  if condition_basis == 'max'
		  mass_flow_rate   = flow_element.up_max_mass_flow_rate
		  pressure         = flow_element.up_max_pressure
		  temperature      = flow_element.up_max_temperature
		  liquid_viscosity = flow_element.up_max_lp_viscosity
		  liquid_density   = flow_element.up_max_lp_density

	  elsif condition_basis == 'min'
		  mass_flow_rate   = flow_element.up_min_mass_flow_rate
		  pressure         = flow_element.up_min_pressure
		  temperature      = flow_element.up_min_temperature
		  liquid_density   = flow_element.up_min_lp_density
		  liquid_viscosity = flow_element.up_min_lp_viscosity
	  else
		  mass_flow_rate   = flow_element.up_nor_mass_flow_rate
		  pressure         = flow_element.up_nor_pressure
		  temperature      = flow_element.up_nor_temperature
		  liquid_density   = flow_element.up_nor_lp_density
		  liquid_viscosity = flow_element.up_nor_lp_viscosity
	  end

	  (0..count-1).each do |p|
		  circuit_piping = circuit_pipings[p]
		  fitting           = circuit_piping.fitting
		  fitting_tag       = circuit_piping.fitting_tag
		  pipe_size         = circuit_piping.pipe_size
		  pipe_schedule     = circuit_piping.pipe_schedule
		  pipe_id           = circuit_piping.pipe_id
		  per_flow          = circuit_piping.per_flow
		  fitting_length    = circuit_piping.length
		  fitting_elevation = circuit_piping.elev

		  #logging info
		  log.info("fitting = #{fitting}")
		  log.info("fitting_tag = #{fitting_tag}")
		  log.info("pipe_size = #{pipe_size}")
		  log.info("pipe_schedule = #{pipe_schedule}")
		  log.info("pipe_id = #{pipe_id}")
		  log.info("percentage_flow = #{per_flow}")
		  log.info("fitting_length = #{fitting_length}")
		  log.info("fitting_elevation = #{fitting_elevation}")

		  pipeid[p] = pipe_id/12
		  flow_percentage[p] = per_flow
		  cv = circuit_piping.ds_cv
		  dorifice = circuit_piping.ds_cv

		mass_flow_rate1 = mass_flow_rate * (flow_percentage[p] / 100)
        volume_rate = mass_flow_rate1 / liquid_density
        nre[p] = (0.52633 * mass_flow_rate1) / (pipeid[p] * liquid_viscosity)

        a = (2.457 * Math.log(1 / (((7 / nre[p]) ** 9) + (0.27 * (pipe_roughness.to_f / pipeid[p]))))) ** 16 
		b = (37530 / nre[p]) ** 16
		f[p] = 2 * ((8 / nre[p]) ** 12 + (1 / ((a+b) ** (3/2)))) ** (1/12)

		fd = 4 * f[p]
		nreynolds = nre[p]
		d = pipe_id
		d1 = pipe_id
		d2 = per_flow
        fitting_type = PipeSizing.get_fitting_tag(circuit_piping.fitting)[:value]

		log.info("fitting type = #{fitting_type}")
		if fitting_type == "Pipe"
			kf = 4 * f[p] * (length[p] / pipeid[p])
		elsif fitting_type == "Control Valve"
			kf = ((29.9 * d ** 2) / cv) ** 2
		elsif fitting_type == "Orifice"
			beta = dorifice/d
			if nreynolds <= 10**4
				#UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2)
				#UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
				#UserFormOrificeCoefficientLR.Show
				#FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
			elsif nreynolds > 10 ^ 4
				#UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
				#UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
				#UserFormOrificeCoefficientHR.Show
				#FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
				#Else
			end
			#TODO dummy value
			flow_c = 10.0
			kf = (1 - beta ** 2) / (flow_c ** 2 * beta ** 4)
		elsif fitting_type == "Equipment"
			kf = 10.0 #TODO dummy value
		else
			result = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)
			dover_d = result[:dover_d]
			kf = result[:kf]
		end
		kfii[p] = kf
		doverdi[p] = dover_d

		kfd[p] = kfii[p] / (pipeid[p] ** 4)
		nre[p + 1] = (0.52633 * mass_flow_rate1) / (pipeid[p + 1] * liquid_viscosity)

		#select Kinetic Energy Correction Factor
		  if nre[p] <= 2000
			  alpha1 = 2
		  elsif nre[p] > 2000 and nre[p] < 10 ** 7
			  alpha1 = 1
		  elsif nre[p] > 10 ** 7
			  alpha1 = 0.85
		  end

		  if nre[p] <= 2000
			  alpha2 = 2
		  elsif nre[p] > 2000 and nre[p] < 10 ** 7
			  alpha2 = 1
		  elsif nre[p] > 10 ** 7
			  alpha2 = 0.85
		  end

		  kinetic_correction1 = alpha1 / pipeid[p] ** 4
		  kinetic_correction2 = alpha2 / pipeid[p+1] ** 4

		  #Kinetic Energy + Frictional Loss
		  sumof_ke_and_ef = (0.810569 * volume_rate ** 2) * (kfd[p] + kinetic_correction2 - kinetic_correction1)

		  #Potential Energy
		  elevation[p] = circuit_piping.elev
		  pe  = 4.1698 * 10 **  8 * elevation[p]
		  #PressureDrop(nn) = Density * ((SumofKEandEf + PE) / (6.00444 * 10 ^ 10))
		  pressure_drop = liquid_density * ((sumof_ke_and_ef + pe) / (6.00444 * 10 ** 10)) 
		  log.info("Calculated pressure drop = #{pressure_drop} =======")
		  #circuit_piping.update_attributes(:delta_p => pressure_drop)
		  if condition_basis == 'max'
		  	circuit_piping.update_attributes(:delta_p_max => pressure_drop.real.to_f)
		  elsif condition_basis == 'min'
		  	circuit_piping.update_attributes(:delta_p_min => pressure_drop.real.to_f)
		  else
		  	circuit_piping.update_attributes(:delta_p_nor => pressure_drop.real.to_f)
		  end

	end
  end

  def self.cvfe_inlet_side_hydraulics_vapor(flow_element,pipings,condition_basis)
	  project = flow_element.project
	  pipeid                     = (1..100).to_a
	  length                     = (1..100).to_a
	  flow_percentage            = (1..100).to_a
	  reynold_number             = (1..100).to_a
	  ft                         = (1..100).to_a
	  kfi                        = (1..100).to_a
	  doverdi                    = (1..100).to_a
	  nre                        = (1..100).to_a
	  kfii                       = (1..100).to_a
	  kfd                        = (1..100).to_a
	  f                          = (1..100).to_a
	  kff                        = (1..100).to_a
	  doverdii                   = (1..100).to_a
	  elevation                  = (1..100).to_a
	  pressure_drop              = (1..100).to_a
	  inlet_pressure             = (1..100).to_a
	  inlet_temperature          = (1..100).to_a
	  section_outlet_pressure    = (0..100).to_a
	  section_outlet_temperature = (0..100).to_a
	  fittings                   = (1..100).to_a
	  fitting_dp                 = (1..100).to_a
	  pi = 3.14159265358979
	  barometric_pressure = project.barometric_pressure
	  pipe_roughness = project.pipes[0].roughness_recommended
	  e = pipe_roughness
	  circuit_pipings = pipings
	  count = circuit_pipings.length

	  if condition_basis == 'max'
		  mass_flow_rate = flow_element.up_max_mass_flow_rate
		  pressure       = flow_element.up_max_pressure
		  temperature    = flow_element.up_max_temperature
		  viscosity      = flow_element.up_max_vp_viscosity
		  vapor_mw       = flow_element.up_max_vp_mw
	  elsif condition_basis == 'min'
		  mass_flow_rate = flow_element.up_min_mass_flow_rate
		  pressure       = flow_element.up_min_pressure
		  temperature    = flow_element.up_min_temperature
		  viscosity      = flow_element.up_min_vp_viscosity
		  vapor_mw       = flow_element.up_min_vp_mw
	  else
		  mass_flow_rate = flow_element.up_nor_mass_flow_rate
		  pressure       = flow_element.up_nor_pressure
		  temperature    = flow_element.up_nor_temperature
		  viscosity      = flow_element.up_nor_vp_viscosity
		  vapor_mw       = flow_element.up_nor_vp_mw
	  end

	  relief_rate = mass_flow_rate
	  #TODO dummy values
	  relief_pressure = 10.0
	  relief_temperature = 10.0

	  (0..count-1).each do |p|
		  circuit_piping = circuit_pipings[p]
		  fitting           = circuit_piping.fitting
		  fitting_tag       = circuit_piping.fitting_tag
		  pipe_size         = circuit_piping.pipe_size
		  pipe_schedule     = circuit_piping.pipe_schedule
		  pipe_id           = circuit_piping.pipe_id
		  per_flow          = circuit_piping.per_flow
		  fitting_length    = circuit_piping.length
		  fitting_elevation = circuit_piping.elev
		  cv = circuit_piping.ds_cv

		  relief_rate1 = relief_rate * (flow_percentage[p] / 100)
		  nre[p] = (0.52633 * relief_rate1) / (pipeid[p] * viscosity)

		  a = (2.457 * Math.log(1 / (((7 / nre[p]) ** 9) + (0.27 * (e / pipeid[p]))))) ** 16 
		  #TODO 0.9 changed to 9 to avoid complex number
		  b = (37530 / nre[p]) ** 16
		  f[p] = 2 * ((8 / nre[p]) ** 12 + ( 1 / ((a + b) ** (3 / 2)))) ** (1 / 12) 
		  p_drop = 0

		  fd        = 4 * f[p]
		  nreynolds = nre
		  d         = pipe_id
		  d1        = pipe_id
		  d2        = per_flow

          fitting_type = PipeSizing.get_fitting_tag(circuit_piping.fitting)[:value]
		  if fitting_type == 'Pipe'
			  kf = 4 * f[p] * (length[p]/pipeid[p])
		  elsif fitting_type == "Control Valve" and p_drop == ""
			  kf = ((29.9 * d ** 2)/ cv) ** 2
		  elsif fitting_type == "Orifice" and p_drop == ""
			  beta = cv_dorifice / d
            if nreynolds <= 10 ** 4
              #UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2)
              #UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
              #UserFormOrificeCoefficientLR.Show
              #FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
            elsif nreynolds > 10 ** 4
              #UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
              #UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
              #UserFormOrificeCoefficientHR.Show
              #FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
            end
			#TODO dummy value
		  flow_c = 1.0
		  kf = (1 - beta ** 2) / (flow_c ** 2 * beta ** 4)
		  elsif fitting_type == "Equipment"
			  p_drop = ""
		  elsif fitting_type == "Control Valve" and p_drop != ""
			  p_drop = ""
		  elsif fitting_type == "Orifice" and p_drop != ""
			  p_drop = ""
		  else
			  result = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)
			  dover_d = result[:dover_d]
			  kfii[p] = result[:kf]
			  doverdii[p] = dover_d
		  end

		  choke_counter = 0
		  sumkff = 0
		  sumkff = sumkff + kff[p]
		  pipeid[p] = pipe_id
		  inlet_pressure[1] = relief_pressure
		  inlet_temperature[1] = relief_temperature
		  #determine g
		  area = (pi / 4) * (pipeid[p]) ** 2
		  mass_velocity = relief_rate1/area
		  if project.vapor_flow_model == "Isothermic"
			  part1 = (inlet_pressure[p] + barometric_pressure) ** 2
			  part2 = (7.41109 * 10 ** -6 * (relief_temperature + 459.67) * mass_velocity ** 2) / vapor_mw
			  part3 = sumkff/2
			  initial_outlet_pressure = (part1 - (part2 * part3)) ** 0.5
			  (1..100).each do |gg|
				  #part4 = Math.log((inlet_pressure[p] + barometric_pressure) / initial_outlet_pressure) # 'Log is natural log (aka ln())
				  #TODO using dummy value
				  part4 = 10.0
				  section_outlet_pressure[gg] = (part1 - part2 * (part3 + part4)) ** 0.5
				  initial_outlet_pressure = section_outlet_pressure[gg]
				  if section_outlet_pressure[gg] ==  section_outlet_pressure[gg - 1]
					  inlet_pressure[p+1] = section_outlet_pressure[gg] - barometric_pressure
				  end              
			  end   
			  #Determine sonic downstream pressure at each fitting along the system
			  #Check for choked flow
			  p1 = inlet_pressure[p]
			  p2 = inlet_pressure[p+1]
			  pressure_drop = p1 - p2
			  (1..1000).each do |r|
				  p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
				  part1 = ((p1 + barometric_pressure) / p2_critical) ** 2
				  #part2 = 2 ** Math.log((p1 + barometric_pressure) / p2_critical)
				  #TODO dummy value
				  part2 = 10.0
				  isothermal_choke_kf = part1 - part2 - 1
				  #TODO dummy value
				  sumkff = 10.0
				  #TODO dummy value
				  isothermal_choke_kf = 10.0
				  if sumkff <= isothermal_choke_kf
					 break
				  end
			  end
			  #Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
		  elsif project.vapor_flow_model == "Adiabatic"
			  part1 = vapor_k / (vapor_k + 1)
			  part2 = 269866 * (vapor_k / (vapor_k + 1))
			  part3 = ((inlet_pressure[p] + barometric_pressure) ** 2 * vapor_mw) / (inlet_temperature[p] + 459.67)
			  part4 = mass_velocity ** 2 * (sumkff / 2)
			  initial_outlet_pressure = (inlet_pressure[p] + barometric_pressure) * (1 - (part4 / (part2 * part3))) ** part1
			  (1..100).each do |gg|
				  part5 = Math.log(inlet_pressure[p] + barometric_pressure / initial_outlet_pressure) / vapor_k
				  part6 = mass_velocity ** 2 * ((sumkff / 2) + part5)
				  section_outlet_pressure[gg] = (inlet_pressure[p] + barometric_pressure) * ( 1 - (part6 / (part2 * part3))) ** part1
				  section_outlet_temperature[gg] = (inlet_temperature[p] + 459.69) * (section_outlet_pressure[gg] / (inlet_pressure[p] + barometric_pressure)) ** (( vapor_k -1) / vapor_k)
				  initial_outlet_pressure = section_outlet_pressure[gg]
				  if section_outlet_pressure == section_outlet_pressure[gg -1]
					  inlet_pressure[p +1] = section_outlet_pressure[gg] - barometric_pressure
					  inlet_temperature[p +1] = section_outlet_temperature[gg] - 459.69
					  #TODO need reiview
					  #Worksheets("FE Circuit").Cells(15720 + nn, 91).Value = InletPress(nn + 1)
					  #Worksheets("FE Circuit").Cells(15720 + nn, 94).Value = InletTemp(nn + 1)
					  gg = 100
				  end
			  end
			  #Determine sonic downstream pressure at each fitting along the system
			  #Check for choked flow
			  #P1 = InletPress(nn)
			  #P2 = InletPress(nn + 1)
			  p1 = inlet_pressure[p]
			  p2 = inlet_pressure[p+1]
			  pressure_drop = p1 - p2
			  (0..1000).each do |r|
				  p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
				  part1 = 2 / (vapor_k +1)
				  part2 = (((p1 + barometric_pressure) / p2_critical) ** ((vapor_k + 1) / vapor_k)) -1
				  part3 = (2 / vapor_k) * Math.log((p1 + barometric_pressure) / p2_critical)
				  adiabatic_choke_kf = (part1 * part2) - part3
				  if sumkff <= adiabatic_choke_kf
					  r = 1000
				  end
			  end
			  # Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
		  end
		  #TODO pressure drop is generating complex number
		  #using a work around to change to to float by taking real part of complex number
		  if condition_basis == 'max'
		  	circuit_piping.update_attributes(:delta_p_max => pressure_drop.real.to_f)
		  elsif condition_basis == 'min'
		  	circuit_piping.update_attributes(:delta_p_min => pressure_drop.real.to_f)
		  else
		  	circuit_piping.update_attributes(:delta_p_nor => pressure_drop.real.to_f)
		  end
	  end
	  return {:success => true }
  end

  def self.cvfe_inlet_side_hydraulics_two_phase(flow_element,pipings,condition_basis)
	  project = flow_element.project
	  pipeid                     = (1..100).to_a
	  flow_percentage            = (1..100).to_a
	  reynold_number             = (1..100).to_a
	  ft                         = (1..100).to_a
	  kfi                        = (1..100).to_a
	  dover_di                   = (1..100).to_a
	  nre                        = (1..100).to_a
	  kfii                       = (1..100).to_a
	  kfd                        = (1..100).to_a
	  f                          = (1..100).to_a
	  kff                        = (1..100).to_a
	  dover_dii                  = (1..100).to_a
	  pressure_drop              = (1..100).to_a
	  inlet_press                = (1..100).to_a
	  inlet_temp                 = (1..100).to_a
	  section_outlet_pressure    = (1..100).to_a
	  section_outlet_temperature = (1..100).to_a
	  fitting_s                  = (1..100).to_a
	  fitting_dp                 = (1..100).to_a
	  dukler_density             = (1..1000).to_a
	  dukler_reynold             = (1..1000).to_a
	  r1                         = (1..1000).to_a
	  equivalent_length          = (1..1000).to_a
	  pi = 3.14159265358979

	  barometric_pressure = project.barometric_pressure
	  pipe_roughness = project.pipes[0].roughness_recommended
	  e = pipe_roughness

	  if condition_basis == 'max'
		  mass_flow_rate      = flow_element.up_max_mass_flow_rate
		  mass_vapor_fraction = flow_element.up_max_mass_vapor_fraction
		  liquid_density      = flow_element.up_max_lp_density
		  liquid_viscosity    = flow_element.up_max_lp_viscosity
		  vapor_density       = flow_element.up_max_vp_density
		  vapor_viscosity     = flow_element.up_max_vp_viscosity
	  elsif condition_basis == 'min'
		  mass_flow_rate      = flow_element.up_min_mass_flow_rate
		  mass_vapor_fraction = flow_element.up_min_mass_vapor_fraction
		  liquid_density      = flow_element.up_min_lp_density
		  liquid_viscosity    = flow_element.up_min_lp_viscosity
		  vapor_density       = flow_element.up_min_vp_density
		  vapor_viscosity     = flow_element.up_min_vp_viscosity
	  else
		  mass_flow_rate      = flow_element.up_nor_mass_flow_rate
		  mass_vapor_fraction = flow_element.up_nor_mass_vapor_fraction
		  liquid_density      = flow_element.up_nor_lp_density
		  liquid_viscosity    = flow_element.up_nor_lp_viscosity
		  vapor_density       = flow_element.up_nor_vp_density
		  vapor_viscosity     = flow_element.up_nor_vp_viscosity
	  end
	stream_quality = mass_vapor_fraction
	stream_liquid_flow_rate = (1 - stream_quality) * mass_flow_rate
	stream_vapor_flow_rate = stream_quality * mass_flow_rate

	if project.two_phase_flow_model == 'Dukler'
		#determine volumetric flow rate
		ql = stream_liquid_flow_rate / liquid_density
		qg = stream_vapor_flow_rate / vapor_density
		qm = ql + qg
		volume_rate = qm

		#Determine liquid inlet resistance and physical properties
		liquid_resistance = ql / qm
		m_density = (liquid_density * liquid_resistance) + vapor_density * (1 - liquid_resistance)
		m_viscosity = (liquid_viscosity * liquid_resistance) + vapor_viscosity * (1 - liquid_resistance)

		circuit_pipings = pipings
		count = circuit_pipings.length
		(0..count-1).each do |p|
			circuit_piping = circuit_pipings[p]
			fitting           = circuit_piping.fitting
			fitting_tag       = circuit_piping.fitting_tag
			pipe_size         = circuit_piping.pipe_size
			pipe_schedule     = circuit_piping.pipe_schedule
			pipe_id           = circuit_piping.pipe_id
			per_flow          = circuit_piping.per_flow
			fitting_length    = circuit_piping.length
			fitting_elevation = circuit_piping.elev

			est_pipe = pipe_id
			est_area = pi * (est_pipe / 2) ** 2

			#Determine Vapor and liquid superficial velocity
			vsg = 0.04 * (qg / est_area)
			vsl = 0.04 * (ql / est_area)
			vm = vsg + vsl

			r1[1] = liquid_resistance

			(1..1000).each do |i|
				part1 = (liquid_density * liquid_resistance ** 2) / r1[i]
				part2 = (vapor_density * (1 - liquid_resistance) ** 2 ) / (1 - r1[i])
				dukler_density[i] = part1 + part2
				dukler_reynold[i] = (dukler_density[i] * vm * (est_pipe / 12)) / (0.000671969 * m_viscosity)
                #To maintain a bubble/froth flow regime and give economical pipe sizes
				if dukler_reynold[i] > 0.2 * 10 ** 6
					r1[i + 1] = liquid_resistance
				else
					reynold = dukler_reynold[i]
					liquid_fraction = liquid_resistance
					#liquid_holdup = self.liquid_resist(reynold,liquid_fraction) #need to implement this method
					#TODO taking dummy value
					liquid_holdup = 10.0
				end

				if r1[i+1] = r1[i]
					d_reynolds = dukler_reynold[i]
					d_density = dukler_density[i]
					#i = 1000
					break
				elsif ((r1[i +1] - r1[i]).abs / r1[i]) * 100 < 0.00001
					d_reynolds = dukler_reynold[i]
					d_density = dukler_density[i]
					#i = 1000
					break
				end
			end
 			#Determine single phase friction factor
  			#s = 1.281 + 0.478 * Log(LiquidResistance) + 0.444 * (Log(LiquidResistance)) ^ 2 + 0.09399999 * 
			#(Log(LiquidResistance)) ^ 3 + 0.0084330001 * (Log(LiquidResistance)) ^ 4
			log_lr = Math.log(liquid_resistance)
			s = 1.281 + 0.478 * log_lr + 0.444 * log_lr ** 2 + 0.09399999 * log_lr ** 3 + 0.0084330001 * log_lr ** 4
		    #Determine two phase friction factor
			#TODO taking dummy value
			d_reynolds = 1.0
			ftpr = 1 - (log_lr / s)
			fo =  0.0014 + (0.125 / d_reynolds ** 0.32)
			ftp = ftpr * fo

			fitting_type = PipeSizing.get_fitting_tag(circuit_piping.fitting)[:value]
			d = pipe_id
			d1 = pipe_id
			d2 = pipe_id
			dorifice = circuit_piping.ds_cv
			cv = circuit_piping.ds_cv

    		#'Determine pressure drop due to friction
			fd = 4 * ftp
			nreynolds = d_reynolds

			if fitting_type == 'Pipe'
				kf = 4 * ftp * (fitting_length / (d / 12))
				equivalent_length[p] = fitting_length
			elsif fitting_type == 'Control Valve'
				kf = ((29.9 * d ** 2) / cv) ** 2
				equivalent_length[p] = (kf / ftp) * (d / 12)
			elsif fitting_type == 'Orifice'
				beta = dorifice / d
				if nreynolds <= 10 ** 4
					#UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientLR.Show
					#FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
					#TODO dummy value
					flow_c = 10.0
				elsif nreynolds > 4
					#ElseIf Nreynolds > 10 ^ 4 Then
					#UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientHR.Show
					#FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
					flow_c = 10.0
				end
				#Kf = (1 - Beta ^ 2) / (FlowC ^ 2 * Beta ^ 4)
				#Equivalentlength(jj) = (Kf / ftp) * (d / 12)
				kf = (1 - beta ** 2) / (flow_c ** 2 * beta ** 4)
				equivalent_length[p] = (kf / ftp) * (d / 12)
			else
				# Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)
				result = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)
				kf = result[:kf]
				# Equivalentlength(jj) = (Kf / ftp) * (d / 12)
				equivalent_length[p] = (kf / ftp) * (d / 12)
			end

			total_length = equivalent_length[p]
    		#DPf = 4 * (ftp / (144 * 32.2)) * (TotalLength / (d / 12)) * MDensity * (Vm ^ 2 / 2)
			dpf = 4 * (ftp / (144 * 32.2)) * (total_length / (d / 12)) * m_density * (vm ** 2 / 2)
			
			#'Determine pressure drop due to elevation
			if fitting_elevation > 0
				ht = fitting_elevation
			elsif fitting_elevation < 0
				ht = fitting_elevation * -1
			else 
				ht = 0
			end

			sum_elevation = ht
            #Omega = 0.76844 - 0.085389 * Vsg + 0.0041264 * Vsg ^ 2 - 0.000087165 * Vsg ^ 3 + 0.00000066422 * Vsg ^ 4
			omega = 0.76844 - 0.085389 * vsg + 0.0041264 * vsg ** 2 - 0.000087165 * vsg ** 3 + 0.00000066422 * vsg ** 4
			if vsg > 50
				omega = 0.04
			elsif vsg < 0.5
				omage = 0.85
			end

			#TODO pl, this was not used anywhere before in this calculation
			#taking dummy value for this
			pl = 1.0
			dpe = (omega * pl * sum_elevation) / 144

    		#'Determine pressure drop due to acceleration, Assumed no contribution
			dpa = 0

			#total pressure drop
			total_dp = dpf + dpe + dpa
			fitting_pressure = total_dp
			#save delta p
			#TODO total_dp is becoming infinite
			#if it is infinite saving dummy value of 10.0
			total_dp = 10.0 if total_dp.nan?
			if condition_basis == 'max'
				circuit_piping.update_attributes(:delta_p_max => total_dp)
			elsif condition_basis == 'min'
				circuit_piping.update_attributes(:delta_p_min=> total_dp)
			else
				circuit_piping.update_attributes(:delta_p_nor=> total_dp)
			end
		end
	elsif project.two_phase_flow_model == "Lockhart-Martinelli"
		#determine volumetric flow rate
		ql = stream_liquid_flow_rate / liquid_density
		qg = stream_vapor_flow_rate / vapor_density
		qm = ql + qg
		volume_rate = qm
		circuit_pipings = pipings
		count = circuit_pipings.length
		(0..count-1).each do |p|
		    circuit_piping = circuit_pipings[p]
			fitting           = circuit_piping.fitting
			fitting_tag       = circuit_piping.fitting_tag
			pipe_size         = circuit_piping.pipe_size
			pipe_schedule     = circuit_piping.pipe_schedule
			pipe_id           = circuit_piping.pipe_id
			per_flow          = circuit_piping.per_flow
			fitting_length    = circuit_piping.length
			fitting_elevation = circuit_piping.elev
			est_pipe = pipe_id
			est_area = pi * (est_pipe / 2) ** 2

			#Determine Vapor and liquid superficial velocity
			vsg = 0.04 * (qg / est_area)
			vsl = 0.04 * (ql / est_area)
			vm = vsg + vsl
			#errosion corrosion index test
			wl = stream_liquid_flow_rate
			wg = stream_vapor_flow_rate
			pm = (wl + wg) / (ql + wg)
			area_ft2 = est_area / 144
			ul = liquid_viscosity
			ug = vapor_viscosity
			pl = liquid_density
			pg = vapor_density

			nrel = (pl * vsl * (est_pipe / 12)) / (0.000671969 * ul)
			nreg = (pg * vsg * (est_pipe / 12)) / (0.666671969 * ug)

			#Determine liquid pressure drop
			#Determine new friction factor using Churchill's equation
			a = (2.457 * Math.log(1 / (((7 / nrel) ** 0.9) + (0.27 * (e / est_pipe))))) ** 16
			b = (37530 / nrel) ** 16
			fl = 2 * ((8 / nrel) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)

			#Determine Vapor Pressure Drop
    		#Determine new friction factor using Churchill's equation
    		a = (2.457 * Math.log(1 / (((7 / nreg) ** 0.9) + (0.27 * (e / est_pipe))))) ** 16
    		b = (37530 / nreg) ** 16
    		fg = 2 * ((8 / nreg) ** 12 + (1 / ((a + b) **  (3 / 2)))) ** (1 / 12)

		    delta_pl_per_length = ((3.36 * 10 ** -6) * fl * wl ** 2) / ((est_pipe) ** 5 * pl)
            delta_pg_per_length = ((3.36 * 10 ** -6) * fg * wg ** 2) / ((est_pipe) ** 5 * pg)	

            x = (delta_pl_per_length / delta_pg_per_length) ** 0.5
			#'Determine stream flow regime
			#TODO need review
			#    If Worksheets("Preliminary Size - Results").Cells(4, 1).Value = ProcessBasis Then
			#        For iix = 1 To 3000
			#            If Worksheets("Preliminary Size - Results").Cells(11 + iix, 2).Value = StreamNo Then
			#            FlowRegime = Worksheets("Preliminary Size - Results").Cells(11 + iix, 13).Value
			#            iix = 3000
			#            Else
			#            End If
			#            If Worksheets("Preliminary Size - Results").Cells(11 + iix, 2).Value = "" Then
			#            iix = 3000
			#            Else
			#            End If
			#        Next iix
			#    Else
			#    msg1 = MsgBox("Is the flow regime for stream " & StreamNo & " in process basis (" & ProcessBasis & ") wavy.  Click YES for Wavy, Click NO for not Wavy.", vbYesNo, "Wavy Flow Regime For Two Phase Flow?")
			#        If msg1 = vbYes Then
			#        FlowRegime = "Wave"
			#        ElseIf msg1 = vbNo Then
			#        FlowRegime = "Others"
			#        Else
			#        End If
			#    End If
			#    
			#    If FlowRegime = "" Then
			#    msg1 = MsgBox("Is the flow regime for stream " & StreamNo & " in process basis (" & ProcessBasis & ") wavy.  Click YES for Wavy, Click NO for not Wavy.", vbYesNo, "Wavy Flow Regime For Two Phase Flow?")
			#        If msg1 = vbYes Then
			#        FlowRegime = "Wave"
			#        ElseIf msg1 = vbNo Then
			#        FlowRegime = "Others"
			#        Else
			#        End If
			#    Else
			#    End If
 				#determine omega for all flow regime
                stratified_omega = (15400 * x) / (wl / area_ft2) ** 0.8
                bubble_froth_omega = (14.2 * x ** 0.75) / (wl / area_ft2) ** 0.1
                slug_omega = (1190 * x ** 0.815) / (wl / area_ft2) ** 0.5

                hx = (wl / wg) * (ul / ug)
                fh = Math.exp((0.211 * Math.log(hx)) - 3.993)
                delta_ptp_per_length = ((3.36 * 10 ** -6) * fh * wg ** 2) / ((est_pipe) ** 5 * pg)
                
                if est_pipe >= 12 
                    est_pipe = 10
                end

                    aa = 4.8 - 0.3125 * est_pipe
                    bb = 0.343 - 0.021 * est_pipe
                    annular_omega = aa * x ** bb

                    c0 = 1.4659
                    c1 = 0.49138
                    c2 = 0.04887
                    c3 = -0.000349
                    dispersed_spray_mist_omega = Math.exp((c0 + c1 * Math.log(x) + c2 * (Math.log(x)) ** 2 + c3 * (Math.log(x)) ** 3))
                    plug_omega = (27.315 * x ** 0.855) / (wl / area_ft2) ** 0.17

					#TODO takind dummy value
					flow_regime = "Slug"

                    #Determine Omega for select flow regime
                    if flow_regime == "Stratified"
                      omega = stratified_omega
                    elsif flow_regime == "Bubble/Froth"
                      omega = bubble_froth_omega
                    elsif flow_regime == "Slug"
                      omega = slug_omega
                    elsif flow_regime == "Wave"
                    elsif flow_regime == "Annular"
                      omega = annular_omega
                    elsif flow_regime == "Dispersed/Spray/Mist"
                      omega = dispersed_spray_mist_omega
                    elsif flow_regime == "Plug"
                      omega = plug_omega
                    end
                    
                    if flow_regime != "Wave"
                      delta_ptp_per_length = delta_pg_per_length * omega ** 2
                    end

			fitting_type = PipeSizing.get_fitting_tag(circuit_piping.fitting)[:value]
			d = pipe_id
			d1 = pipe_id
			d2 = pipe_id
			dorifice = circuit_piping.ds_cv
			cv = circuit_piping.ds_cv

			fd = 4 * fg
			nreynolds = nreg

			if fitting_type == 'Pipe'
				kf = 4 * fg * (fitting_length / (d / 12))
				equivalent_length[p] = fitting_length
			elsif fitting_type == 'Control Valve'
				kf = ((29.9 * d ** 2) / cv) ** 2
				equivalent_length[p] = (kf / fg) * (d / 12)
			elsif fitting_type == 'Orifice'
				beta = dorifice / d
				if nreynolds <= 10 ** 4
					#UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientLR.Show
					#FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
					#TODO dummy value
					flow_c = 10.0
				elsif nreynolds > 4
					#ElseIf Nreynolds > 10 ^ 4 Then
					#UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientHR.Show
					#FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
					flow_c = 10.0
				end
				#Kf = (1 - Beta ^ 2) / (FlowC ^ 2 * Beta ^ 4)
				#Equivalentlength(jj) = (Kf / fg) * (d / 12)
				kf = (1 - beta ** 2) / (flow_c ** 2 * beta ** 4)
				equivalent_length[p] = (kf / fg) * (d / 12)
			else
				# Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)module 7
				# Equivalentlength(jj) = (Kf / fg) * (d / 12)
				result = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)
				kf = result[:kf]
				equivalent_length[p] = (kf / fg) * (d / 12)
			end

			total_length = equivalent_length[p]
    		tp_horizontal_deltap = delta_ptp_per_length * total_length
			#pressure drop due to elevation
			fe = (0.00967 * (wl / area_ft2) ** 0.5) / (vsg) ** 0.7

			if fitting_elevation > 0
				sum_elevation = fitting_elevation
			end
		    #TPElevationDeltaP = (SumElevation * FE * PL) / 144
			tp_elevation_deltap = (sum_elevation * fe * pl) / 144
			#Pressure drop due to acceleration, Assumed equal 0
    		tp_acceleration_deltap = 0
			total_dp = tp_horizontal_deltap + tp_elevation_deltap + tp_acceleration_deltap
			#save delta p
			#TODO total_dp is becoming infinity
			#so storing 10.0 when it is becoming infinity
			total_dp = 10.0 if total_dp.nan?
			if condition_basis == 'max'
				circuit_piping.update_attributes(:delta_p_max => total_dp)
			elsif condition_basis == 'min'
				circuit_piping.update_attributes(:delta_p_min=> total_dp)
			else
				circuit_piping.update_attributes(:delta_p_nor=> total_dp)
			end
		end
	end
	return {:success => true}
  end

  def calculate_and_save_delta_ps(params)
	 unit_decimals = self.project.project_units
	  
	  if params[:up_condition_basis] == 'max'
	  #assuming 51 for fitting type orifice
	  orifice_dp = self.suction_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 51])
	  #assuming 49 for fitting type equipment
	  equipment_dp = self.suction_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 49])
	  #assuming 52 for fitting type control valve
	  control_valve_dp = self.suction_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 52])
	  fitting_dp = self.suction_pipings.sum(:delta_p_max)
	  total_suction_dp = orifice_dp+equipment_dp+control_valve_dp+fitting_dp
		  self.update_attributes(:up_max_fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_max_equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_max_control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_max_orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_max_total_upstream_dp => total_suction_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i)
								)
	  elsif params[:up_condition_basis] == 'min'
 	  #assuming 51 for fitting type orifice
	  orifice_dp = self.suction_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 51])
	  #assuming 49 for fitting type equipment
	  equipment_dp = self.suction_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 49])
	  #assuming 52 for fitting type control valve
	  control_valve_dp = self.suction_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 52])
	  fitting_dp = self.suction_pipings.sum(:delta_p_min)
	  total_suction_dp = orifice_dp+equipment_dp+control_valve_dp+fitting_dp
		  self.update_attributes(:up_min_fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_min_equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_min_control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_min_orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_min_total_upstream_dp => total_suction_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i)
								)
      elsif params[:up_condition_basis] == 'nor'
 	  #assuming 51 for fitting type orifice
	  orifice_dp = self.suction_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 51])
	  #assuming 49 for fitting type equipment
	  equipment_dp = self.suction_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 49])
	  #assuming 52 for fitting type control valve
	  control_valve_dp = self.suction_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 52])
	  fitting_dp = self.suction_pipings.sum(:delta_p_nor)

	  total_suction_dp = orifice_dp+equipment_dp+control_valve_dp+fitting_dp
		  self.update_attributes(:up_nor_fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_nor_equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_nor_control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_nor_orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
								 :up_nor_total_upstream_dp => total_suction_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i)
								)
	  end
  end

  #convert values
  def convert_values(multiply_factor,project)
    #Upstream
    self.up_max_pressure = (self.up_max_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_temperature = project.convert_temperature(:value => self.up_max_temperature, :subtype => "General")
    self.up_max_mass_flow_rate = (self.up_max_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.up_max_vp_density = (self.up_max_vp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_max_vp_viscosity = (self.up_max_vp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_max_lp_density = (self.up_max_lp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_max_lp_viscosity = (self.up_max_lp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_max_lp_surface_tension = (self.up_max_lp_surface_tension.to_f * multiply_factor["Surface Tension"]["General"].to_f) if !multiply_factor["Surface Tension"].nil?
    self.up_max_lp_critical_pressure = (self.up_max_lp_critical_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_lp_vapor_pressure = (self.up_max_lp_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_pressure = (self.up_nor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_temperature = project.convert_temperature(:value => self.up_nor_temperature, :subtype => "General")
    self.up_nor_mass_flow_rate = (self.up_nor_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.up_nor_vp_density = (self.up_nor_vp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_nor_vp_viscosity = (self.up_nor_vp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_nor_lp_density = (self.up_nor_lp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_nor_lp_viscosity = (self.up_nor_lp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_nor_lp_surface_tension = (self.up_nor_lp_surface_tension.to_f * multiply_factor["Surface Tension"]["General"].to_f) if !multiply_factor["Surface Tension"].nil?
    self.up_nor_lp_critical_pressure = (self.up_nor_lp_critical_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_lp_vapor_pressure = (self.up_nor_lp_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_pressure = (self.up_min_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_temperature = project.convert_temperature(:value => self.up_min_temperature, :subtype => "General")
    self.up_min_mass_flow_rate = (self.up_min_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.up_min_vp_density = (self.up_min_vp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_min_vp_viscosity = (self.up_min_vp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_min_lp_density = (self.up_min_lp_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.up_min_lp_viscosity = (self.up_min_lp_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
    self.up_min_lp_surface_tension = (self.up_min_lp_surface_tension.to_f * multiply_factor["Surface Tension"]["General"].to_f) if !multiply_factor["Surface Tension"].nil?
    self.up_min_lp_critical_pressure = (self.up_min_lp_critical_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_lp_vapor_pressure = (self.up_min_lp_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    
    self.up_max_fitting_dp = (self.up_max_fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_equipment_dp = (self.up_max_equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_control_valve_dp = (self.up_max_control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_orifice_dp = (self.up_max_orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_total_upstream_dp = (self.up_max_total_upstream_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_max_pressure_at_inlet_flange = (self.up_max_pressure_at_inlet_flange.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?

    self.up_min_fitting_dp = (self.up_min_fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_equipment_dp = (self.up_min_equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_control_valve_dp = (self.up_min_control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_orifice_dp = (self.up_min_orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_total_upstream_dp = (self.up_min_total_upstream_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_min_pressure_at_inlet_flange = (self.up_min_pressure_at_inlet_flange.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
 
    self.up_nor_fitting_dp = (self.up_nor_fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_equipment_dp = (self.up_nor_equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_control_valve_dp = (self.up_nor_control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_orifice_dp = (self.up_nor_orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_total_upstream_dp = (self.up_nor_total_upstream_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.up_nor_pressure_at_inlet_flange = (self.up_nor_pressure_at_inlet_flange.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        
    suction_pipings.where(:tab=>"upstream").each do |suction_piping|
      suction_piping.pipe_id = (suction_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.length = (suction_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.elev = (suction_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      suction_piping.delta_p = (suction_piping.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      suction_piping.outlet_pressure = (suction_piping.outlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      suction_piping.save      
    end
        
    #Downstream
    control_valve_downstreams.each do |control_valve_downstream|
      control_valve_downstream.destination_pressure = (control_valve_downstream.destination_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      control_valve_downstream.fitting_dp = (control_valve_downstream.fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      control_valve_downstream.equipment_dp = (control_valve_downstream.equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      control_valve_downstream.control_valve_dp = (control_valve_downstream.control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      control_valve_downstream.orifice_dp = (control_valve_downstream.orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      control_valve_downstream.total_system_dp = (control_valve_downstream.total_system_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      control_valve_downstream.pressure_at_outlet_flange = (control_valve_downstream.pressure_at_outlet_flange.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
              
      control_valve_downstream.save
      
      control_valve_downstream.control_valve_downstream_circuit_pipings do |control_valve_downstream_circuit_piping|
        control_valve_downstream_circuit_piping.pipe_id = (control_valve_downstream_circuit_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
        control_valve_downstream_circuit_piping.length = (control_valve_downstream_circuit_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        control_valve_downstream_circuit_piping.elev = (control_valve_downstream_circuit_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        control_valve_downstream_circuit_piping.delta_p = (control_valve_downstream_circuit_piping.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        control_valve_downstream_circuit_piping.inlet_pressure = (control_valve_downstream_circuit_piping.inlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        
        control_valve_downstream_circuit_piping.save
      end
    end
        
    #Control Valve Design
    self.cvs_cv_body_size = (self.cvs_cv_body_size.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.cvs_trim_size = (self.cvs_trim_size.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.cvs_travel = (self.cvs_travel.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.cvs_min_differential_pressure = (self.cvs_min_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.cvs_nor_differential_pressure = (self.cvs_nor_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.cvs_max_differential_pressure = (self.cvs_max_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    
    #Bypass Design
    self.cvb_line_size = (self.cvb_line_size.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
    self.cvb_body_size = (self.cvb_body_size.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
        
    save    
  end

#TODO updated paths for downstream circuits
  def update_downstream_circuits_path    
    self.downstream_maximum.each do |downstream|
      rs_hds = self.control_valve_downstreams.where(:path => downstream.path)
      path_ar = {}
      rs_hds.each do |hd|
        path_ar[hd.downstream_condition_basis] = hd.id
      end
      
      downstream.control_valve_downstream_circuit_pipings.each do |dcp|
        dcp.downstream_maximum_path_id = path_ar['maximum']
        dcp.downstream_normal_path_id = path_ar['normal']  
        dcp.downstream_minimum_path_id = path_ar['minimum']
        dcp.save        
      end
    end   
  end


end
