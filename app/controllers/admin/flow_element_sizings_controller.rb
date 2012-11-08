class Admin::FlowElementSizingsController < AdminController
  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]
  
  def index
    @flow_element_sizings = @company.flow_element_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
    
    if @user_project_settings.client_id.nil?     
      flash[:error] = "Please Update Project Setting"      
      redirect_to admin_sizings_path
    end
  end
  
  def new
    @flow_element_sizing = @company.flow_element_sizings.new
  end
  
  def create
    flow_element_sizing = params[:flow_element_sizing]
    flow_element_sizing[:created_by] = flow_element_sizing[:updated_by] = current_user.id    
    @flow_element_sizing = @company.flow_element_sizings.new(flow_element_sizing)   
    
    if !@flow_element_sizing.up_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@flow_element_sizing.up_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
    
    if @flow_element_sizing.save
      @flow_element_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      flash[:notice] = "New flow element sizing created successfully."
      redirect_to admin_flow_element_sizings_path
    else
      render :new
    end
  end
  
  def edit
    @flow_element_sizing = @company.flow_element_sizings.find(params[:id])    
    
    if !@flow_element_sizing.up_process_basis_id.nil?     
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@flow_element_sizing.up_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
  end
  
  def update
    flow_element_sizing = params[:flow_element_sizing]
    flow_element_sizing[:updated_by] = current_user.id
    
    @flow_element_sizing = @company.flow_element_sizings.find(params[:id])    
            
    if !@flow_element_sizing.up_process_basis_id.nil?      
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@flow_element_sizing.up_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
        
    if @flow_element_sizing.update_attributes(flow_element_sizing)
      flash[:notice] = "Updated flow element sizing successfully."
      if params[:commit] == "Update"
        redirect_to admin_flow_element_sizings_path     
      elsif       
        redirect_to edit_admin_flow_element_sizing_path(:anchor => params[:tab], :calculate_btn=>params[:calculate_btn])
      end             
    else      
      render :edit
    end
  end
  
  def destroy
    @flow_element_sizing = @company.flow_element_sizings.find(params[:id])
    if @flow_element_sizing.destroy
      flash[:notice] = "Deleted #{@flow_element_sizing.flow_element_tag} successfully."
      redirect_to admin_flow_element_sizings_path
    end
  end

   def clone
	  @flow_element_sizing = @company.flow_element_sizings.find(params[:id])
	  new = @flow_element_sizing.clone :except => [:created_at, :updated_at]
	  new.flow_element_tag = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_flow_element_sizing_path(new) }
	  else
		  render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
	  end
	  return
  end

 
  def get_stream_values
    form_values = {}
    
    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    property = heat_and_meterial_balance.heat_and_material_properties
    
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first    
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure] = pressure_stream.stream_value.to_f rescue nil
    
    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature] = temperature_stream.stream_value.to_f rescue nil
    
    mass_flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    mass_flow_rate_stream = mass_flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_flow_rate] = mass_flow_rate_stream.stream_value.to_f rescue nil
    
    mass_vapour_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    mass_vapour_fraction_stream = mass_vapour_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_vapour_fraction] = mass_vapour_fraction_stream.stream_value.to_f rescue nil
    
    vp_density = property.where(:phase => "Vapour", :property => "Mass Density").first
    vp_density_stream = vp_density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vp_density] = vp_density_stream.stream_value.to_f rescue nil
    
    vp_viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
    vp_viscosity_stream = vp_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vp_viscosity] = vp_viscosity_stream.stream_value.to_f rescue nil
    
    lp_density = property.where(:phase => "Light Liquid", :property => "Mass Density").first
    lp_density_stream = lp_density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:lp_density] = lp_density_stream.stream_value.to_f rescue nil
    
    lp_viscosity = property.where(:phase => "Light Liquid", :property => "Viscosity").first
    lp_viscosity_stream = lp_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:lp_viscosity] = lp_viscosity_stream.stream_value.to_f rescue nil
    
    render :json => form_values
  end
  
  def get_discharge_stream_nos
    form_values = {}
    
    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    property = heat_and_meterial_balance.heat_and_material_properties
    
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first    
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure] = pressure_stream.stream_value.to_f rescue nil
    
    render :json => form_values
  end
  
  def flow_element_sizing_summary
    @flow_element_sizings = @company.flow_element_sizings.all    
  end
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
    @breadcrumbs << { :name => 'Flow Element sizing', :url => admin_flow_element_sizings_path }
  end

  def upstream_calculate
	  flow_element = FlowElementSizing.find(params[:flow_element_sizing_id])
	  project = flow_element.project

	  ['max','min','nor'].each do |basis|

		  stream_phase = flow_element.up_max_stream_phase if basis == 'max'
		  stream_phase = flow_element.up_min_stream_phase if basis == 'min'
		  stream_phase = flow_element.up_nor_stream_phase if basis == 'nor'

		  flow_rate_basis = project.control_flow_bias_max #from project setup

		  if stream_phase == 'Liquid'
			  ControlValveSizing.cvfe_inlet_side_hydraulics_liquid(flow_element,flow_element.suction_pipings,basis) 
		  elsif stream_phase == 'Vapor'
			  ControlValveSizing.cvfe_inlet_side_hydraulics_vapor(flow_element,flow_element.suction_pipings,basis)
		  elsif stream_phase == 'Bi-Phase'
			  ControlValveSizing.cvfe_inlet_side_hydraulics_two_phase(flow_element,flow_element.suction_pipings,basis)
		  end
		  
		end
   
   #calculate fitting DP, Equipment DP, Control Valve DP, Orifice DP
   #51 for fitting type 'orifice'
   orifice_dp_max = flow_element.suction_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 51])
   orifice_dp_nor = flow_element.suction_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 51])
   orifice_dp_min = flow_element.suction_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 51])
   
   #49 for fitting type 'equipment'
   equipment_dp_max = flow_element.suction_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 49])
   equipment_dp_nor = flow_element.suction_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 49])
   equipment_dp_min = flow_element.suction_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 49])
   
   #52 for fitting type 'control valve'
   control_valve_dp_max = flow_element.suction_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 52])
   control_valve_dp_nor = flow_element.suction_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 52])
   control_valve_dp_min = flow_element.suction_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 52])

   fitting_dp_max = flow_element.suction_pipings.sum(:delta_p_max)
   fitting_dp_nor = flow_element.suction_pipings.sum(:delta_p_nor)
   fitting_dp_min = flow_element.suction_pipings.sum(:delta_p_min)

   total_dp_max = orifice_dp_max + equipment_dp_max + control_valve_dp_max + fitting_dp_max
   total_dp_nor = orifice_dp_nor + equipment_dp_nor + control_valve_dp_nor + fitting_dp_nor
   total_dp_min = orifice_dp_max + equipment_dp_max + control_valve_dp_max + fitting_dp_min
   
   pressure_at_inlet_flange_dp_max = flow_element.up_max_pressure - total_dp_max
   pressure_at_inlet_flange_dp_nor = flow_element.up_nor_pressure - total_dp_nor
   pressure_at_inlet_flange_dp_min = flow_element.up_min_pressure - total_dp_min
   
   flow_element.update_attributes(
      :up_il_max_fitting_dp => fitting_dp_max.round(4),
      :up_il_max_equipment_dp => equipment_dp_max.round(4),
      :up_il_max_control_valve_dp => control_valve_dp_max.round(4),
      :up_il_max_orifice_dp => orifice_dp_max.round(4),
      :up_il_max_total_suction_dp => total_dp_max.round(4),
      :up_il_max_pressure_at_inlet_flange_dp => pressure_at_inlet_flange_dp_max.round(4),
      
      :up_il_nor_fitting_dp => fitting_dp_nor.round(4),
      :up_il_nor_equipment_dp => equipment_dp_nor.round(4),
      :up_il_nor_control_valve_dp => control_valve_dp_nor.round(4),
      :up_il_nor_orifice_dp => orifice_dp_nor.round(4),
      :up_il_nor_total_suction_dp => total_dp_nor.round(4),
      :up_il_nor_pressure_at_inlet_flange_dp => pressure_at_inlet_flange_dp_nor.round(4),
      
      :up_il_min_fitting_dp => fitting_dp_min.round(4),
      :up_il_min_equipment_dp => equipment_dp_min.round(4),
      :up_il_min_control_valve_dp => control_valve_dp_min.round(4),
      :up_il_min_orifice_dp => orifice_dp_min.round(4),
      :up_il_min_total_suction_dp => total_dp_min.round(4),
      :up_il_min_pressure_at_inlet_flange_dp => pressure_at_inlet_flange_dp_min.round(4)
    )
    
	  render :json =>  {:success => true }
  end

  def downstream_calculate
  
	  flow_element = FlowElementSizing.find(params[:flow_element_sizing_id])
	  project = flow_element.project
	  
	  pressure_differential = project.measure_unit("Pressure", "Differential")
	  pressure_general = project.measure_unit("Pressure", "General")
	  
	  flow_element.flow_element_downstreams.each do |downstream|
		  pipings = downstream.flow_element_downstream_circuit_pipings
		  ['max','min','nor'].each do |basis|
			  stream_phase = flow_element.up_max_stream_phase
			  flow_rate_basis = project.control_flow_bias_max #from project setup
			  if stream_phase == 'Liquid'
				  ControlValveSizing.cvfe_inlet_side_hydraulics_liquid(flow_element,pipings,basis) 
			  elsif stream_phase == 'Vapor'
				  ControlValveSizing.cvfe_inlet_side_hydraulics_vapor(flow_element,pipings,basis)
			  elsif stream_phase == 'Bi-Phase'
				  ControlValveSizing.cvfe_inlet_side_hydraulics_two_phase(flow_element,pipings,basis)
				end        
		  end
		end
   
    #51 for fitting type 'orifice'
    #49 for fitting type 'equipment'
    #52 for fitting type 'control valve'
    
    flow_element.downstream_maximum.each do |dmax|
      orifice_dp_max = FlowElementDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 51])
      equipment_dp_max = FlowElementDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 49])
      control_valve_dp_max = FlowElementDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 52])
      fitting_dp_max = FlowElementDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max)
      
      total_dp_max = fitting_dp_max + equipment_dp_max + control_valve_dp_max + orifice_dp_max
      pressure_at_discharge_nozzle = total_dp_max.to_f + dmax.destination_pressure.to_f
            
      dmax.update_attributes(          
        :fitting_dp => fitting_dp_max.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_max.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_max.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_max.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_max.round(pressure_general[:decimal_places]),
        :pressure_at_outlet_flange => pressure_at_discharge_nozzle.round(pressure_general[:decimal_places])        
      )
      dmax.save          
    end
    
    flow_element.downstream_normal.each do |dnor|
      orifice_dp_nor = FlowElementDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 51])
      equipment_dp_nor = FlowElementDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 49])
      control_valve_dp_nor = FlowElementDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 52])
      fitting_dp_nor = FlowElementDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor)
      
      total_dp_nor = fitting_dp_nor + equipment_dp_nor + control_valve_dp_nor + orifice_dp_nor
      pressure_at_discharge_nozzle = total_dp_nor.to_f + dnor.destination_pressure.to_f
            
      dnor.update_attributes(          
        :fitting_dp => fitting_dp_nor.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_nor.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_nor.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_nor.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_nor.round(pressure_general[:decimal_places]),
        :pressure_at_outlet_flange => pressure_at_discharge_nozzle.round(pressure_general[:decimal_places])        
      )
      dnor.save          
    end
    
    flow_element.downstream_minimum.each do |dmin|
      orifice_dp_min = FlowElementDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 51])
      equipment_dp_min = FlowElementDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 49])
      control_valve_dp_min = FlowElementDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 52])
      fitting_dp_min = FlowElementDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min)
      
      total_dp_min = fitting_dp_min + equipment_dp_min + control_valve_dp_min + orifice_dp_min
      pressure_at_discharge_nozzle = total_dp_min.to_f + dmin.destination_pressure.to_f
            
      dmin.update_attributes(          
        :fitting_dp => fitting_dp_min.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_min.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_min.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_min.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_min.round(pressure_general[:decimal_places]),
        :pressure_at_outlet_flange => pressure_at_discharge_nozzle.round(pressure_general[:decimal_places])        
      )
      dmin.save          
    end
    
	  render :json =>  {:success => true }
  end

  def get_pipe_diameter
	  pipe_diameter = PipeSizing.determine_pipe_diameter(params[:pipe_size].to_f,params[:pipe_schedule])
	  render :json => {:pipe_diameter => pipe_diameter}
  end

  def get_orifice_types
	  render :json => orifice_types(params)
  end

  def orifice_design
	  flow_element_sizing = FlowElementSizing.find(params[:flow_element_sizing_id])
	  project        = flow_element_sizing.project	  

	  flow_rate      = (1..100).to_a
	  factor         = (1..100).to_a
	  co             = (0..10000).to_a
	  y              = (0..10000).to_a
	  beta           = (0..10000).to_a
	  r1             = (1..100).to_a
	  dukler_density = (1..100).to_a
	  dukler_reynold = (1..100).to_a

	  pi = 3.14159265358979

	  #TODO not sure where to get these values
	  minimum_factor = "" #from project minumum flow rate factor
	  normal_factor = "" #from project normal flow rate factor
	  maximum_factor = "" #from project maximum flow rate factor

	  orifice_type = flow_element_sizing.os_orifice_type
	  pipe_size = flow_element_sizing.os_pipe_size.to_f
	  pipe_schedule = flow_element_sizing.os_pipe_schedule
	  pipe_diameter = PipeSizing.determine_pipe_diameter(pipe_size.to_f,pipe_schedule)
	  barometric_pressure = project.barometric_pressure	  

	  ['max','min','nor'].each do |basis|
      
      if basis == 'max'
        p1                  = flow_element_sizing.up_il_max_pressure_at_inlet_flange_dp
			  t                   = flow_element_sizing.up_max_temperature
			  p2                  = flow_element_sizing.downstream_maximum.maximum(:pressure_at_outlet_flange)			 
			  stream_phase        = flow_element_sizing.up_max_stream_phase
			  vapor_mass_fraction = flow_element_sizing.up_max_mass_vapor_fraction
			  mass_flow_rate      = flow_element_sizing.up_max_mass_flow_rate
			  vapor_density       = flow_element_sizing.up_max_vp_density
			  vapor_viscosity     = flow_element_sizing.up_max_vp_viscosity
			  vapor_mx            = flow_element_sizing.up_max_vp_mw
			  vapor_k             = flow_element_sizing.up_max_vp_cp_cv
			  vapor_z             = flow_element_sizing.up_max_vp_z
			  liquid_density      = flow_element_sizing.up_max_lp_density
			  liquid_viscosity    = flow_element_sizing.up_max_lp_viscosity
			  surface_tension     = flow_element_sizing.up_max_lp_surface_tension     
			elsif basis == 'min'
        p1                  = flow_element_sizing.up_il_min_pressure_at_inlet_flange_dp
			  t                   = flow_element_sizing.up_nor_temperature
			  p2                  = flow_element_sizing.downstream_normal.maximum(:pressure_at_outlet_flange)
			  stream_phase        = flow_element_sizing.up_min_stream_phase
			  vapor_mass_fraction = flow_element_sizing.up_min_mass_vapor_fraction
			  mass_flow_rate      = flow_element_sizing.up_min_mass_flow_rate
			  vapor_density       = flow_element_sizing.up_min_vp_density
			  vapor_viscosity     = flow_element_sizing.up_min_vp_viscosity
			  vapor_mx            = flow_element_sizing.up_min_vp_mw
			  vapor_k             = flow_element_sizing.up_min_vp_cp_cv
			  vapor_z             = flow_element_sizing.up_min_vp_z
			  liquid_density      = flow_element_sizing.up_min_lp_density
			  liquid_viscosity    = flow_element_sizing.up_min_lp_viscosity
			  surface_tension     = flow_element_sizing.up_min_lp_surface_tension
		  else
 			  p1                  = flow_element_sizing.up_il_nor_pressure_at_inlet_flange_dp
			  t                   = flow_element_sizing.up_min_temperature
			  p2                  = flow_element_sizing.downstream_minimum.maximum(:pressure_at_outlet_flange)
			  stream_phase        = flow_element_sizing.up_nor_stream_phase
			  vapor_mass_fraction = flow_element_sizing.up_nor_mass_vapor_fraction
			  mass_flow_rate      = flow_element_sizing.up_nor_mass_flow_rate
			  vapor_density       = flow_element_sizing.up_nor_vp_density
			  vapor_viscosity     = flow_element_sizing.up_nor_vp_viscosity
			  vapor_mx            = flow_element_sizing.up_nor_vp_mw
			  vapor_k             = flow_element_sizing.up_nor_vp_cp_cv
			  vapor_z             = flow_element_sizing.up_nor_vp_z
			  liquid_density      = flow_element_sizing.up_nor_lp_density
			  liquid_viscosity    = flow_element_sizing.up_nor_lp_viscosity
			  surface_tension     = flow_element_sizing.up_nor_lp_surface_tension
			end
      
      #determine pressure ratio
		  delta_p = p1 - p2
		  pressure_ratio = delta_p / (p1 + barometric_pressure)
      
      nred = (6.31595 * mass_flow_rate) / (pipe_diameter * vapor_viscosity)
  		nreb = 0
      beta_value = 0
		  co_value = 0
      orifice_d = 0

		  if stream_phase == 'Vapor'
			  co[0] = 0.61
			  y[0] = 1
			  (1..10000).each do |p|
				  x = ((2.79926 * 10 ** -7) * mass_flow_rate ** 2) / (pipe_diameter ** 4 * y[p - 1] ** 2 * co[p - 1] ** 2 * vapor_density * delta_p)
				  beta[p] = (x / (1 + x)) ** (1 / 4)
				  nreb = nred / beta[p]

				  #Determine Discharge Coefficient (Infinitity) for Equation 10-10, Darby
				  if orifice_type == "Corner Taps"
					  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Flange Taps"
					  if pipe_diameter >= 2.3
						  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.09 * ((beta[p] ** 4)/(pipe_diameter * (1 - beta[p] ** 4))) - 0.0337 * (beta[p] ** 3 / pipe_diameter)
					  elsif pipe_diameter >= 2 and pipe_diameter <= 2.3
						  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.039 * ((beta[p] ** 4) / (1 - beta[p] ** 4)) - 0.0337 * (beta[p] ** 3 / pipe_diameter)
					  else
						  cinf = 0.6
					  end
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Radius Taps"
					  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.039 * ((beta[p] ** 4) / (1 - beta[p] ** 4)) - 0.0158 * beta[p] ** 3
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Pipe Taps"
					  cinf = 0.5959 + 0.461 * beta[p] ** 2.1 + 0.48 * beta[p] ** 8 + 0.039 * (beta[p] ** 4 / (1 - beta[p] ** 4))
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Machine Inlet" 
					  cinf = 0.995
					  b = 0
					  n = 0
				  elsif orifice_type == "Rough Cast Inlet"
					  cinf = 0.984
					  b = 0
					  n = 0
				  elsif orifice_type == "Rough Welded Sheet Iron Inlet"
					  cinf = 0.985
					  b = 0
					  n = 0
				  elsif orifice_type == "ASME Long Radius"
					  cinf = 0.9975
					  b = -6.53 * beta[p] ** 0.5
					  n = 0.5
				  elsif orifice_type == "ISA"
					  cinf = 0.99 - 0.2262 * beta[p] ** 4.1
					  b = 1708 - 8936 * beta[p] + 19779 * beta[p] ** 4.7
					  n = 1.15
				  elsif orifice_type == "Venturi Nozzle (ISA Inlet)"
					  cinf = 0.9858 - 0.195 * beta[p] ** 4.5
					  b = 0
					  n = 0
				  end

				  if pipe_size >= 2 and pipe_size <= 36
					  if orifice_type == "Radius Taps" || orifice_type == "Corner Taps" || orifice_type == "Flange Taps"
						  if beta[p] >= 0.2 and beta[p] <= 0.75
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 = "The Discharge Coefficient(Cd) cannot be automatically estimated based 
								  #on Miller (1983) correlation published in Table 10-1 (Darby, 1996))
								  #as the parameters falls outside the corresponding applicability and accuracy range." & Chr(13) & Chr(13)_ 
								  #& "Please enter the Orifice Discharge Coefficient (Co) for the " & OrificeType & " orifice with Beta of " 
								  #& Round(Beta(p), 3) & " 
								  #and a Reynold's Number of flow through the orifice " & Round(NreB, 0) & " as accurately as possible.
								  #Note that the previous value for Co is " & Round(Co(p - 1), 3) & "."
								  #UserFormOrificeCoefficient.lblBeta = Round(Beta(p), 2)
								  #UserFormOrificeCoefficient.lblPipeReynoldNumber = Round(NreB, 0)
								  #UserFormOrificeCoefficient.Show
								  #Co(p) = UserFormOrificeCoefficient.txtOrificeCoefficient.Value + 0
							  end
						  else
							  #message2 
						  end
					  elsif orifice_type == "Pipe Taps"
						  if beta[p] >= 0.2 and beta[p] <= 0.75
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2
							  end
						  else
							  #message2
						  end
					  end 
				  else
					  #message2 
				  end



				  if orifice_type == "Machine Inlet"
					  if pipe_size >= 2 and pipe_size <= 10
						  if beta[p] >= 0.4 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Rough Cast"
					  if pipe_size >= 4 and pipe_size <= 32
						  if beta[p] >= 0.4 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Rough Welded Sheet Iron Inlet"
					  if pipe_size >= 8 and pipe_size <= 48
						  if beta[p] >= 0.4 and beta[p] <= 0.7
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "ASME"
					  if pipe_size >= 2 and pipe_size <= 16
						  if beta[p] >= 0.25 and beta[p] <= 0.7
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "ISA"
					  if pipe_size >= 2 and pipe_size <= 20
						  if beta[p] >= 0.3 and beta[p] <= 0.75
							  if nred >= 10 ** 5 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Venturi Nozzle"
					  if pipe_size >= 3 and pipe_size <= 20
						  if beta[p] >= 0.3 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= (2 * 10 ** 6)
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  end


				  #Pipe Tap, Equation 10-17, Equation 10-18 Darby
				  if orifice_type == 'Radius Taps'
					  y[p] = 1 - ((delta_p / (vapor_k * (p1 + barometric_pressure))) * (0.41 + 0.35 * beta[p] ** 4))
				  elsif orifice_type == 'Pipe Taps'
					  y[p] = 1 - ((delta_p / (vapor_k * (p1 + barometric_pressure))) * (0.333 + (1.145 * (beta[p] ** 2 + 0.7 * beta[p] ** 5 + 12 * beta[p] ** 13))))
				  else
					  #message1 = "No correlation is available to automatically determine the Net Expansion Factor (Y) for this restriction meter with " & 
					  #OrificeType & "." & Chr(13) & Chr(13) _
					  #& "Please enter a value for the Net Expansion Factor (Y)."
					  #UserFormNetExpansion.lblBeta = Round(Beta(p), 2)
					  #UserFormNetExpansion.lblVaporK = VaporK
					  #UserFormNetExpansion.lblPressureRatio = Round(PressureRatio, 2)
					  #UserFormNetExpansion.Show
					  #Y(p) = UserFormNetExpansion.txtNetExpansion + 0
				  end

				  if beta[p] == beta[p-1]
					  orifice_d = beta[p] * pipe_diameter
					  beta_value = beta[p]
					  co_value = co[p]
				  end
			end
	  			  elsif stream_phase == 'Liquid'
			  co[0] = 0.61
			  y[0] = 1
			  (1..10000).each do |p|
				  x = ((2.79926 * 10 ** -7) * mass_flow_rate ** 2) / (pipe_diameter ** 4 * y[p - 1] ** 2 * co[p - 1] ** 2 * vapor_density * delta_p)
				  beta[p] = (x / (1 + x)) ** (1 / 4)
				  nreb = nred / beta[p]
				  #Determine Discharge Coefficient (Infinitity) for Equation 10-10, Darby
				  if orifice_type == "Corner Taps"
					  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Flange Taps"
					  if pipe_diameter >= 2.3
						  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.09 * ((beta[p] ** 4)/(pipe_diameter * (1 - beta[p] ** 4))) - 0.0337 * (beta[p] ** 3 / pipe_diameter)
					  elsif pipe_diameter >= 2 and pipe_diameter <= 2.3
						  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.039 * ((beta[p] ** 4) / (1 - beta[p] ** 4)) - 0.0337 * (beta[p] ** 3 / pipe_diameter)
					  else
						  cinf = 0.6
					  end
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Radius Taps"
					  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.039 * ((beta[p] ** 4) / (1 - beta[p] ** 4)) - 0.0158 * beta[p] ** 3
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Pipe Taps"
					  cinf = 0.5959 + 0.461 * beta[p] ** 2.1 + 0.48 * beta[p] ** 8 + 0.039 * (beta[p] ** 4 / (1 - beta[p] ** 4))
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Machined Inlet" 
					  cinf = 0.995
					  b = 0
					  n = 0
				  elsif orifice_type == "Rough Cast Inlet"
					  cinf = 0.984
					  b = 0
					  n = 0
				  elsif orifice_type == "Rough Welded Sheet Iron Inlet"
					  cinf = 0.985
					  b = 0
					  n = 0
				  elsif orifice_type == "ASME"
					  cinf = 0.9975
					  b = -6.53 * beta[p] ** 0.5
					  n = 0.5
				  elsif orifice_type == "ISA"
					  cinf = 0.99 - 0.2262 * beta[p] ** 4.1
					  b = 1708 - 8936 * beta[p] + 19779 * beta[p] ** 4.7
					  n = 1.15
				  elsif orifice_type == "Venturi Nozzle"
					  cinf = 0.9858 - 0.195 * beta[p] ** 4.5
					  b = 0
					  n = 0
				  end

				  if pipe_size >=2 and pipe_size <= 36
					  if orifice_type == "radius taps" || orifice_type == "corner taps" || orifice_type == "flange taps"
						  if beta[p] >= 0.2 and beta[p] <= 0.75
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message
							  end
						  else
							  #message2 
						  end
					  elsif orifice_type == "Pipe Taps"
						  if beta[p] >= 0.2 and beta[p] <= 0.75
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2
							  end
						  else
							  #message2
						  end
					  end 
				  else
					  #message2 
				  end


				  if orifice_type == "Machine Inlet"
					  if pipe_size >= 2 and pipe_size <= 10
						  if beta[p] >= 0.4 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Rough Cast"
					  if pipe_size >= 4 and pipe_size <= 32
						  if beta[p] >= 0.4 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Rough Welded Sheet Iron Inlet"
					  if pipe_size >= 8 and pipe_size <= 48
						  if beta[p] >= 0.4 and beta[p] <= 0.7
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "ASME"
					  if pipe_size >= 2 and pipe_size <= 16
						  if beta[p] >= 0.25 and beta[p] <= 0.7
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "ISA"
					  if pipe_size >= 2 and pipe_size <= 20
						  if beta[p] >= 0.3 and beta[p] <= 0.75
							  if nred >= 10 ** 5 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Venturi Nozzle"
					  if pipe_size >= 3 and pipe_size <= 20
						  if beta[p] >= 0.3 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= (2 * 10 ** 6)
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  end

				  #Pipe Tap, Equation 10-17, Equation 10-18 Darby
				  y[p] = 1
				  if beta[p] = beta[p-1]
					  orifice_d = beta[p] * pipe_diameter
				  end
			  end
		  elsif stream_phase == 'Bi-Phase'
			  stream_liquid_flow_rate = (1 - vapor_mass_fraction) * mass_flow_rate
			  stream_vapor_flow_rate = vapor_mass_fraction * mass_flow_rate

			  #determine volumetric flow rate
			  ql = stream_liquid_flow_rate / liquid_density
			  qg = stream_vapor_flow_rate / vapor_density
			  qm = ql + qg
			  volume_rate = qm

			  #Determine liquid inlet resistance and physical properties
			  liquid_resistance = ql / qm
			  m_density = (liquid_density * liquid_resistance) + vapor_density * (1 - liquid_resistance)
			  m_viscosity = (liquid_viscosity * liquid_resistance) + vapor_viscosity * (1 - liquid_resistance)

			  #determine initial pipe diameter guess
			  est_area = pi * (pipe_diameter / 2) ** 2

			  #Determine Vapor and liquid superficial velocity
			  vsg = 0.04 * (qg / est_area)
			  vsl = 0.04 * (ql / est_area)
			  vm = vsg + vsl

			  #errosion corrosion index test
			  wl = stream_liquid_flow_rate
			  wg = stream_vapor_flow_rate
			  pm = (wl + wg) / (ql + wg)
			  aec = est_area / 144

			  um = (wg / (3600 * vapor_density * aec)) + (wl / (3600 * liquid_density * aec))

			  #Determine average local liquid resistance , Rl, liquid hold up or actual resistance of liquid in piping
			  r1[1] = liquid_resistance
			  (1..100).each do |i|
				  part1 = (liquid_density * liquid_resistance ** 2) / r1[i]
				  part2 = (vapor_density * (1 - liquid_resistance) ** 2) / (1 - r1[i])
				  dukler_density[i] = part1 + part2
				  dukler_reynold[i] = (dukler_density[i] * vm * (pipe_diameter / 12)) / (0.000671969 * m_viscosity)

				  if dukler_reynold[i] > 0.2 * 10 ** 6
					  r1[i+1] = liquid_resistance
				  else
					  reynold = dukler_reynold[i]
					  liquid_fraction = liquid_resistance
					  liquid_holdup = PipeSizing.liquid_resist(reynold,liquid_fraction) #call the method
					  r1[i+1] = liquid_holdup
				  end

				  if r1[i+1] = r1[i]
					  d_reynolds = dukler_reynold[i]
					  d_density = dukler_density[i]
				  end
			  end

			  co[0] = 0.61
			  y[0] = 1
			  (1..10000).each do |p|
				  x = ((2.79926 * 10 ** -7) * mass_flow_rate ** 2) / (pipe_diameter ** 4 * y[p - 1] ** 2 * co[p - 1] ** 2 * vapor_density * delta_p)
				  beta[p] = (x / (1 + x)) ** (1 / 4)
				  nreb = nred / beta[p]
				  #Determine Discharge Coefficient (Infinitity) for Equation 10-10, Darby
				  if orifice_type == "Corner Taps"
					  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Flange Taps"
					  if pipe_diameter >= 2.3
						  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.09 * ((beta[p] ** 4)/(pipe_diameter * (1 - beta[p] ** 4))) - 0.0337 * (beta[p] ** 3 / pipe_diameter)
					  elsif pipe_diameter >= 2 and pipe_diameter <= 2.3
						  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.039 * ((beta[p] ** 4) / (1 - beta[p] ** 4)) - 0.0337 * (beta[p] ** 3 / pipe_diameter)
					  else
						  cinf = 0.6
					  end
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Radius Taps"
					  cinf = 0.5959 + 0.0312 * beta[p] ** 2.1 - 0.184 * beta[p] ** 8 + 0.039 * ((beta[p] ** 4) / (1 - beta[p] ** 4)) - 0.0158 * beta[p] ** 3
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Pipe Taps"
					  cinf = 0.5959 + 0.461 * beta[p] ** 2.1 + 0.48 * beta[p] ** 8 + 0.039 * (beta[p] ** 4 / (1 - beta[p] ** 4))
					  b = 91.71 * beta[p] ** 2.5
					  n = 0.75
				  elsif orifice_type == "Machined Inlet" 
					  cinf = 0.995
					  b = 0
					  n = 0
				  elsif orifice_type == "Rough Cast Inlet"
					  cinf = 0.984
					  b = 0
					  n = 0
				  elsif orifice_type == "Rough Welded Sheet Iron Inlet"
					  cinf = 0.985
					  b = 0
					  n = 0
				  elsif orifice_type == "ASME"
					  cinf = 0.9975
					  b = -6.53 * beta[p] ** 0.5
					  n = 0.5
				  elsif orifice_type == "ISA"
					  cinf = 0.99 - 0.2262 * beta[p] ** 4.1
					  b = 1708 - 8936 * beta[p] + 19779 * beta[p] ** 4.7
					  n = 1.15
				  elsif orifice_type == "Venturi Nozzle"
					  cinf = 0.9858 - 0.195 * beta[p] ** 4.5
					  b = 0
					  n = 0
				  end

				  if pipe_size >=2 and pipe_size <= 36
					  if orifice_type = "radius taps" || orifice_type == "corner taps" || orifice_type == "flange taps"
						  if beta[p] >= 0.2 and beta[p] <= 0.75
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 = "The Discharge Coefficient(Cd) cannot be automatically estimated based on Miller (1983) correlation published in Table 10-1 (Darby, 1996))
								  #as the parameters falls outside the corresponding applicability and accuracy range." & Chr(13) & Chr(13)_ 
								  #& "Please enter the Orifice Discharge Coefficient (Co) for the " & OrificeType & " orifice with Beta of " & Round(Beta(p), 3) & " 
								  #and a Reynold's Number of flow through the orifice " & Round(NreB, 0) & " as accurately as possible.
								  #Co(p) = UserFormOrificeCoefficient.txtOrificeCoefficient.Value + 0
							  end
						  else
							  #message2 
						  end
					  elsif orifice_type == "Pipe Taps"
						  if beta[p] >= 0.2 and beta[p] <= 0.75
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2
							  end
						  else
							  #message2
						  end
					  end 
				  else
					  #message2 
				  end


				  if orifice_type == "Machine Inlet"
					  if pipe_size >= 2 and pipe_size <= 10
						  if beta[p] >= 0.4 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Rough Cast"
					  if pipe_size >= 4 and pipe_size <= 32
						  if beta[p] >= 0.4 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Rough Welded Sheet Iron Inlet"
					  if pipe_size >= 8 and pipe_size <= 48
						  if beta[p] >= 0.4 and beta[p] <= 0.7
							  if nred >= (2 * 10 ** 5) and nred <= 10 ** 6
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "ASME"
					  if pipe_size >= 2 and pipe_size <= 16
						  if beta[p] >= 0.25 and beta[p] <= 0.7
							  if nred >= 10 ** 4 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "ISA"
					  if pipe_size >= 2 and pipe_size <= 20
						  if beta[p] >= 0.3 and beta[p] <= 0.75
							  if nred >= 10 ** 5 and nred <= 10 ** 7
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  elsif orifice_type == "Venturi Nozzle"
					  if pipe_size >= 3 and pipe_size <= 20
						  if beta[p] >= 0.3 and beta[p] <= 0.75
							  if nred >= (2 * 10 ** 5) and nred <= (2 * 10 ** 6)
								  co[p] = cinf + (b / nred ** n)
							  else
								  #message2 
							  end
						  else
							  #message2 
						  end
					  else
						  #message2 
					  end
				  end

				  #Pipe Tap, Equation 10-17, Equation 10-18 Darby
				  if orifice_type == 'Radius Taps'
					  y[p] = 1 - ((delta_p / (vapor_k * (p1 + barometric_pressure))) * (0.41 + 0.35 * beta[p] ** 4))
				  elsif orifice_type == 'Pipe Taps'
					  y[p] = 1 - ((delta_p / (vapor_k * (p1 + barometric_pressure))) * (0.333 + (1.145 * (beta[p] ** 2 + 0.7 * beta[p] ** 5 + 12 * beta[p] ** 13))))
				  else
					  #message1 = "No correlation is available to automatically determine the Net Expansion Factor (Y) for this restriction meter with " & 
					  #OrificeType & "." & Chr(13) & Chr(13) _
					  #& "Please enter a value for the Net Expansion Factor (Y)."
					  #UserFormNetExpansion.lblBeta = Round(Beta(p), 2)
					  #UserFormNetExpansion.lblVaporK = VaporK
					  #UserFormNetExpansion.lblPressureRatio = Round(PressureRatio, 2)
					  #UserFormNetExpansion.Show
					  #Y(p) = UserFormNetExpansion.txtNetExpansion + 0
				  end
				  if beta[p] == beta[p-1]
					  orifice_d = beta[p] * pipe_diameter
					  beta_value = beta[p]
					  co_value = co[p]
				  end
			  end
		  end

		  if  basis == 'max'
			  flow_element_sizing.update_attributes(
				  :os_max_pipe_reynolds_number => nred,
				  :os_max_orifice_reynolds_number => nreb,
				  :os_max_beta_b => beta_value,
				  :os_max_orifice_coefficient_co => co_value,
				  :os_max_orifice_diameter_d => orifice_d
			  )
		  elsif basis == 'min'
			  flow_element_sizing.update_attributes(
				  :os_min_pipe_reynolds_number => nred,
				  :os_min_orifice_reynolds_number => nreb,
				  :os_min_beta_b => beta_value,
				  :os_min_orifice_coefficient_co => co_value,
				  :os_min_orifice_diameter_d => orifice_d
			  )
		  else
 			 flow_element_sizing.update_attributes(
				  :os_nor_pipe_reynolds_number => nred,
				  :os_nor_orifice_reynolds_number => nreb,
				  :os_nor_beta_b => beta_value,
				  :os_nor_orifice_coefficient_co => co_value,
				  :os_nor_orifice_diameter_d => orifice_d
			  )
		  end

	  end
	  render :json => {:url => 'ok'}
  end

  private
  
  def default_form_values

    @flow_element_sizing = @company.flow_element_sizings.find(params[:id]) rescue @company.flow_element_sizings.new
    @comments = @flow_element_sizing.comments
    @new_comment = @flow_element_sizing.comments.new

    @attachments = @flow_element_sizing.attachments
    @new_attachment = @flow_element_sizing.attachments.new

    @project = @user_project_settings.project
    @streams = []
    
    @restriction_type = [      
      ["Venturi"],
      ["Nozzle"],
      ["Orifice"]
    ]
    
    @orifice_type = [
      ["Corner Taps"],
      ["Flange Taps"],
      ["Pipe Taps"],
      ["Radius Taps"]
     ]
     
     @upstream_condition_basis  = [
                                   {:name=>"Maximum", :value=>"maximum"},
                                   {:name=>"Normal/Design", :value=>"normal"},
                                   {:name=>"Minimum/Turndown", :value=>"minimum"}
                                  ]
  end

  #return orifice type based on restriction type
  def orifice_types(params)
	  venturi = ["Machine Inlet","Rought Case","Rought Welded"]
	  nozzle = ["ASME","ISA","Venturi Nozzle"]
	  orifice = ["Corner Taps","Flange Taps","Pipe Taps","Radius Tips"]
	  if params[:restriction_type] == "Venturi"
		  venturi
	  elsif params[:restriction_type] == "Nozzle"
		  nozzle
	  else
		  orifice
	  end
  end
end
