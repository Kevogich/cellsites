class Admin::ControlValveSizingsController < AdminController
  
  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]
  
  def index
    @control_valve_sizings = @company.control_valve_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
    
    if @user_project_settings.client_id.nil?     
      flash[:error] = "Please Update Project Setting"      
      redirect_to admin_sizings_path
    end
  end

  def new
    @control_valve_sizing = @company.control_valve_sizings.new
  end
  
  def create
    control_valve_sizing = params[:control_valve_sizing]
    control_valve_sizing[:created_by] = control_valve_sizing[:updated_by] = current_user.id    
    @control_valve_sizing = @company.control_valve_sizings.new(control_valve_sizing)    
    
    if !@control_valve_sizing.up_process_basis_id.nil?
      heat_and_material_balance = HeatAndMaterialBalance.find(@control_valve_sizing.up_process_basis_id)
      @streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end
    
    if @control_valve_sizing.save
      @control_valve_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      if !params[:calculate_btn].blank?        
        flash[:notice] = "New control value sizing created."
        redirect_to edit_admin_control_valve_sizing_path(:id=>@control_valve_sizing.id, :calculate_btn=>params[:calculate_btn], :anchor=>params[:tab])  
      else
        flash[:notice] = "New control valve sizing created successfully."
        redirect_to admin_control_valve_sizings_path
      end      
    else
      render :new
    end
  end
  
  def edit
    @control_valve_sizing = @company.control_valve_sizings.find(params[:id])    
    
    if !@control_valve_sizing.up_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@control_valve_sizing.up_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
  end
  
  def update
    control_valve_sizing = params[:control_valve_sizing]
    control_valve_sizing[:updated_by] = current_user.id
    
    @control_valve_sizing = @company.control_valve_sizings.find(params[:id])    
    
    if !@control_valve_sizing.up_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@control_valve_sizing.up_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
        
    if @control_valve_sizing.update_attributes(control_valve_sizing)
      if !params[:calculate_btn].blank?        
        flash[:notice] = "Updated control value sizing."
        redirect_to edit_admin_control_valve_sizing_path(:id=>@control_valve_sizing.id, :calculate_btn=>params[:calculate_btn], :anchor=>params[:tab])
      else  
        flash[:notice] = "Updated control valve sizing successfully."
        if params[:commit] == "Update"
          redirect_to admin_control_valve_sizings_path
        elsif params[:commit] == "Save"
          redirect_to edit_admin_control_valve_sizing_path(:anchor => params[:tab])
        end
      end             
    else      
      render :edit
    end
  end
  
  def destroy
    @control_valve_sizing = @company.control_valve_sizings.find(params[:id])
    if @control_valve_sizing.destroy
      flash[:notice] = "Deleted #{@control_valve_sizing.control_valve_tag} successfully."
      redirect_to admin_control_valve_sizings_path
    end
  end

  def clone
	  @control_valve_sizing = @company.control_valve_sizings.find(params[:id])
	  new = @control_valve_sizing.clone :except => [:created_at, :updated_at]
	  new.control_valve_tag = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_control_valve_sizing_path(new) }
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
    
    lp_surface_tension = property.where(:phase => "Light Liquid", :property => "Surface Tension").first
    lp_surface_tension_stream = lp_surface_tension.streams.where(:stream_no => params[:stream_no]).first
    form_values[:lp_surface_tension] = lp_surface_tension_stream.stream_value.to_f rescue nil
    
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
  
  def control_valve_sizing_summary
    @control_valve_sizings = @company.control_valve_sizings.all    
  end

  def upstream_calculate
	  control_valve = ControlValveSizing.find(params[:control_valve_id])
	  project = control_valve.project
	  pipings = control_valve.suction_pipings

	  ['max','min','nor'].each do |basis|

		  stream_phase = control_valve.up_max_stream_phase if basis == 'max'
		  stream_phase = control_valve.up_min_stream_phase if basis == 'min'
		  stream_phase = control_valve.up_nor_stream_phase if basis == 'nor'

		  flow_rate_basis = project.control_flow_bias_max #from project setup

		  if stream_phase == 'Liquid'
			  ControlValveSizing.cvfe_inlet_side_hydraulics_liquid(control_valve,pipings,basis) 
		  elsif stream_phase == 'Vapor'
			  ControlValveSizing.cvfe_inlet_side_hydraulics_vapor(control_valve,pipings,basis)
		  elsif stream_phase == 'Bi-Phase'
			  ControlValveSizing.cvfe_inlet_side_hydraulics_two_phase(control_valve,pipings,basis)
		  end
		  control_valve.calculate_and_save_delta_ps(:up_condition_basis => basis)
	  end

  rescue Exception => e
	  render :json => {:success => false, :error => "#{e.to_s}\n#{e.backtrace[0..5].join("\n")}" }
  else
	  render :json => {:success => true}
  end

  def downstream_calculate
      control_valve = ControlValveSizing.find(params[:control_valve_id])
	  project = control_valve.project
	  pipings = control_valve.suction_pipings

	  ['max','min','nor'].each do |basis|

		  stream_phase = control_valve.up_max_stream_phase if basis == 'max'
		  stream_phase = control_valve.up_min_stream_phase if basis == 'min'
		  stream_phase = control_valve.up_nor_stream_phase if basis == 'nor'
		  flow_rate_basis = project.control_flow_bias_max #from project setup

		  control_valve.control_valve_downstreams.each do |downstream|
			  pipings = downstream.control_valve_downstream_circuit_pipings
			  if stream_phase == 'Liquid'
				  ControlValveSizing.cvfe_inlet_side_hydraulics_liquid(control_valve,pipings,basis) 
			  elsif stream_phase == 'Vapor'
				  ControlValveSizing.cvfe_inlet_side_hydraulics_vapor(control_valve,pipings,basis)
			  elsif stream_phase == 'Bi-Phase'
				  ControlValveSizing.cvfe_inlet_side_hydraulics_two_phase(control_valve,pipings,basis)
			  end
			  control_valve.calculate_and_save_delta_ps(:up_condition_basis => basis)

		  end #downstream
	  end #basis

    #51 for fitting type 'orifice'
    #49 for fitting type 'equipment'
    #52 for fitting type 'control valve'
    pressure_differential = project.measure_unit("Pressure", "Differential")
    pressure_general = project.measure_unit("Pressure", "General")
    
   control_valve.downstream_maximum.each do |dmax|
      orifice_dp_max = ControlValveDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 51])
      equipment_dp_max = ControlValveDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 49])
      control_valve_dp_max = ControlValveDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 52])
      fitting_dp_max = ControlValveDownstreamCircuitPiping.where(:downstream_maximum_path_id => dmax.id).sum(:delta_p_max)
      
      total_dp_max = fitting_dp_max + equipment_dp_max + control_valve_dp_max + orifice_dp_max
            
      dmax.update_attributes(          
        :fitting_dp => fitting_dp_max.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_max.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_max.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_max.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_max.round(pressure_general[:decimal_places])
      )
      dmax.save          
    end
    
    control_valve.downstream_normal.each do |dnor|          
      orifice_dp_nor = ControlValveDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 51])
      equipment_dp_nor = ControlValveDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 49])
      control_valve_dp_nor = ControlValveDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 52])
      fitting_dp_nor = ControlValveDownstreamCircuitPiping.where(:downstream_normal_path_id => dnor.id).sum(:delta_p_nor)
      
      total_dp_nor = fitting_dp_nor + equipment_dp_nor + control_valve_dp_nor + orifice_dp_nor
      
      dnor.update_attributes(
        :fitting_dp => fitting_dp_nor.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_nor.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_nor.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_nor.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_nor.round(pressure_general[:decimal_places])
      )
      dnor.save
    end
    
    control_valve.downstream_minimum.each do |dmin|
      orifice_dp_min = ControlValveDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 51])
      equipment_dp_min = ControlValveDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 49])
      control_valve_dp_min = ControlValveDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 52])
      fitting_dp_min = ControlValveDownstreamCircuitPiping.where(:downstream_minimum_path_id => dmin.id).sum(:delta_p_min)
      
      total_dp_min = fitting_dp_min + equipment_dp_min + control_valve_dp_min + orifice_dp_min
      
      dmin.update_attributes(
        :fitting_dp => fitting_dp_min.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_min.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_min.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_min.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_min.round(pressure_general[:decimal_places])
      ) 
      dmin.save        
    end

  rescue Exception => e
	  render :json => {:success => false, :error => "#{e.to_s}\n#{e.backtrace[1..5].join("\n")}" }
  else
	  render :json => {:success => true}
  end
  
  def bypass_design_calculation
    calculated_values = {}
    
    control_valve_sizing = ControlValveSizing.find(params[:control_valve_id])
    project = control_valve_sizing.project
    
    nre = (0..1000).to_a
    f = (0..1000).to_a
    g = (0..1000).to_a
    p2star = (0..100000).to_a
    pipe_id = (1..1000).to_a
    est_pipe = (1..1000).to_a
    est_area = (1..1000).to_a
    r1 = (1..1000).to_a
    dukler_density = (1..1000).to_a
    dukler_reynold = (1..1000).to_a
    lbl_by_pass_body_size = 0
    kf = 0
    d_reynolds = 0
    
    process_basis = control_valve_sizing.up_process_basis_id
    cv_tag = control_valve_sizing.control_valve_tag
    
    #Considering bypass
    if control_valve_sizing.cvb_include_bypass
      
      pipe_size = control_valve_sizing.cvb_line_size
      pipe_schedule = control_valve_sizing.cvb_line_schedule
      #TODO check cv_actual
      cv_actual = control_valve_sizing.cvb_bypass_tag.to_f
      
      #Determined valve type
      if control_valve_sizing.cvb_valve_type == "Gate"
        fitting_type = "Valve - Gate (Full Bore)"
      elsif control_valve_sizing.cvb_valve_type == "Ball" 
        fitting_type = "Valve - Ball (Full Bore)"
      elsif control_valve_sizing.cvb_valve_type == "Globe" 
        fitting_type = "Valve - Globe (Full Bore)"
      elsif control_valve_sizing.cvb_valve_type == "Butterfly" 
        fitting_type = "Valve - Butterfly Valve (Full Bore)"
      elsif control_valve_sizing.cvb_valve_type == "Angle (45&deg;)" 
        fitting_type = "Valve - Angle (45&deg;, Full Bore)"
      elsif control_valve_sizing.cvb_valve_type == "Angle (90&deg;)" 
        fitting_type = "Valve - Angle (90&deg;, Full Bore)"
      elsif control_valve_sizing.cvb_valve_type == "Plug (Branch Flow)" 
        fitting_type = "Valve - Plug (Branch Flow)"
      elsif control_valve_sizing.cvb_valve_type == "Plug (Straight Thru)" 
        fitting_type = "Valve - Plug (Straight Through)"
      elsif control_valve_sizing.cvb_valve_type == "Plug (3-Way)" 
        fitting_type = "Valve - Plug (3 way Flow Through)"
      elsif control_valve_sizing.cvb_valve_type == "Diaphragm" 
        fitting_type = "Valve - Diaphragm (Dam Type)"
      end
      
      pipe_roughness = project.project_pipes[0].roughness
      pi = 3.14159265358979
      
      pipe_d = PipeSizing.determine_pipe_diameter(pipe_size.to_f, pipe_schedule)      
      pipe_id[1] = pipe_d
      
      if control_valve_sizing.upstream_condition_basis == "maximum"
        process_basis = control_valve_sizing.up_process_basis_id
        stream_no = control_valve_sizing.up_max_stream_no
        temperature = control_valve_sizing.up_max_temperature
        stream_phase = control_valve_sizing.up_max_stream_phase
        mass_vapor_fraction = control_valve_sizing.up_max_mass_vapor_fraction
        mass_flow_rate = control_valve_sizing.up_max_mass_flow_rate
        vapor_density = control_valve_sizing.up_max_vp_density
        vapor_viscosity = control_valve_sizing.up_max_vp_viscosity
        vapor_mw = control_valve_sizing.up_max_vp_mw
        vapor_k = control_valve_sizing.up_max_vp_cp_cv
        vapor_z = control_valve_sizing.up_max_vp_z
        liquid_density = control_valve_sizing.up_max_lp_density
        liquid_viscosity = control_valve_sizing.up_max_lp_viscosity
        p1 = control_valve_sizing.up_max_pressure
           
        #For j = 1 To 20
        #    If Worksheets("CV Circuit").Cells(16868 + 10 * (j - 1), 78 + i).Value = True Then
        #    P2 = Worksheets("CV Circuit").Cells(16876 + 10 * (j - 1), 78 + i).Value
        #    j = 20
        #    Else
        #    End If
        #Next j
        
        surface_tension = control_valve_sizing.up_max_lp_surface_tension
        critical_pressure = control_valve_sizing.up_max_lp_critical_pressure
        vapor_pressure = control_valve_sizing.up_max_lp_vapor_pressure
        cv_flow_rate = control_valve_sizing.cvb_flow_coefficient
           
      elsif control_valve_sizing.upstream_condition_basis == "normal"
        process_basis = control_valve_sizing.up_process_basis_id
        stream_no = control_valve_sizing.up_nor_stream_no
        temperature = control_valve_sizing.up_nor_temperature
        stream_phase = control_valve_sizing.up_nor_stream_phase
        mass_vapor_fraction = control_valve_sizing.up_nor_mass_vapor_fraction
        mass_flow_rate = control_valve_sizing.up_nor_mass_flow_rate
        vapor_density = control_valve_sizing.up_nor_vp_density
        vapor_viscosity = control_valve_sizing.up_nor_vp_viscosity
        vapor_mw = control_valve_sizing.up_nor_vp_mw
        vapor_k = control_valve_sizing.up_nor_vp_cp_cv
        vapor_z = control_valve_sizing.up_nor_vp_z
        liquid_density = control_valve_sizing.up_nor_lp_density
        liquid_viscosity = control_valve_sizing.up_nor_lp_viscosity
        p1 = control_valve_sizing.up_nor_pressure
        
        #For j = 1 To 20
        #    If Worksheets("CV Circuit").Cells(17073 + 10 * (j - 1), 78 + i).Value = True Then
        #    P2 = Worksheets("CV Circuit").Cells(17081 + 10 * (j - 1), 78 + i).Value
        #    j = 20
        #    Else
        #    End If
        #Next j

        surface_tension = control_valve_sizing.up_nor_lp_surface_tension
        critical_pressure = control_valve_sizing.up_nor_lp_critical_pressure
        vapor_pressure = control_valve_sizing.up_nor_lp_vapor_pressure
        cv_flow_rate = control_valve_sizing.cvb_flow_coefficient
           
      elsif control_valve_sizing.upstream_condition_basis == "minimum"
        process_basis = control_valve_sizing.up_process_basis_id
        stream_no = control_valve_sizing.up_min_stream_no
        temperature = control_valve_sizing.up_min_temperature
        stream_phase = control_valve_sizing.up_min_stream_phase
        mass_vapor_fraction = control_valve_sizing.up_min_mass_vapor_fraction
        mass_flow_rate = control_valve_sizing.up_min_mass_flow_rate
        vapor_density = control_valve_sizing.up_min_vp_density
        vapor_viscosity = control_valve_sizing.up_min_vp_viscosity
        vapor_mw = control_valve_sizing.up_min_vp_mw
        vapor_k = control_valve_sizing.up_min_vp_cp_cv
        vapor_z = control_valve_sizing.up_min_vp_z
        liquid_density = control_valve_sizing.up_min_lp_density
        liquid_viscosity = control_valve_sizing.up_min_lp_viscosity
        p1 = control_valve_sizing.up_min_pressure
           
        #For j = 1 To 20
        #     If Worksheets("CV Circuit").Cells(17278 + 10 * (j - 1), 78 + i).Value = True Then
        #     P2 = Worksheets("CV Circuit").Cells(17286 + 10 * (j - 1), 78 + i).Value
        #     j = 20
        #     Else
        #     End If
        #Next j

        surface_tension = control_valve_sizing.up_min_lp_surface_tension
        critical_pressure = control_valve_sizing.up_min_lp_critical_pressure
        vapor_pressure = control_valve_sizing.up_min_lp_vapor_pressure
        cv_flow_rate = control_valve_sizing.cvb_flow_coefficient
      end
            
      valve_flow_rate = (mass_flow_rate / cv_flow_rate) * cv_actual
            
      if stream_phase == "Liquid"
        avg_density = liquid_density #Assumed Fully Turbulent Flow to calculated initial friction factor
        
        (1..1000).each do |k|          
          nre[k] = (0.52633 * valve_flow_rate * liquid_density) / (pipe_id[k] * liquid_viscosity)
          
          #Determine new friction factor using Churchill's equation
          a = (2.457 * Math.log(1 / (((7 / nre[k]) ** 0.9) + (0.27 * (pipe_roughness / pipe_id[k]))))) ** 16
          b = (37530 / nre[k]) ** 16
          f[k] = 2 * ((8 / nre[k]) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)

          fd = 4 * f[k]
          nreynolds = nre[k]
          d = pipe_id[k]
          
          #Call ResistanceCoefficient(fittingtype, nreynolds, d, d1, d2, kf, fd, DoverD)  'module 71
          #TODO need to find what is d1 and d2
          resistance_coefficient_values = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1 = 0, d2 = 0, fd)          
          kf = resistance_coefficient_values[:kf]          

          #Determine equivalent Cv for valve
          pipe_id[k + 1] = ((cv_actual * (kf) ** 0.5) / 29.9) ** 0.5
          
          if pipe_id[k] == pipe_id[k + 1]            
            rupture_diameter = pipe_id[k + 1]            
            #Call DetermineNominalPipeSize(rupture_diameter, PipeSize, PipeSchedule, ProposedDiameter)        'Module 60
            determine_nominal_pipe_size_values =  PipeSizing.determine_nominal_pipe_size(rupture_diameter)            
            lbl_by_pass_body_size = determine_nominal_pipe_size_values[:pipe_size]            
            k = 1000
          end
        end 
        
      elsif stream_phase == "Vapor"
        #Using Adiabatic/Isothermal Flow For Valve Capacity Calculation
        #Assuming full turbulent flow
        (1..1000).each do |m|
          nre[m] = (0.52633 * mass_flow_rate * vapor_density) / (pipe_id[m] * vapor_viscosity)
          
          #Determine new friction factor using Churchill's equation
          a = (2.457 * Math.log(1 / (((7 / nre[m]) ** 0.9) + (0.27 * (pipe_roughness / pipe_id[m]))))) ** 16
          b = (37530 / nre[m]) ** 16
          f[m] = 2 * ((8 / nre[m]) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)
          
          #Kf for valve type          
          nreynolds = nre[m]
          d = pipe_id[m]
          
          #Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)          'module 60
          #TODO need to find what is d1 and d2
          resistance_coefficient_values = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1 = 0, d2 = 0, fd = 0)          
          kf = resistance_coefficient_values[:kf]     
          
          #Determine equivalent Cv for valve
          pipe_id[m+1] = ((cv_actual * (kf) ** 0.5) / 29.9) ** 0.5
          
          if pipe_id[m] == pipe_id[m+1]
            rupture_diameter = pipe_id[m+1]   
            determine_nominal_pipe_size_values =  PipeSizing.determine_nominal_pipe_size(rupture_diameter)
            lbl_by_pass_body_size = determine_nominal_pipe_size_values[:pipe_size]
            m = 1000
          end
        end # 1..1000 m
        
        #Determine the choke pressure
        p2star[0] = (p1 + project.barometric_pressure)
        
        if project.vapor_flow_model. == "Adiabatic"
          (1..1000).each do |n|
            p2star[n] = p2star[0] - ((0.001 * n) * p2star[0])
            part1 = (2 / (k + 1))
            part2 = (((p1 + project.barometric_pressure) / p2star[n]) ** ((k + 1) / k)) - 1
            part3 = (2 / k) * Math.log((p1 + project.barometric_pressure) / p2star[n])
            critical_kf = (part1 * part2) - part3
            if kf <= critical_kf
              n = 1000
            end
          end
          raise "aa"
        elsif project.vapor_flow_model. == "Isothermic"
          (1..1000).each do |n|
            p2star[n] = p2star[0] - ((0.001 * n) * p2star[0])
            part1 = ((p1 + project.barometric_pressure) / p2star[n]) ** 2
            part2 = 2 * Math.log((p1 + project.barometric_pressure) / p2star[n])
            critical_kf = part1 - part2 - 1
            if kf <= critical_kf
              n = 1000
            end
          end          
        end

        p2_critical = 10 #TODO 
        p2 = 2 #TODO 
        if p2_critical > (p2 + project.barometric_pressure)
          txt_notes = "Choked flow expected"
        end
        
      elsif stream_phase == "Bi-Phase"        
        #Determine volumetric flow rate        
        stream_liquid_flow_rate = mass_flow_rate * (1 - mass_vapor_fraction)
        stream_vapor_flow_rate = mass_flow_rate * mass_vapor_fraction
        
        ql = stream_liquid_flow_rate / liquid_density
        qg = stream_vapor_flow_rate / vapor_density        
        qm = ql + qg
        volume_rate = qm
        
        #Determine liquid inlet resistance and physical properties
        liquid_resistance = ql / qm        
        m_density = (liquid_density * liquid_resistance) + vapor_density * (1 - liquid_resistance)
        m_viscosity = (liquid_viscosity * liquid_resistance) + vapor_viscosity * (1 - liquid_resistance)
        
        #Determine initial pipe diameter guess
        (1..100).each do |k|
          est_area[k] = pi * (pipe_id[k] / 2) ** 2
         
          #Determine Vapor and Liquid Superficial Velocity
          vsg = 0.04 * (qg / est_area[k])
          vsl = 0.04 * (ql / est_area[k])
          vm = vsg + vsl
          
          #Determine average local liquid resistance , Rl, liquid hold up or actual resistance of liquid in piping
          r1[1] = liquid_resistance
          
          (1..1000).each do |ii|
            part1 = (liquid_density * liquid_resistance ** 2) / r1[ii]
            part2 = (vapor_density * (1 - liquid_resistance) ** 2) / (1 - r1[ii])
            dukler_density[ii] = part1 + part2
            dukler_reynold[ii] = (dukler_density[ii] * vm * (pipe_id[k] / 12)) / (0.000671969 * m_viscosity)            
            if dukler_reynold[ii] > 0.2 * 10 ** 6 #To maintain a bubble/froth flow regime and give economical pipe sizes
              r1[ii + 1] = liquid_resistance
            else
              reynold = dukler_reynold[ii]
              liquid_fraction = liquid_resistance
              #Call LiquidResist(Reynold, LiquidFraction, LiquidHoldUp)                  'Module 3
              #TODO need review liquid resist method
              liquid_hold_up = PipeSizing.liquid_resist(reynold, liquid_fraction)
              r1[ii + 1] = liquid_hold_up
            end
            
            if r1[ii + 1] == r1[ii]
              d_reynolds = dukler_reynold[ii]
              d_density = dukler_density[ii]
              break#ii = 1000
            end
          end

          nreynolds = d_reynolds
          d = pipe_id[k]
          #TODO what is d1, d2 and fd
          #Call ResistanceCoefficient(fitting_type, nreynolds, d, d1, d2, kf, fd, DoverD)          'module 60
          resistance_coefficient_values = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1 = 0, d2 = 0, fd = 1)          
          kf = resistance_coefficient_values[:kf]    
          
          #Determine equivalent Cv for valve
          pipe_id[k + 1] = ((cv_actual * (kf) ** 0.5) / 29.9) ** 0.5
          if pipe_id[k] == pipe_id[k + 1]
            rupture_diameter = pipe_id[k + 1]
            
            #Call DetermineNominalPipeSize(rupture_diameter, PipeSize, PipeSchedule, ProposedDiameter)        'Module 60            
            determine_nominal_pipe_size_values =  PipeSizing.determine_nominal_pipe_size(rupture_diameter)            
            lbl_by_pass_body_size = determine_nominal_pipe_size_values[:pipe_size]
            break #k = 100
          end
          
        end # k

      end      
    end
    
    calculated_values[:lbl_by_pass_body_size] = lbl_by_pass_body_size.to_f
    calculated_values[:txt_notes] = txt_notes
        
    respond_to do |format|
      format.json {render :json => calculated_values}     
    end    
  end 
  
  def control_valve_design_calculation
    calculated_values = {}
    
    control_valve_sizing = ControlValveSizing.find(params[:control_valve_id])
    project = control_valve_sizing.project

	log = CustomLogger.new("control_valve_design_calculation")

	line_size           = control_valve_sizing.cvs_line_size
	line_schedule       = control_valve_sizing.cvs_line_schedule
	pipe_diameter       = PipeSizing.determine_pipe_diameter(line_size.to_f,line_schedule)

	log.info("line size = #{line_size}")
	log.info("line schedule = #{line_schedule}")
	log.info("piep diameter = #{pipe_diameter}")

	body_size           = control_valve_sizing.cvs_cv_body_size
	attached_fitting    = control_valve_sizing.cvs_attached_fittings_reducer
	barometric_pressure = project.barometric_pressure.to_f
	pressure_drop_ratio = control_valve_sizing.cvs_valve_pressure_drop_ratio
	fl 					= control_valve_sizing.cvs_valve_liquid_recovery_factor
	fd 					= control_valve_sizing.cvs_valve_style_modifier
	cv 					= control_valve_sizing.cvs_valve_flow_coefficient
	dcv = body_size
    dline = pipe_diameter

	#determine piping geometry factor fp
	#message1 = "Note that the calculation for the piping geometry factor (Fp) in this software is applicable only when 
	#the diameter of the piping approaching the control valve is the same as the diameter of the piping leaving the control valve.
	#Otherwise the Fp factor must be determine manual and entered in the software" & Chr(13) & Chr(13) _
    #& "Does the installation under consideration comply with the above stated conditions?"
	msg = 'yes'
	if msg == 'yes'
		if attached_fitting == 'None'
			fp = 1
		elsif attached_fitting == 'Inlet Only'
			k = 0.5 * (1 - (dcv ** 2 / dline ** 2)) ** 2
 			fp = (1 + ((k / 890) * (cv / dcv ** 2) ** 2)) ** -0.5
		elsif attached_fitting == 'Outlet Only'
      		k = 1 * (1 - (dcv ** 2 / dline ** 2)) ** 2
	        fp = (1 + ((k / 890) * (cv / dcv ** 2) ** 2)) ** -0.5
		elsif attached_fitting == 'Both Sides'
            k = 1.5 * (1 - (dcv ** 2 / dline ** 2)) ** 2
            fp = (1 + ((k / 890) * (cv / dcv ** 2) ** 2)) ** -0.5
		elsif attached_fitting == 'Other(s)'
		    #Fp = InputBox("Enter Piping Geometry Factor (Fp) for the fittings other than a reducer(s)that
		    #are attached to the control valve.  Refer to Fisher Catalog 12 for details on how to determine the appropriate Fp Factor.")
			#TODO dummy value
			fp = 1
		end
	else
	    #Fp = InputBox("Enter Piping Geometry Factor (Fp) for the fittings other than a reducer(s)that
		#are attached to the control valve.  Refer to Fisher Catalog 12 for details on how to determine the appropriate Fp Factor.")
		#TODO dummy value
		fp = 1
	end

	#save fp in database
	control_valve_sizing.update_attributes(:cvs_piping_geometric_factor => fp)

	['max','min','nor'].each do |basis|
		if basis == 'max'
			stream_no           = control_valve_sizing.up_max_stream_no
			pressure            = control_valve_sizing.up_max_pressure
			temperature         = control_valve_sizing.up_max_temperature
			stream_phase        = control_valve_sizing.up_max_stream_phase
			mass_vapor_fraction = control_valve_sizing.up_max_mass_vapor_fraction
			mass_flow_rate      = control_valve_sizing.up_max_mass_flow_rate
			vapor_density       = control_valve_sizing.up_max_vp_density
			vapor_viscosity     = control_valve_sizing.up_max_vp_viscosity
			vapor_mw            = control_valve_sizing.up_max_vp_mw
			vapor_k             = control_valve_sizing.up_max_vp_cp_cv
			vapor_z             = control_valve_sizing.up_max_vp_z
			liquid_density      = control_valve_sizing.up_max_lp_density
			liquid_viscosity    = control_valve_sizing.up_max_lp_viscosity
			surface_tension     = control_valve_sizing.up_max_lp_surface_tension
			critical_pressure   = control_valve_sizing.up_max_lp_critical_pressure
			vapor_pressure      = control_valve_sizing.up_max_lp_vapor_pressure
			p1 					= control_valve_sizing.up_max_pressure_at_inlet_flange
			#TODO dummy value
			p2 					= 10.0
		elsif basis == 'min'
			stream_no           = control_valve_sizing.up_min_stream_no
			pressure            = control_valve_sizing.up_min_pressure
			temperature         = control_valve_sizing.up_min_temperature
			stream_phase        = control_valve_sizing.up_min_stream_phase
			mass_vapor_fraction = control_valve_sizing.up_min_mass_vapor_fraction
			mass_flow_rate      = control_valve_sizing.up_min_mass_flow_rate
			vapor_density       = control_valve_sizing.up_min_vp_density
			vapor_viscosity     = control_valve_sizing.up_min_vp_viscosity
			vapor_mw            = control_valve_sizing.up_min_vp_mw
			vapor_k             = control_valve_sizing.up_min_vp_cp_cv
			vapor_z             = control_valve_sizing.up_min_vp_z
			liquid_density      = control_valve_sizing.up_min_lp_density
			liquid_viscosity    = control_valve_sizing.up_min_lp_viscosity
			surface_tension     = control_valve_sizing.up_min_lp_surface_tension
			critical_pressure   = control_valve_sizing.up_min_lp_critical_pressure
			vapor_pressure      = control_valve_sizing.up_min_lp_vapor_pressure
			p1 					= control_valve_sizing.up_min_pressure_at_inlet_flange
			#TODO dummy value
			p2 					= 10.0
		else
			stream_no           = control_valve_sizing.up_nor_stream_no
			pressure            = control_valve_sizing.up_nor_pressure
			temperature         = control_valve_sizing.up_nor_temperature
			stream_phase        = control_valve_sizing.up_nor_stream_phase
			mass_vapor_fraction = control_valve_sizing.up_nor_mass_vapor_fraction
			mass_flow_rate      = control_valve_sizing.up_nor_mass_flow_rate
			vapor_density       = control_valve_sizing.up_nor_vp_density
			vapor_viscosity     = control_valve_sizing.up_nor_vp_viscosity
			vapor_mw            = control_valve_sizing.up_nor_vp_mw
			vapor_k             = control_valve_sizing.up_nor_vp_cp_cv
			vapor_z             = control_valve_sizing.up_nor_vp_z
			liquid_density      = control_valve_sizing.up_nor_lp_density
			liquid_viscosity    = control_valve_sizing.up_nor_lp_viscosity
			surface_tension     = control_valve_sizing.up_nor_lp_surface_tension
			critical_pressure   = control_valve_sizing.up_nor_lp_critical_pressure
			vapor_pressure      = control_valve_sizing.up_nor_lp_vapor_pressure
			p1 					= control_valve_sizing.up_nor_pressure_at_inlet_flange
			#TODO dummy value
			p2 					= 10.0
		end
 		#Determine Pressure Ratio
        delta_p = p1 - p2
        pressure_ratio = delta_p / (p1 + barometric_pressure)

		xt = pressure_drop_ratio
		k = vapor_k
		mw = vapor_mw
		z = vapor_z
			p_vapor = vapor_pressure
		pc = critical_pressure

		if stream_phase == 'Vapor' or stream_phase == 'Bi-Phase'
			n5 = 1000
			if attached_fitting == 'Outlet Only' or attached_fitting ==  'None'
				xc = xt
			elsif attached_fitting == 'Inlet Only' or attached_fitting == 'Both Sides' 
				#accounting for just the inlet reducer
				k1 = 0.5 * (1 - (dcv ** 2 / dline ** 2)) ** 2        
				ki = k1
				part1 = xt / (fp ** 2)
				part2 = ((xt * ki) / n5) * (cv / dcv ** 2) ** 2
				xtp = part1 * (1 + part2) ** -1
				xc = xtp
			elsif attached_fitting == "Other(s)"
				#K1 = InputBox("Input the sum of the velocity head loss coefficient (K) for all the fittings attached to the inlet of the control valve." & Chr(13) & Chr(13) _
				#& "Note further that the K value should account for the inlet Bernoulli coefficient in the event that the diameter of the piping approaching the control valve is different 
				#from the diameter of the piping leaving the control valve.  See Fisher Catalog 12 for more details.", "Combined Pressure Drop Ratio Factor And Piping Geometry Factor") + 0
				ki = k1
				part1 = xt / (fp ** 2)
				part2 = ((xt * ki) / n5) * (cv / dcv ** 2) ** 2
				xtp = part1 * (1 + part2) ** -1
				xc = xtp
			end
			#Determine Expansion Factor
			delta_p  = p1 - p2
			x = delta_p / (p1 + barometric_pressure)
			fk = k / 1.4
			y = 1 - (x / (3 * fk * xc))

			if y < 0.667  
			   #message2 = MsgBox("The Expansion Factor (Y) of " & Round(Y, 3) & " is less than 0.667, the back pressure is less than the critical pressure. 
			   #Flow is expected to be choked.", vbOKOnly, "Choked Flow Predicted.")
               #Notes = "Choked Flow is expected at service conditions."
               y_limited = 0.667
			else
               #Notes = "Choked Flow is not expected at service conditions."
               y_limited = y
			end
			#Determine Flowrate
            vapor_mass_flow_reate = mass_flow_rate * mass_vapor_fraction
            n8 = 19.3
			t = temperature
            required_cv = vapor_mass_flow_reate / (n8 * fp * (p1 + barometric_pressure) * y_limited* ((x * mw) / ((t + 459.67) * z)) ** 0.5)

			if stream_phase == "Bi-Phase"
				vapor_cv = required_cv
			end
		end

		if  stream_phase == "Liquid" or stream_phase == "Bi-Phase"
			#Determine kinematic viscosity
             liquid_mass_fraction = 1 - mass_vapor_fraction
             kinematic_viscosity = 62.428 * (liquid_viscosity / liquid_density)
 			#Determine Liquid Pressure Recovery Coefficient
             ff = 0.96 - (0.28 * ((p_vapor+ barometric_pressure) / (pc + barometric_pressure)) **  0.5)
			 if attached_fitting == 'None' or attached_fitting == 'Outlet Only' or fp == 1
				max_delta_p = fl ** 2 * ((p1 + barometric_pressure) - (ff * (p_vapor+ barometric_pressure)))
			 elsif attached_fitting == "Inlet Only" or attached_fitting == "Both Sides"
               k1 = 0.5 * (1 - (dcv ** 2 / dline ** 2)) ** 2
               kb1 = 1 - (dcv / dline) ** 4
               k1 = k1 + kb1
               flp = (((k1 / 890) * (cv / dcv ** 2) ** 2) + (1 / fl ** 2)) ** -0.5
			   max_delta_p = (flp / fp) ** 2 * ((p1 + barometric_pressure) - ((p_vapor + barometric_pressure) * ff))
			 elsif attached_fitting == "Other(s)"
			   #K1 = InputBox("Input the sum of the velocity head loss coefficient (K) for all the fittings attached to the inlet of the control valve." & Chr(13) & Chr(13) _
               #& "Note further that the K value should account for the inlet Bernoulli coefficient in the event that the diameter of the piping approaching the control valve 
			   #is different from the diameter of the piping leaving the control valve.  See Fisher Catalog 12 for more details.",
			   #"Combined Liquid Pressure Recovery Factor And Piping Geometry Factor") + 0
			   flp = (((k1 / 890) * (cv / dcv ** 2) ** 2) + (1 / fl ** 2)) ** -0.5
			   max_delta_p = (flp / fp) ** 2 * ((p1 + barometric_pressure) - ((p_vapor + barometric_pressure) * ff))
			 end

 			#if max_delta_p > 0
            #   Msg5 = MsgBox("The vapor pressure at the " & CurrentBasis & " upstream condition specified for this liquid or two phase
			#   stream may not be accurate (i.e may be higher than expected).  
			#   hPlease review the vapor pressure specified for the stream and update accordingly.", vbInformation, "Possibly Inaccurate Liquid Vapor Pressure!")
            #   Exit Sub
			#end

			 #determine actual delta p
			 delta_p = p1 - p2
			 log.info("max_delta_p = #{max_delta_p}")
			 log.info("delta_p = #{delta_p}")
			 #TODO dummy value getting complex number
			 max_delta_p = 0.12

			 if delta_p > max_delta_p
				 #msg1 = MsgBox("Choked flow in the vena contracta is expected at the relief conditions due to either flashing or cavitation of the fluid in the control valve.")
				 if p_vapor > p2
					 #Notes = "Choked flow is expected at service conditions due to liquid flashing."
					 note = "Flashing"
				 elsif p_vapor < p2
					 #Notes = "Choked flow is expected at service conditions due to liquid cavitating."
					 note = "Cavitating"
				 else
					 #Notes = "Choked flow is expected at service conditions."
					 note = "Choked Liquid"
				 end
				 sizing_delta_p = max_delta_p
			 else
				 #Notes = "Choked Flow is not expected at service conditions."
				 note = "Choke"
				 sizing_delta_p = delta_p
			 end

			 if fd.blank?
				#message2 = "The valve style modifier (Fd) is dependent of the valve sytle used.  
				#Valves that use two parallel flow paths, such as double-ported globe style valve or butterfly valve are more appropriately represented by a Fd of 0.7.
				#All other type valves can be represented by  a Fd of 1.0." & Chr(13) & Chr(13) _
                #& "Can the valve style be characterized as having two parallel flow paths?"
                #msg2 = MsgBox(message2, vbYesNo, "Valve Style Modifier (Fd)")
				msg = 'yes'
				if msg == 'yes'
					fd = 0.7
				else
					fd = 1
				end
			 end

			#Determine Reynolds Number Factor, Fr
            n4 = 17300
            n1 = 1
            n2 = 890

           liquid_mass_flow_rate = mass_flow_rate * (1 - mass_vapor_fraction)
           q = (7.4805 / 60) * (liquid_mass_flow_rate/ liquid_density)
		   pseudo_cv = q / (n1 * fp * (sizing_delta_p / (liquid_density / 62.4)) ** 0.5)      #fp = 1.0
           part1 = (n4 * fd * q) / (kinematic_viscosity * fl ** 0.5 * pseudo_cv ** 0.5)
		   log.info("dline   = #{dline}")
           part2 = (((fl ** 2 * pseudo_cv ** 2) / (n2 * dline ** 4)) + 1) ** (1 / 4)
           rev = part1 * part2

		   log.info("pseudo_cv = #{pseudo_cv}")
		   log.info("rev  = #{rev}")

		   if rev < 56
			   fr = 0.019 * rev ** 0.67
		   elsif rev > 56 and rev < 40000 
			   if rev > 56 and rev < 340
				   fr = -0.00000466307 * rev ** 2 + 0.00314412 * rev + 0.138397
			   elsif rev >= 340 and rev <= 40000
				   fr = 0.0681 * Math.log(rev) + 0.3203
			   end
		   elsif rev > 40000 
			   fr = 1
		   end

 		  #Determine Cv
		   #TODO dummy value
		   fr = 2.0
           required_cv = pseudo_cv / fr
            if stream_phase == "Bi-Phase"
               liquid_cv = required_cv
		     end
		end

		if stream_phase == 'Bi-Phase'
			vg = 1 / vapor_density
			vl = 1 / liquid_density
			part1 = (1 - mass_vapor_fraction) / mass_vapor_fraction
			vr = vg / (vg + (vl * part1))
			log.info("vr = #{vr}")
			if vr > 0 and vr < 0.6
				fm = 0.9536 * vr - 0.0078
			elsif vr >= 0.6 and vr < 0.8
				fm = 1.5 * vr - 0.329
			elsif vr >= 0.8 and vr <= 1
				fm = -466.67 * vr ** 4 + 1513.3 * vr ** 3 - 1844.8 * vr ** 2 + 1003.9 * vr - 205.25
			end 
			log.info("liquid_cv = #{liquid_cv}")
			log.info("vapor cv = #{vapor_cv}")
			log.info("fm = #{fm}")
			#TODO dummy value
			vapor_cv = 10.0
			liquid_cv = 10.0 if liquid_cv.nil? or liquid_cv.nan?
			fm = 1.0 if fm.nil?
			required_cv = (liquid_cv + vapor_cv) * (1 + fm)
		end

	   log.info("calculated values for #{basis} =============== ")
       log.info("delta p = #{delta_p}")
	   log.info("fr = #{fr}")
	   log.info("required cv = #{required_cv}")
	   log.info("note  = #{note}")

	   if basis == 'max'
		   control_valve_sizing.update_attributes(
			   :cvs_max_differential_pressure => delta_p,
			   :cvs_max_reynolds_number_factor => fr,
			   :cvs_max_required_flow_coefficient => required_cv,
			   :cvs_max_choke_condition => note
		   )
	   elsif basis == 'min'
		 control_valve_sizing.update_attributes(
			   :cvs_min_differential_pressure => delta_p,
			   :cvs_min_reynolds_number_factor => fr,
			   :cvs_min_required_flow_coefficient => required_cv,
			   :cvs_min_choke_condition => note
		   )
	   else
	     control_valve_sizing.update_attributes(
			   :cvs_nor_differential_pressure => delta_p,
			   :cvs_nor_reynolds_number_factor => fr,
			   :cvs_nor_required_flow_coefficient => required_cv,
			   :cvs_nor_choke_condition => note
		   )
	   end
	end
  rescue Exception => e
	render :json => {:success => false, :error => "#{e.to_s}\n#{e.backtrace.join("\n")}"}
  else
	render :json => {:success => true}
  end
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
    @breadcrumbs << { :name => 'Control Valve sizing', :url => admin_control_valve_sizings_path }
  end
  
  private
  
 def default_form_values

   @control_valve_sizing = @company.control_valve_sizings.find(params[:id]) rescue @company.control_valve_sizings.new
   @comments = @control_valve_sizing.comments
   @new_comment = @control_valve_sizing.comments.new

   @attachments = @control_valve_sizing.attachments
   @new_attachment = @control_valve_sizing.attachments.new
    
    @project = @user_project_settings.project
    @streams = []
    
    @upstream_condition_basis = [        
                                  {:name=>"Maximum", :value=>"maximum"},
                                  {:name=>"Normal/Design", :value=>"normal"},
                                  {:name=>"Minimum/Turndown", :value=>"minimum"}
                                ]
    
    @administrative_controls = [
      ["Car-Seal Closed (CSC)"], 
      ["Locked Closed (LC)"], 
      ["Car-Seal Open (CSO)"],
      ["Locked Open (LO)"],
      ["Mechanical Stop"],
      ["Isolated By Valve(s)"],
      ["Binded Closed"],
      ["Binded Open"],
      ["Others"],
      ["None"]
    ]
    
    @flow_characteristic = [
      ["Linear"],
      ["Equal Percentage"],
      ["Modified Parabolic"],
      ["Quick Open"],
      ["Others"],
      ["Unknown"]
    ]
    
    @fittings_reducer = [
      ["Inlet Only"],
      ["Outlet Only"],
      ["Both Sides"],
      ["None"],
      ["Other(s)"]
    ]

  end
end
