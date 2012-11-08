class Admin::HydraulicTurbinesController < AdminController
  
  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update, :get_stream_values]
  
  def new
    @hydraulic_turbine = @company.hydraulic_turbines.new   
  end
  
  def create
    hydraulic_turbine = params[:hydraulic_turbine]
    hydraulic_turbine[:created_by] = hydraulic_turbine[:updated_by] = current_user.id    
    @hydraulic_turbine = @company.hydraulic_turbines.new(hydraulic_turbine)    
    
    if @hydraulic_turbine.save
      @hydraulic_turbine.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      flash[:notice] = "New hydraulic turbine created successfully."
      redirect_to admin_driver_sizings_path(:anchor => "hydraulic_turbine")
    else
      render :new
    end
  end
  
  def edit
    @hydraulic_turbine = @company.hydraulic_turbines.find(params[:id])    

  	unless @hydraulic_turbine.htd_red_equipment_type.nil?
  		param = {:equipment_type => @hydraulic_turbine.htd_red_equipment_type,:project_id => @user_project_settings.project_id}
  		@equipment_tags = get_equipment_tags(param)
  	end
    
    if !@hydraulic_turbine.su_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@hydraulic_turbine.su_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end    
  end
  
  def update
    hydraulic_turbine = params[:hydraulic_turbine]
    hydraulic_turbine[:updated_by] = current_user.id
    
    #raise hydraulic_turbine.to_yaml
    
    @hydraulic_turbine = @company.hydraulic_turbines.find(params[:id])
    if !@hydraulic_turbine.su_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@hydraulic_turbine.su_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
           
    if @hydraulic_turbine.update_attributes(hydraulic_turbine)
      if !params[:calculate_btn].blank?
        flash[:notice] = "Updated hydraulic turbine successfully."
        redirect_to edit_admin_hydraulic_turbine_path(:id=>@hydraulic_turbine.id, :calculate_btn=>params[:calculate_btn], :anchor=>params[:tab])
      else
        flash[:notice] = "Updated hydraulic turbine successfully."
        redirect_to admin_driver_sizings_path(:anchor => "hydraulic_turbine")
      end      
    else      
      render :edit
    end
  end
  
  def destroy
    @hydraulic_turbine = @company.hydraulic_turbines.find(params[:id])
    if @hydraulic_turbine.destroy
      flash[:notice] = "Deleted #{@hydraulic_turbine.hydraulic_turbine_tag} successfully."
      redirect_to admin_driver_sizings_path(:anchor => "hydraulic_turbine")
    end
  end

  def clone
      @hydraulic_turbine = @company.hydraulic_turbines.find(params[:id])
	  new = @hydraulic_turbine.clone :except => [:created_at, :updated_at]
	  new.hydraulic_turbine_tag = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_hydraulic_turbine_path(new) }
	  else
		  render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
	  end
	  return
  end
  
  def hydraulic_turbine_summary
    @hydraulic_turbines = @company.hydraulic_turbines.all
  end
  
  def get_stream_values
    form_values = {}
    
    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    property = heat_and_meterial_balance.heat_and_material_properties
    
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first    
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure_value] = pressure_stream.stream_value.to_f rescue nil
    
    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature_value] = temperature_stream.stream_value.to_f rescue nil
    
    mass_vapour_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    mass_vapour_fraction_stream = mass_vapour_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_vapour_fraction] = mass_vapour_fraction_stream.stream_value.to_f rescue nil
    
    mass_flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    mass_flow_rate_stream = mass_flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_flow_rate_value] = mass_flow_rate_stream.stream_value.to_f rescue nil
    
    mass_flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    mass_flow_rate_stream = mass_flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_flow_rate_value] = mass_flow_rate_stream.stream_value.to_f rescue nil
    
    vapor_density = property.where(:phase => "Vapour", :property => "Mass Density").first
    vapor_density_stream = vapor_density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_density_value] = vapor_density_stream.stream_value.to_f rescue nil
    
    vapor_viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
    vapor_viscosity_stream = vapor_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_viscosity_value] = vapor_viscosity_stream.stream_value.to_f rescue nil   
    
    render :json => form_values
  end
  
  def get_discharge_stream_nos
    form_values = {}
    
    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    property = heat_and_meterial_balance.heat_and_material_properties
    
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first    
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure] = pressure_stream.stream_value.to_f.round(4) rescue nil
    
    render :json => form_values    
  end

  #TODO changing logic basiced on new UI changes - need review
  def suction_calculation
    calculated_values = {}
    
    hydraulic_turbine = HydraulicTurbine.find(params[:hydraulic_turbine_id])
    
    suction_total_dp_max = ''
    pressure_suction_nozzle_max = ''
    max_suction_pressure_max = ''
    suction_total_dp_nor = ''
    pressure_suction_nozzle_nor = ''
    max_suction_pressure_nor = ''
    suction_total_dp_min = ''
    pressure_suction_nozzle_min = ''
    max_suction_pressure_min = ''
        
    #maximum
    pressure_max = hydraulic_turbine.su_max_pressure
    suction_total_dp_max = (hydraulic_turbine.su_fitting_dp_max + hydraulic_turbine.su_equipment_dp_max + hydraulic_turbine.su_control_valve_dp_max + hydraulic_turbine.su_orifice_dp_max).round(2)
    pressure_suction_nozzle_max = (pressure_max - suction_total_dp_max).round(2)
    
    if hydraulic_turbine.su_max_upstream_pressure_max != ''
      max_upstream_max = hydraulic_turbine.su_max_upstream_pressure_max.to_f + 0
      suction_total_dp_max = (hydraulic_turbine.su_fitting_dp_max + hydraulic_turbine.su_equipment_dp_max + hydraulic_turbine.su_control_valve_dp_max + hydraulic_turbine.su_orifice_dp_max).round(2)
      deltap_max = suction_total_dp_max
      
      max_suction_max = max_upstream_max - deltap_max        
      max_suction_pressure_max = (max_suction_max).round(2)
    end
      
    #normal
    pressure_nor = hydraulic_turbine.su_nor_pressure
    suction_total_dp_nor = (hydraulic_turbine.su_fitting_dp_nor + hydraulic_turbine.su_equipment_dp_nor + hydraulic_turbine.su_control_valve_dp_nor + hydraulic_turbine.su_orifice_dp_nor).round(2)
    pressure_suction_nozzle_nor = (pressure_nor - suction_total_dp_nor).round(2)
    
    if hydraulic_turbine.su_max_upstream_pressure_nor != ''
      max_upstream_nor = hydraulic_turbine.su_max_upstream_pressure_nor.to_f + 0
      suction_total_dp_nor = (hydraulic_turbine.su_fitting_dp_nor + hydraulic_turbine.su_equipment_dp_nor + hydraulic_turbine.su_control_valve_dp_nor + hydraulic_turbine.su_orifice_dp_nor).round(2)
      deltap_nor = suction_total_dp_nor
    
      max_suction_nor = max_upstream_nor - deltap_nor
      max_suction_pressure_nor = (max_suction_nor).round(2)
    end
      
    #minimum
    pressure_min = hydraulic_turbine.su_min_pressure
    suction_total_dp_min = (hydraulic_turbine.su_fitting_dp_min + hydraulic_turbine.su_equipment_dp_min + hydraulic_turbine.su_control_valve_dp_min + hydraulic_turbine.su_orifice_dp_min).round(2)
    pressure_suction_nozzle_min = (pressure_min - suction_total_dp_min).round(2)
    
    if hydraulic_turbine.su_max_upstream_pressure_min != ''
      max_upstream_min = hydraulic_turbine.su_max_upstream_pressure_min.to_f + 0
      suction_total_dp_min = (hydraulic_turbine.su_fitting_dp_min + hydraulic_turbine.su_equipment_dp_min + hydraulic_turbine.su_control_valve_dp_min + hydraulic_turbine.su_orifice_dp_min).round(2)
      deltap_min = suction_total_dp_min
    
      max_suction_min = max_upstream_min - deltap_min
      max_suction_pressure_min = (max_suction_min).round(2)
    end
        
    hydraulic_turbine.update_attributes(
      :su_total_suction_dp_max => suction_total_dp_max,
      :su_pressure_at_suction_nozzle_max => pressure_suction_nozzle_max,    
      :su_max_pressure_at_suction_nozzle_max => max_suction_pressure_max,
      
      :su_total_suction_dp_nor => suction_total_dp_nor,
      :su_pressure_at_suction_nozzle_nor => pressure_suction_nozzle_nor,
      :su_max_pressure_at_suction_nozzle_nor => max_suction_pressure_nor,
      
      :su_total_suction_dp_min => suction_total_dp_min,
      :su_pressure_at_suction_nozzle_min => pressure_suction_nozzle_min,
      :su_max_pressure_at_suction_nozzle_min => max_suction_pressure_min
    )
    hydraulic_turbine.save
    
    respond_to do |format|
      format.json {render :json => calculated_values}
    end
  end

  def hprt_suctionside_hydraulics
	  calculated_values = {}
	  hydraulic_turbine = HydraulicTurbine.find(params[:hydraulic_turbine_id])
	  project = hydraulic_turbine.project
    
    #units 
    pressure_differential = project.measure_unit("Pressure", "Differential")
        
	  pipe_id         = (1..100).to_a
	  length          = (1..100).to_a
	  flow_percentage = (1..100).to_a
	  reynold_number  = (1..100).to_a
	  ft              = (1..100).to_a
	  kfi             = (1..100).to_a
	  doverdi         = (1..100).to_a
	  nre             = (1..100).to_a
	  kfii            = (1..100).to_a
	  kfd             = (1..100).to_a
	  f               = (1..100).to_a
	  kff             = (1..100).to_a
	  doverdii        = (1..100).to_a
	  elevation       = (1..100).to_a
	  pressure_drop   = (1..100).to_a
	  pi = 3.14159265358979

	  barometric_pressure = project.barometric_pressure
	  pipe_roughness = project.project_pipes[0].roughness
	  e = pipe_roughness
	  e = e/12

	  hydraulic_turbine_circuit_pipings = hydraulic_turbine.hydraulic_turbine_circuit_pipings
	  count = hydraulic_turbine_circuit_pipings.size   
        
    (1..3).each do |basis|      

      if basis == 1
        relief_rate     = hydraulic_turbine.su_max_mass_flow_rate
        relief_pressure = hydraulic_turbine.su_max_pressure
        density         = hydraulic_turbine.su_max_density
        viscosity       = hydraulic_turbine.su_max_viscosity        
      elsif basis == 2
        relief_rate     = hydraulic_turbine.su_nor_mass_flow_rate
        relief_pressure = hydraulic_turbine.su_nor_pressure
        density         = hydraulic_turbine.su_nor_density
        viscosity       = hydraulic_turbine.su_nor_viscosity        
      elsif basis == 3
        relief_rate     = hydraulic_turbine.su_min_mass_flow_rate
        relief_pressure = hydraulic_turbine.su_min_pressure
        density         = hydraulic_turbine.su_min_density
        viscosity       = hydraulic_turbine.su_min_viscosity
      end
            
      (0..count-1).each do |p|
        circuit_piping = hydraulic_turbine_circuit_pipings[p]
        pipe_size = circuit_piping.pipe_size
        pipe_schedule = circuit_piping.pipe_schedule

        pipe_diameter = PipeSizing.determine_pipe_diameter(pipe_size, pipe_schedule)
        
        fitting = circuit_piping.fitting
        cv_dorifice = circuit_piping.ds_cv
        
        fitting_length    = circuit_piping.length
        fitting_elevation = circuit_piping.elev
        fitting_tag       = circuit_piping.fitting_tag
        per_flow          = circuit_piping.per_flow    
        
        pipe_id[p] = circuit_piping.pipe_id / 12
        length[p] = circuit_piping.length
        cv = circuit_piping.ds_cv
        dorifice = circuit_piping.ds_cv
        #PDrop = Worksheets("Hydraulic Turbine Circuit").Cells(15720 + nn, 91).Value #TODO
        p_drop = ""  
        
        relief_rate_1 = relief_rate * (per_flow/100)
        volumne_rate = relief_rate_1/density
        nre[p] = (0.52633 * relief_rate_1) / (pipe_id[p] * viscosity)
        
        #Determine new friction factor using Churchill's equation
        a = (2.457 * Math.log(1 / (((7 / nre[p]) ** 0.9) + (0.27 * (e / pipe_id[p]))))) ** 16
        b = (37530 / nre[p]) ** 16
        f[p] = 2 * ((8 / nre[p]) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)
        
        fd = 4 * f[p]
        nreynolds = nre[p]
        d = circuit_piping.pipe_id
        d1 = circuit_piping.pipe_id
        d2 = circuit_piping.per_flow
        
        pipe_fitting = PipeSizing.get_fitting_tag(circuit_piping.fitting)
        fitting_type = pipe_fitting[:value] 
        
        if fitting_type == 'Pipe'
          kf = 4 * f[p] * (length[p]/pipe_id[p])
        elsif fitting_type == "Control Valve" and p_drop == ""
          kf = ((29.9 * d ** 2)/ cv) ** 2
        elsif fitting_type == "Orifice" and p_drop == ""
          beta = cv_dorifice / d
          if nreynolds <= 10 ** 4
            beta = beta.round(2)
            pipe_reynold_number = nreynolds.round(0)
            #TODO
            #UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2) 
            #UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
            #UserFormOrificeCoefficientLR.Show 
            #FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
            flow_c = 1.0
          elsif nreynolds > 10 ** 4
            beta = beta.round(2)
            pipe_reynold_number = nreynolds.round(0)
            #TODO
            #UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
            #UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
            #UserFormOrificeCoefficientHR.Show
            #FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
            flow_c = 1
          end
          kf = (1 - beta ** 2) / (flow_c ** 2 * beta ** 4)
        elsif fitting_type == "Equipment"
          pressure_drop[p] = p_drop          
        elsif fitting_type == "Control Valve" and p_drop != ""
          pressure_drop[p] = p_drop
        elsif fitting_type == "Orifice" and p_drop != ""
          pressure_drop[p] = p_drop
        else          
          resistance_coefficient_values = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)        
          kf = resistance_coefficient_values[:kf]
          dorifice = resistance_coefficient_values[:dover_d]
        end
        
        kfii[p] = kf.to_f
        doverdii[p] = dorifice
          
        kfd[p] = kfii[p] / ((pipe_id[p]) ** 4)
        
        if p == (count-1)
          pipe_id[p+1] = circuit_piping.pipe_id
        else
          pipe_id[p+1] = hydraulic_turbine_circuit_pipings[p+1].pipe_id
        end
         
        nre[p+1] = (0.52633 * relief_rate_1) / (pipe_id[p+1] * viscosity)

        #select Kinetic Energy Correction Factor
        if nre[p] <= 2000
          alpha1 = 2
        elsif nre[p] > 2000 and nre[p] < 10 ** 7 #highly turbulent assumed to start at 10^7
          alpha1 = 1
        elsif nre[p] > 10 ** 7
          alpha1 = 0.85
        end

        if nre[p] <= 2000
          alpha2 = 2
        elsif nre[p] > 2000 and nre[p] < 10 ** 7 #highly turbulent assumed to start at 10^7
          alpha2 = 1
        elsif nre[p] > 10 ** 7
          alpha2 = 0.85
        end

        kinetic_correction1 = alpha1 / pipe_id[p] ** 4        
        kinetic_correction2 = alpha2 / pipe_id[p+1] ** 4
        
        #Kinetic Energy + Frictional Loss
        sumof_ke_and_ef = (0.810569 * volumne_rate ** 2) * (kfd[p] + kinetic_correction2 - kinetic_correction1) #Units of ft^2/hr^2

        #Potential Energy
        elevation[p] = circuit_piping.elev
        pe  = 4.1698 * 10 **  8 * elevation[p]        
        pressure_drop[p] = density * ((sumof_ke_and_ef + pe) / (6.00444 * 10 ** 10)) 
                
        circuit_piping.update_attributes(:delta_p_max => pressure_drop[p].round(pressure_differential[:decimal_places])) if basis == 1
        circuit_piping.update_attributes(:delta_p_nor => pressure_drop[p].round(pressure_differential[:decimal_places])) if basis == 2
        circuit_piping.update_attributes(:delta_p_min => pressure_drop[p].round(pressure_differential[:decimal_places])) if basis == 3
        circuit_piping.save
      end
      
    end # 1..3 end
    
    #calculate fitting DP, Equipment DP, Control Valve DP, Orifice DP
    #assuming 51 for fitting type orifice 
    orifice_dp_max = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 51])
    orifice_dp_nor = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 51])
    orifice_dp_min = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 51])
    
    #assuming 49 for fitting type equipment
    equipment_dp_max = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 49])
    equipment_dp_nor = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 49])
    equipment_dp_min = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 49])
    
    #assuming 52 for fitting type control valve
    control_valve_dp_max = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_max, :conditions => ['fitting = ? ', 52])
    control_valve_dp_nor = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_nor, :conditions => ['fitting = ? ', 52])
    control_valve_dp_min = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_min, :conditions => ['fitting = ? ', 52])
    
    fitting_dp_max = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_max)
    fitting_dp_nor = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_nor)
    fitting_dp_min = hydraulic_turbine.hydraulic_turbine_circuit_pipings.sum(:delta_p_min)
    
    hydraulic_turbine.update_attributes(
      :su_fitting_dp_max => fitting_dp_max.round(pressure_differential[:decimal_places]),
      :su_equipment_dp_max => equipment_dp_max.round(pressure_differential[:decimal_places]),
      :su_control_valve_dp_max => control_valve_dp_max.round(pressure_differential[:decimal_places]),
      :su_orifice_dp_max => orifice_dp_max.round(pressure_differential[:decimal_places]),
      
      :su_fitting_dp_nor => fitting_dp_nor.round(pressure_differential[:decimal_places]),
      :su_equipment_dp_nor => equipment_dp_nor.round(pressure_differential[:decimal_places]),
      :su_control_valve_dp_nor => control_valve_dp_nor.round(pressure_differential[:decimal_places]),
      :su_orifice_dp_nor => orifice_dp_nor.round(pressure_differential[:decimal_places]),
      
      :su_fitting_dp_min => fitting_dp_min.round(pressure_differential[:decimal_places]),
      :su_equipment_dp_min => equipment_dp_min.round(pressure_differential[:decimal_places]),
      :su_control_valve_dp_min => control_valve_dp_min.round(pressure_differential[:decimal_places]),
      :su_orifice_dp_min => orifice_dp_min.round(pressure_differential[:decimal_places])      
    )
    hydraulic_turbine.save
    
    render :json => {:url => "ok"}    

  end
  
  #Discharge calculations
  def hprt_dischargeside_hydraulics
	  
    calculated_values = {}
	  hydraulic_turbine = HydraulicTurbine.find(params[:hydraulic_turbine_id])
	  project = hydraulic_turbine.project
    
    #units 
    pressure_differential = project.measure_unit("Pressure", "Differential")
    pressure_general = project.measure_unit("Pressure", "General")
    
    pipe_id         = (1..1000).to_a
	  length          = (1..1000).to_a
	  flow_percentage = (1..1000).to_a
	  reynold_number  = (1..1000).to_a
	  ft              = (1..1000).to_a
    kfi             = (1..1000).to_a
	  kff             = (1..1000).to_a
    kf_per_diameter = (1..1000).to_a
	  doverdi         = (1..1000).to_a
    elevation       = (1..1000).to_a
    pressure_drop   = (1..1000).to_a
    fittings        = (1..1000).to_a
    fitting_dp      = (1..1000).to_a
    fitting_circuit = (1..1000).to_a
    pipe_change_circuit = (1..1000).to_a
	  pi = 3.14159265358979

	  barometric_pressure = project.barometric_pressure
    pipe_roughness = project.project_pipes[0].roughness
    e = pipe_roughness/12
    	  
    (1..3).each do |basis|
      
      if basis == 1
        relief_rate     = hydraulic_turbine.su_max_mass_flow_rate
        relief_pressure = hydraulic_turbine.su_max_pressure
        density         = hydraulic_turbine.su_max_density
        viscosity       = hydraulic_turbine.su_max_viscosity        
      elsif basis == 2
        relief_rate     = hydraulic_turbine.su_nor_mass_flow_rate
        relief_pressure = hydraulic_turbine.su_nor_pressure
        density         = hydraulic_turbine.su_nor_density
        viscosity       = hydraulic_turbine.su_nor_viscosity        
      elsif basis == 3
        relief_rate     = hydraulic_turbine.su_min_mass_flow_rate
        relief_pressure = hydraulic_turbine.su_min_pressure
        density         = hydraulic_turbine.su_min_density
        viscosity       = hydraulic_turbine.su_min_viscosity
      end
      
      hydraulic_turbine.hydraulic_discharges.each do |discharge|
        
        hydraulic_discharge_circuit_pipings = discharge.hydraulic_discharge_circuit_pipings
        count = hydraulic_discharge_circuit_pipings.size
        
        (0..count-1).each do |h|
          circuit_piping = hydraulic_discharge_circuit_pipings[h]
          
          pipe_size = circuit_piping.pipe_size
          pipe_schedule = circuit_piping.pipe_schedule
          
          pipe_diameter = PipeSizing.determine_pipe_diameter(pipe_size, pipe_schedule)
          
          pipe_id[h] = circuit_piping.pipe_id
          length[h] = circuit_piping.length
          flow_percentage[h] = circuit_piping.per_flow
          cv =  circuit_piping.ds_cv
          dorifice = circuit_piping.ds_cv
          p_drop = ''
          p_drop = circuit_piping.delta_p_max if basis == 1
          p_drop = circuit_piping.delta_p_nor if basis == 2
          p_drop = circuit_piping.delta_p_min if basis == 3
          
          relief_rate_1 = relief_rate * (flow_percentage[h]/100)
          volumne_rate = relief_rate_1/density
          reynold_number[h] = (0.52633 * relief_rate_1) / (pipe_id[h] * viscosity)
          
          #Determine new friction factor using Churchill's equation
          a = (2.457 * Math.log(1 / (((7 / reynold_number[h]) ** 0.9) + (0.27 * (e / pipe_id[h]))))) ** 16 
          b = (37530 / reynold_number[h]) ** 16
          ft[h] = 2 * ((8 / reynold_number[h]) ** 12 + ( 1 / ((a + b) ** (3 / 2)))) ** (1 / 12) 
          
          fd = 4 * ft[h]
          nreynolds = reynold_number[h]
          d = circuit_piping.pipe_id
          d1 = circuit_piping.pipe_id
          d2 = circuit_piping.per_flow
          
          pipe_fitting = PipeSizing.get_fitting_tag(circuit_piping.fitting)
          fitting_type = pipe_fitting[:value]
          
          #raise fitting_type.to_yaml
          
          if fitting_type == 'Pipe'
            kf = 4 * f[p] * (length[p]/pipe_id[p])
          elsif fitting_type == "Control Valve" and p_drop == ""
            kf = ((29.9 * d ** 2)/ cv) ** 2
          elsif fitting_type == "Orifice" and p_drop == ""
            beta = dorifice / d
            
            if nreynolds <= 10 ** 4
              beta = beta.round(2)
              pipe_reynold_number = nreynolds.round(0)
              #TODO
              #UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2) 
              #UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
              #UserFormOrificeCoefficientLR.Show 
              #FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
              flow_c = 1.0
            elsif nreynolds > 10 ** 4
              beta = beta.round(2)
              pipe_reynold_number = nreynolds.round(0)
              #TODO
              #UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
              #UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
              #UserFormOrificeCoefficientHR.Show
              #FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
              flow_c = 1
            end
            kf = (1 - beta ** 2) / (flow_c ** 2 * beta ** 4)
          elsif fitting_type == "Equipment"
            pressure_drop[h] = p_drop          
          elsif fitting_type == "Control Valve" and p_drop != ""
            pressure_drop[h] = p_drop
          elsif fitting_type == "Orifice" and p_drop != ""
            pressure_drop[h] = p_drop
          else
            resistance_coefficient_values = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)            
            kf = resistance_coefficient_values[:kf]
            dover_d = resistance_coefficient_values[:dover_d]
          end #fitting_type end
          
          kfi[h] = kf.to_f
          doverdi[h] = dover_d
            
          kf_per_diameter[h] = kfi[h] / (pipe_id[h]) ** 4
          
          if h == (count-1)
            pipe_id[h+1] = circuit_piping.pipe_id
          else
            pipe_id[h+1] = hydraulic_discharge_circuit_pipings[h+1].pipe_id
          end
          
          reynold_number[h+1] = (0.52633 * relief_rate_1) / (pipe_id[h+1] * viscosity)
          
          #select Kinetic Energy Correction Factor
          if reynold_number[h] <= 2000
            alpha1 = 2
          elsif reynold_number[h] > 2000 && reynold_number[h] < 10 ** 7 #highly turbulent assumed to start at 10^7
            alpha1 = 1
          elsif reynold_number[h] > 10 ** 7
            alpha1 = 0.85
          end
          
          if reynold_number[h+1] <= 2000
            alpha2 = 2
          elsif reynold_number[h+1] > 2000 && reynold_number[h] < 10 ** 7 #highly turbulent assumed to start at 10^7
            alpha2 = 1
          elsif reynold_number[h+1] > 10 ** 7
            alpha2 = 0.85
          end
          
          kinetic_correction1 = alpha1 / (pipe_id[h]) ** 4
          kinetic_correction2 = alpha2 / (pipe_id[h+1]) ** 4
          
          #TODO
          #If PipeChangeCircuit(h + 1) <> PipeChangeCircuit(h) Then
          #  KineticCorrection1 = 0
          #  KineticCorrection2 = 0
          #Else
          #End If
          
          #Kinetic Energy + Frictional Loss
          sum_of_ke_and_ef = (0.810569 * volumne_rate ** 2) * (kf_per_diameter[h] + kinetic_correction2 - kinetic_correction1)
          
          #Potential Energy
          elevation[h] = circuit_piping.elev
          pe = 4.1698 * 10 ** 8 * elevation[h]
          pressure_drop[h] = density * ((sum_of_ke_and_ef + pe) / (6.00444 * 10 ** 10))
          
          circuit_piping.update_attributes(:delta_p_max => pressure_drop[h].round(pressure_differential[:decimal_places])) if basis == 1
          circuit_piping.update_attributes(:delta_p_nor => pressure_drop[h].round(pressure_differential[:decimal_places])) if basis == 2
          circuit_piping.update_attributes(:delta_p_min => pressure_drop[h].round(pressure_differential[:decimal_places])) if basis == 3
          circuit_piping.save       
          
        end #count
                
      end #discharge
            
    end #basis
    
    #51 for fitting type 'orifice'
    #49 for fitting type 'equipment'
    #52 for fitting type 'control valve'
    
    hydraulic_turbine.discharge_maximum.each do |dmax|
      orifice_dp_max = HydraulicDischargeCircuitPiping.where(:discharge_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 51])
      equipment_dp_max = HydraulicDischargeCircuitPiping.where(:discharge_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 49])
      control_valve_dp_max = HydraulicDischargeCircuitPiping.where(:discharge_maximum_path_id => dmax.id).sum(:delta_p_max, :conditions => ['fitting = ? ', 52])
      fitting_dp_max = HydraulicDischargeCircuitPiping.where(:discharge_maximum_path_id => dmax.id).sum(:delta_p_max)
      
      total_dp_max = fitting_dp_max + equipment_dp_max + control_valve_dp_max + orifice_dp_max
      pressure_at_discharge_nozzle = total_dp_max.to_f + dmax.destination_pressure.to_f
            
      dmax.update_attributes(          
        :fitting_dp => fitting_dp_max.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_max.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_max.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_max.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_max.round(pressure_general[:decimal_places]),
        :pressure_at_discharge_nozzle_dp => pressure_at_discharge_nozzle.round(pressure_general[:decimal_places])        
      )
      dmax.save          
    end
    
    hydraulic_turbine.discharge_normal.each do |dnor|          
      orifice_dp_nor = HydraulicDischargeCircuitPiping.where(:discharge_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 51])
      equipment_dp_nor = HydraulicDischargeCircuitPiping.where(:discharge_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 49])
      control_valve_dp_nor = HydraulicDischargeCircuitPiping.where(:discharge_normal_path_id => dnor.id).sum(:delta_p_nor, :conditions => ['fitting = ? ', 52])
      fitting_dp_nor = HydraulicDischargeCircuitPiping.where(:discharge_normal_path_id => dnor.id).sum(:delta_p_nor)
      
      total_dp_nor = fitting_dp_nor + equipment_dp_nor + control_valve_dp_nor + orifice_dp_nor
      pressure_at_discharge_nozzle = total_dp_nor.to_f + dnor.destination_pressure.to_f
      
      dnor.update_attributes(
        :fitting_dp => fitting_dp_nor.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_nor.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_nor.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_nor.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_nor.round(pressure_general[:decimal_places]),
        :pressure_at_discharge_nozzle_dp => pressure_at_discharge_nozzle.round(pressure_general[:decimal_places])
      )
      dnor.save
    end
    
    hydraulic_turbine.discharge_minimum.each do |dmin|
      orifice_dp_min = HydraulicDischargeCircuitPiping.where(:discharge_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 51])
      equipment_dp_min = HydraulicDischargeCircuitPiping.where(:discharge_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 49])
      control_valve_dp_min = HydraulicDischargeCircuitPiping.where(:discharge_minimum_path_id => dmin.id).sum(:delta_p_min, :conditions => ['fitting = ? ', 52])
      fitting_dp_min = HydraulicDischargeCircuitPiping.where(:discharge_minimum_path_id => dmin.id).sum(:delta_p_min)
      
      total_dp_min = fitting_dp_min + equipment_dp_min + control_valve_dp_min + orifice_dp_min
      pressure_at_discharge_nozzle = total_dp_min.to_f + dmin.destination_pressure.to_f
      
      dmin.update_attributes(
        :fitting_dp => fitting_dp_min.round(pressure_differential[:decimal_places]),
        :equipment_dp => equipment_dp_min.round(pressure_differential[:decimal_places]), 
        :control_valve_dp => control_valve_dp_min.round(pressure_differential[:decimal_places]), 
        :orifice_dp => orifice_dp_min.round(pressure_differential[:decimal_places]),
        :total_system_dp => total_dp_min.round(pressure_general[:decimal_places]),
        :pressure_at_discharge_nozzle_dp => pressure_at_discharge_nozzle.round(pressure_general[:decimal_places])
      ) 
      dmin.save        
    end
        
	  render :json => {:url => "ok"}
	end
 
  def hydraulic_turbine_design
    
    calculated_values = {}
    hydraulic_turbine = HydraulicTurbine.find(params[:hydraulic_turbine_id])
    project = hydraulic_turbine.project
    
    #maximum
    pressure_at_suction_nozzle_max = hydraulic_turbine.su_pressure_at_suction_nozzle_max
    pressure_at_discharge_nozzle_max = hydraulic_turbine.discharge_maximum.maximum('pressure_at_discharge_nozzle_dp')
    differential_pressure_max = (pressure_at_discharge_nozzle_max - pressure_at_suction_nozzle_max).abs
        
    density_max = hydraulic_turbine.su_max_density    
    differential_head_max = (144 * differential_pressure_max) / density_max
    safety_factor = project.hydraulic_power_recovery_turbine_design_safety_factor / 100
    required_diff_head_max = differential_head_max * (1 - safety_factor)
    
    massflowrate_max = hydraulic_turbine.su_max_mass_flow_rate 
    flow_rate_max = (massflowrate_max * 7.4805) / (density_max * 60)    
    sg_max = density_max / 62.4
    hydraulic_power_max = (flow_rate_max * required_diff_head_max * sg_max) / 3960
    efficiency_max = project.hydraulic_power_recovery_turbine_efficiency
    brake_hp_max = hydraulic_power_max / efficiency_max
    
    equipment_brake_hp = hydraulic_turbine.htd_red_horsepower
    balance_brake_hp_max = equipment_brake_hp - brake_hp_max
    
    #normal
    pressure_at_suction_nozzle_nor = hydraulic_turbine.su_pressure_at_suction_nozzle_nor
    pressure_at_discharge_nozzle_nor = hydraulic_turbine.discharge_normal.maximum('pressure_at_discharge_nozzle_dp')
    differential_pressure_nor = (pressure_at_discharge_nozzle_nor - pressure_at_suction_nozzle_nor).abs
    
    density_nor = hydraulic_turbine.su_nor_density    
    differential_head_nor = (144 * differential_pressure_nor) / density_nor
    safety_factor = project.hydraulic_power_recovery_turbine_design_safety_factor / 100
    required_diff_head_nor = differential_head_nor * (1 - safety_factor)
    
    massflowrate_nor = hydraulic_turbine.su_nor_mass_flow_rate 
    flow_rate_nor = (massflowrate_nor * 7.4805) / (density_nor * 60)    
    sg_nor = density_nor / 62.4
    hydraulic_power_nor = (flow_rate_nor * required_diff_head_nor * sg_nor) / 3960
    efficiency_nor = project.hydraulic_power_recovery_turbine_efficiency
    brake_hp_nor = hydraulic_power_nor / efficiency_nor
    
    equipment_brake_hp = hydraulic_turbine.htd_red_horsepower
    balance_brake_hp_nor = equipment_brake_hp - brake_hp_nor

#TODO for 3 balance brake hp
=begin    
    If BalanceBrakeHP <= 0 Then
    msg2 = MsgBox("The hydraulic turbine is capable of providing the full complement of horsepower required to power the associated rotating equipment.", vbOKOnly, "Supplemental Driver Required")
    BalanceBrakeHP = 0
    ElseIf BalanceBrakeHP > 0 Then
    msg2 = MsgBox("The hydraulic turbine does not have the full horsepower requirement to power the associated rotating equipment and therefore will need a " & Chr(34) & "helper" & Chr(34) & " driver in supplemental service." & Chr(13) & Chr(13) _
    "When possible, the supplemental driver is an electric motor with the full horsepower rating to power the associated equipment on its own.", vbOKOnly, "Supplemental Driver Required")
    BalanceBrakeHP = Abs(BalanceBrakeHP)
    Else
    End If
=end
       
    #minimum
    pressure_at_suction_nozzle_min = hydraulic_turbine.su_pressure_at_suction_nozzle_min
    pressure_at_discharge_nozzle_min = hydraulic_turbine.discharge_minimum.maximum('pressure_at_discharge_nozzle_dp')
    differential_pressure_min = (pressure_at_discharge_nozzle_min - pressure_at_suction_nozzle_min).abs
    
    density_min = hydraulic_turbine.su_min_density    
    differential_head_min = (144 * differential_pressure_min) / density_min
    safety_factor = project.hydraulic_power_recovery_turbine_design_safety_factor / 100
    required_diff_head_min = differential_head_min * (1 - safety_factor)
    
    massflowrate_min = hydraulic_turbine.su_min_mass_flow_rate 
    flow_rate_min = (massflowrate_min * 7.4805) / (density_min * 60)
    sg_min = density_min / 62.4
    hydraulic_power_min = (flow_rate_min * required_diff_head_min * sg_min) / 3960
    efficiency_min = project.hydraulic_power_recovery_turbine_efficiency
    brake_hp_min = hydraulic_power_min / efficiency_min
    
    equipment_brake_hp = hydraulic_turbine.htd_red_horsepower
    balance_brake_hp_min = equipment_brake_hp - brake_hp_min
    
    hydraulic_turbine.update_attributes(
      :htd_td_pressure_at_suction_nozzle_max => pressure_at_suction_nozzle_max,
      :htd_td_pressure_at_suction_nozzle_nor => pressure_at_suction_nozzle_nor,
      :htd_td_pressure_at_suction_nozzle_min => pressure_at_suction_nozzle_min,
      
      :htd_td_pressure_at_discharge_nozzle_max => pressure_at_discharge_nozzle_max,
      :htd_td_pressure_at_discharge_nozzle_nor => pressure_at_discharge_nozzle_nor,
      :htd_td_pressure_at_discharge_nozzle_min => pressure_at_discharge_nozzle_min,
      
      :htd_td_differential_pressure_max => differential_pressure_max.round(1),
      :htd_td_differential_pressure_nor => differential_pressure_nor.round(1),
      :htd_td_differential_pressure_min => differential_pressure_min.round(1),
      
      :htd_td_differential_head_max => differential_head_max.round(0),
      :htd_td_differential_head_nor => differential_head_nor.round(0),
      :htd_td_differential_head_min => differential_head_min.round(0),
      
      :htd_tap_flow_rate_max => flow_rate_max.round(0),      
      :htd_tap_flow_rate_nor => flow_rate_nor.round(0),
      :htd_tap_flow_rate_min => flow_rate_min.round(0),
      
      :htd_tap_sg_max => sg_max.round(3),
      :htd_tap_sg_nor => sg_nor.round(3),
      :htd_tap_sg_min => sg_min.round(3),
      
      :htd_tap_hydraulic_hp_max => hydraulic_power_max.round(1),
      :htd_tap_hydraulic_hp_nor => hydraulic_power_nor.round(1),
      :htd_tap_hydraulic_hp_min => hydraulic_power_min.round(1),
      
      :htd_tap_efficiency_max => efficiency_max.round(0),
      :htd_tap_efficiency_nor => efficiency_nor.round(0),
      :htd_tap_efficiency_min => efficiency_min.round(0),
      
      :htd_tap_brake_horsepower_max => brake_hp_max.round(1),
      :htd_tap_brake_horsepower_nor => brake_hp_nor.round(1),
      :htd_tap_brake_horsepower_min => brake_hp_min.round(1),
      
      :htd_pb_brake_horsepower_max => balance_brake_hp_max.round(1),
      :htd_pb_brake_horsepower_nor => balance_brake_hp_nor.round(1),
      :htd_pb_brake_horsepower_min => balance_brake_hp_min.round(1)      
    )
    
    render :json => {:url => "ok", :tab=>params[:tab], :calculate_btn=> params[:calculate_btn]}
  end

  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Driver Sizing', :url => admin_driver_sizings_path }
    @breadcrumbs << { :name => 'Hydraulic Turbine', :url => admin_driver_sizings_path(:anchor => "hydraulic_turbine")}
  end

  def get_equiment_tag_by_equiment_type
	  render :json => get_equipment_tags(params)
  end

  def get_rotating_equipment_details
    equipment_details = {}    
    equipment_type = params[:equipment_type]
    equipment_tag = params[:equipment_tag]
    
    #TODO re-check mappings
    if equipment_type == "Centrifugal Pump" || equipment_type == "Reciprocating Pump"      
      pump_sizing = PumpSizing.find(equipment_tag)
      if equipment_type == "Centrifugal Pump"
        equipment_details[:capacity] = pump_sizing.cd_flow_rate
        equipment_details[:differential_pressure] = pump_sizing.cd_differential_pressure
        equipment_details[:horsepower] = pump_sizing.cd_brake_horsepower
        equipment_details[:speed] = ""
      elsif equipment_type == "Reciprocating Pump"
        equipment_details[:capacity] = pump_sizing.rd_rated_discharge_capacity
        equipment_details[:differential_pressure] = pump_sizing.rd_differential_pressure
        equipment_details[:horsepower] = pump_sizing.rd_brake_horsepower
        equipment_details[:speed] = ""
      end
    elsif equipment_type == "Centrifugal Compressor" || equipment_type == "Reciprocating Compressor"
       compressor_sizing = CompressorSizing.find(equipment_tag)        
       if equipment_type == "Centrifugal Compressor"
         equipment_details[:capacity] = ""
         equipment_details[:differential_pressure] = compressor_sizing.cd_overall_differential_pressure
         equipment_details[:horsepower] = ""
         equipment_details[:speed] = ""
       elsif equipment_type == "Reciprocating Compressor"
         equipment_details[:capacity] = ""
         equipment_details[:differential_pressure] = compressor_sizing.rd_overall_differential_pressure
         equipment_details[:horsepower] = ""
         equipment_details[:speed] = ""
       end
    end
    respond_to do |format|
      format.json {render :json => equipment_details}     
    end
  end

  
  private
  
  def default_form_values

    @hydraulic_turbine = @company.hydraulic_turbines.find(params[:id]) rescue @company.hydraulic_turbines.new
    @comments = @hydraulic_turbine.comments
    @new_comment = @hydraulic_turbine.comments.new

    @attachments = @hydraulic_turbine.attachments
    @new_attachment = @hydraulic_turbine.attachments.new

    @project = @user_project_settings.project
    @streams = []   
	@equipment_tags = []
    
    @suction_condition_basis = [        
                                {:name=>"Maximum", :value=>"maximum"},
                                {:name=>"Normal/Design", :value=>"normal"},
                                {:name=>"Minimum/Turndown", :value=>"minimum"}
                               ]
  end

  def get_equipment_tags(params)
	  equipment_type = params[:equipment_type]    
	  project = Project.find(params[:project_id])
	  equipment_tag = []       
	  if equipment_type == "Centrifugal Pump" || equipment_type == "Reciprocating Pump"      
		  rs_pump_sizings = project.pump_sizings    
		  rs_pump_sizings.each do |rs_pump_sizing|
			  equipment_tag << {:id => rs_pump_sizing.id, :tag => rs_pump_sizing.centrifugal_pump_tag}
		  end
	  elsif equipment_type == "Centrifugal Compressor" || equipment_type == "Reciprocating Compressor"      
		  rs_compressor_sizing_tags = project.compressor_sizing_tags
		  rs_compressor_sizing_tags.each do |rs_compressor_sizing_tag|        
			  rs_compressor_sizing = rs_compressor_sizing_tag.compressor_sizings.where(:selected_sizing => true).first                
			  equipment_tag << {:id => rs_compressor_sizing.id, :tag => rs_compressor_sizing_tag.compressor_sizing_tag} if !rs_compressor_sizing.nil?
		  end      
	  end
	  return equipment_tag
  end

end
