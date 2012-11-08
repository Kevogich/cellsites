class Admin::SteamTurbinesController < AdminController
  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]
  
  def new
    @steam_turbine = @company.steam_turbines.new   
  end
    
  def create
    steam_turbine = params[:steam_turbine]
    steam_turbine[:created_by] = steam_turbine[:updated_by] = current_user.id    
    @steam_turbine = @company.steam_turbines.new(steam_turbine) 
    
    if !@steam_turbine.ssc_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@steam_turbine.ssc_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
    
    if !@steam_turbine.std_equipment_type.nil?
      @equipment_tag = get_equiment_tag(@steam_turbine.std_equipment_type, @project.id)
    end
        
    if @steam_turbine.save
      @steam_turbine.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      flash[:notice] = "New steam turbine created successfully."
      redirect_to admin_driver_sizings_path(:anchor => "steam_turbine")
    else
      render :new
    end
  end
  
  def edit
    @steam_turbine = @company.steam_turbines.find(params[:id])
        
    if !@steam_turbine.ssc_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@steam_turbine.ssc_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
    
    if !@steam_turbine.std_equipment_type.nil?
      @equipment_tag = get_equiment_tag(@steam_turbine.std_equipment_type, @project.id)
    end
  end
  
  def update
    steam_turbine = params[:steam_turbine]
    steam_turbine[:updated_by] = current_user.id
    @steam_turbine = @company.steam_turbines.find(params[:id])    
    
    if !@steam_turbine.ssc_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@steam_turbine.ssc_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
        
    if !steam_turbine[:std_equipment_type].nil?
      @equipment_tag = get_equiment_tag(steam_turbine[:std_equipment_type], @project.id)
    end    
    
    if @steam_turbine.update_attributes(steam_turbine)
      if !params[:calculate_btn].blank?
        flash[:notice] = "Updated stream turbine values."
        redirect_to edit_admin_steam_turbine_path(:id=>@steam_turbine.id, :calculate_btn=>params[:calculate_btn], :anchor=>params[:tab])
      else
        flash[:notice] = "Updated steam turbine successfully."
        redirect_to admin_driver_sizings_path(:anchor => "steam_turbine")
      end
    else      
      render :edit
    end
  end
  
  def destroy
    @steam_turbine = @company.steam_turbines.find(params[:id])
    if @steam_turbine.destroy
      flash[:notice] = "Deleted #{@steam_turbine.steam_turbine_tag} successfully."
      redirect_to admin_driver_sizings_path(:anchor => "steam_turbine")
    end
  end

  def clone
      @steam_turbine = @company.steam_turbines.find(params[:id])
	  new = @steam_turbine.clone :except => [:created_at, :updated_at]
	  new.steam_turbine_tag = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_steam_turbine_path(new) }
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
    
    density = property.where(:phase => "Overall", :property => "Mass Density").first
    density_stream = density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:density] = density_stream.stream_value.to_f rescue nil
    
    enthalpy = property.where(:phase => "Overall", :property => "Mass Density").first
    enthalpy_stream = enthalpy.streams.where(:stream_no => params[:stream_no]).first
    form_values[:enthalpy] = enthalpy_stream.stream_value.to_f rescue nil
    
    render :json => form_values
  end
  
  def steam_turbine_summary
    @steam_turbines = @company.steam_turbines.all    
  end
  
  def get_equiment_tag_by_equiment_type
    equipment_type = params[:equipment_type] 
    project_id = params[:project_id]
    
    equiment_tag = get_equiment_tag(equipment_type, project_id)    
    
    respond_to do |format|
      format.json {render :json => equiment_tag}     
    end    
  end
  
  #get equiment tag
  def get_equiment_tag(equipment_type, project_id)
    project = Project.find(project_id)
    equiment_tag = []
    
    if equipment_type == "Centrifugal Pump" || equipment_type == "Reciprocating Pump"      
      rs_pump_sizings = project.pump_sizings    
      rs_pump_sizings.each do |rs_pump_sizing|
        equiment_tag << {:id => rs_pump_sizing.id, :tag => rs_pump_sizing.centrifugal_pump_tag}
      end
    elsif equipment_type == "Centrifugal Compressor" || equipment_type == "Reciprocating Compressor"      
      rs_compressor_sizing_tags = project.compressor_sizing_tags
      rs_compressor_sizing_tags.each do |rs_compressor_sizing_tag|        
        rs_compressor_sizing = rs_compressor_sizing_tag.compressor_sizings.where(:selected_sizing => true).first                
        equiment_tag << {:id => rs_compressor_sizing.id, :tag => rs_compressor_sizing_tag.compressor_sizing_tag} if !rs_compressor_sizing.nil?
      end      
    end
    
    return equiment_tag    
  end  
  
  def get_rotating_equipment_details
    equipment_details = {}    
    equipment_type = params[:equipment_type]
    equipment_tag = params[:equipment_tag]    
    
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
         centrifugal_compressor = compressor_sizing.compressor_centrifugal_designs.first
         horsepower = compressor_sizing.compressor_centrifugal_designs.sum(:brake_horsepower)
         
         equipment_details[:capacity] = centrifugal_compressor.flow_rate rescue 0
         equipment_details[:differential_pressure] = compressor_sizing.cd_overall_differential_pressure
         equipment_details[:horsepower] = horsepower
         equipment_details[:speed] = ""
       elsif equipment_type == "Reciprocating Compressor"
         reciprocating_compressor =  compressor_sizing.compressor_reciprocation_designs.first
         horsepower = compressor_sizing.compressor_reciprocation_designs.sum(:brake_horsepower)
         
         equipment_details[:capacity] = reciprocating_compressor.capacity rescue 0
         equipment_details[:differential_pressure] = compressor_sizing.rd_overall_differential_pressure
         equipment_details[:horsepower] = horsepower
         equipment_details[:speed] = ""
       end
    end
        
    respond_to do |format|
      format.json {render :json => equipment_details}     
    end
  end
  
  def steam_turbine_design_calculate
    calculated_values = {}
    
    steam_turbine = SteamTurbine.find(params[:steam_turbine_id])
    project = steam_turbine.project
        
    rated_speed = (1..100).to_a
    rated_horsepower = (1..100).to_a
    rated_speed_low = (1..100).to_a
    rated_speed_high = (1..100).to_a
    rated_horsepower_low = (1..100).to_a
    rated_horsepower_high = (1..100).to_a
    rated_speed_cf_low = (1..100).to_a
    rated_speed_cf_high = (1..100).to_a
    inlet_steam_pressure_be = (1..100).to_a
    inlet_steam_pressure_be_low = (1..100).to_a
    inlet_steam_pressure_be_high = (1..100).to_a
    basis_efficiency = (1..100).to_a
    basis_efficiency_low = (1..100).to_a
    basis_efficiency_high = (1..100).to_a
    approximate_steam_rate = (1..100).to_a
    approximate_steam_rate_low = (1..100).to_a
    approximate_steam_rate_high = (1..100).to_a
    single_stage_speed = (1..100).to_a
    single_stage_speed_low = (1..100).to_a
    single_stage_speed_high = (1..100).to_a
    single_stage_pressure_ratio = (1..100).to_a
    single_stage_pressure_ratio_low = (1..100).to_a
    single_stage_pressure_ratio_high = (1..100).to_a
            
    lbl_actual_steam_rate_label = "Actual Steam Rate"
    
    if steam_turbine.ssc_mininum == true
      inlet_pressure = steam_turbine.ssc_min_steam_supply_pressure
      inlet_temperature = steam_turbine.ssc_min_steam_supply_temperature
      saturated_temperature = steam_turbine.ssc_min_steam_saturation_temperature
      inlet_enthalpy = steam_turbine.ssc_min_steam_enthalpy
      inlet_entropy = steam_turbine.ssc_min_steam_entropy
      inlet_vapor_density = steam_turbine.ssc_min_steam_density
      
      inlet_steam_condition = steam_turbine.ssc_steam_phase_min
    elsif steam_turbine.ssc_normal == true
      inlet_pressure = steam_turbine.ssc_nor_steam_supply_pressure
      inlet_temperature = steam_turbine.ssc_nor_steam_supply_temperature
      saturated_temperature = steam_turbine.ssc_nor_steam_saturation_temperature
      inlet_enthalpy = steam_turbine.ssc_nor_steam_enthalpy
      inlet_entropy = steam_turbine.ssc_nor_steam_entropy
      inlet_vapor_density = steam_turbine.ssc_nor_steam_density
      
      inlet_steam_condition = steam_turbine.ssc_steam_phase_nor
    elsif steam_turbine.ssc_maximum == true
      inlet_pressure = steam_turbine.ssc_max_steam_supply_pressure
      inlet_temperature = steam_turbine.ssc_max_steam_supply_temperature
      saturated_temperature = steam_turbine.ssc_max_steam_saturation_temperature
      inlet_enthalpy = steam_turbine.ssc_max_steam_enthalpy
      inlet_entropy = steam_turbine.ssc_max_steam_entropy
      inlet_vapor_density = steam_turbine.ssc_max_steam_density
      
      inlet_steam_condition = steam_turbine.ssc_steam_phase_max
    end
    
    if steam_turbine.sec_mininum == true
      exhaust_pressure = steam_turbine.sec_min_steam_exhaust_pressure
      exhaust_temperature = steam_turbine.sec_min_steam_exhaust_temperature
      #exhaust_saturation_temperature = steam_turbine.sec_min_steam_saturation_temperature
      exhaust_vapor_density = steam_turbine.sec_min_steam_density
      exhaust_vapor_entropy = steam_turbine.sec_min_steam_entropy
      exhaust_vapor_enthalpy = steam_turbine.sec_min_steam_enthalpy
      exhaust_liquid_entropy = steam_turbine.sec_min_water_entropy
      exhaust_liquid_enthalpy = steam_turbine.sec_min_water_enthalpy      
    elsif steam_turbine.sec_normal == true
      exhaust_pressure = steam_turbine.sec_nor_steam_exhaust_pressure
      exhaust_temperature = steam_turbine.sec_nor_steam_exhaust_temperature
      #exhaust_saturation_temperature = steam_turbine.sec_nor_steam_saturation_temperature
      exhaust_vapor_density = steam_turbine.sec_nor_steam_density
      exhaust_vapor_entropy = steam_turbine.sec_nor_steam_entropy
      exhaust_vapor_enthalpy = steam_turbine.sec_nor_steam_enthalpy
      exhaust_liquid_entropy = steam_turbine.sec_nor_water_entropy
      exhaust_liquid_enthalpy = steam_turbine.sec_nor_water_enthalpy
    elsif steam_turbine.sec_maximum == true
      exhaust_pressure = steam_turbine.sec_max_steam_exhaust_pressure
      exhaust_temperature = steam_turbine.sec_max_steam_exhaust_temperature
      #exhaust_saturation_temperature = steam_turbine.sec_max_steam_saturation_temperature
      exhaust_vapor_density = steam_turbine.sec_max_steam_density
      exhaust_vapor_entropy = steam_turbine.sec_max_steam_entropy
      exhaust_vapor_enthalpy = steam_turbine.sec_max_steam_enthalpy
      exhaust_liquid_entropy = steam_turbine.sec_max_water_entropy
      exhaust_liquid_enthalpy = steam_turbine.sec_max_water_enthalpy
    end
    
    horsepower = steam_turbine.std_horsepower
    speed = steam_turbine.std_speed
    
    barometric_pressure = project.barometric_pressure
    
    inlet_steam_pressure = inlet_pressure + barometric_pressure
    exhaust_steam_pressure = exhaust_pressure + barometric_pressure
    pressure_ratio = exhaust_steam_pressure / inlet_steam_pressure
    
    #Determine Degree of Inlet Superheat
    degree_of_super_heat = inlet_temperature - saturated_temperature
    
    #Determine Exhaust Phase    
    if inlet_entropy == exhaust_vapor_entropy
      exhaust_phase = "Vapor - Saturated"
    elsif inlet_entropy > exhaust_vapor_entropy
      exhaust_phase = "Vapor - Superheated"
    elsif inlet_entropy < exhaust_vapor_entropy
      exhaust_phase = "Two Phase"
    elsif inlet_entropy == exhaust_liquid_entropy
      exhaust_phase = "Saturated Liquid"
    end
      
    if steam_turbine.sec_mininum == true
      lbl_exhaust_steam_phase_min = exhaust_phase
    elsif steam_turbine.sec_normal == true
      lbl_exhaust_steam_phase_nor = exhaust_phase
    elsif steam_turbine.sec_maximum == true
      lbl_exhaust_steam_phase_max = exhaust_phase
    end
      
    if exhaust_phase == "Vapor - Saturated"
      exhaust_enthalpy = exhaust_vapor_enthalpy
      exhaust_entropy = exhaust_vapor_entropy
    elsif exhaust_phase == "Vapor - Superheated"
      exhaust_enthalpy = exhaust_vapor_enthalpy
      exhaust_entropy = exhaust_vapor_entropy
    elsif exhaust_phase == "Two Phase"
      exhaust_liquid_fraction = (inlet_entropy - exhaust_vapor_entropy) / (exhaust_liquid_entropy - exhaust_vapor_entropy) #Determine the vapor fraction based on constant entropy (isentropic conditions)if Exhaust Phase is Two Phase
      exhaust_enthalpy = (1 - exhaust_liquid_fraction) * exhaust_vapor_enthalpy + (exhaust_liquid_fraction * exhaust_liquid_enthalpy)
      exhaust_entropy = inlet_entropy
    elsif exhaust_phase == "Saturated Liquid"
      exhaust_enthalpy = exhaust_liquid_enthalpy
      exhaust_entropy = exhaust_liquid_entropy
    end
   
    #Determine Change in Enthalpy in hp-hr (converted from Btu)
    delta_enthalpy = (exhaust_enthalpy - inlet_enthalpy) / 2544
    delta_enthalpy1 = (exhaust_enthalpy - inlet_enthalpy)
    
    #Determine Theoretical Steam Rate lb/(hp-hr)
    tsr = (1 / delta_enthalpy).abs
    
    #Determine Corrected Efficiency
    efficiency = steam_turbine.std_efficiency / 100

    #Determine Actual Steam Rate (ASR)
    asr = tsr / efficiency

    #Determine SteamRate
    steam_flow_rate = asr * horsepower
        
    #Determine steam turbine type (condensing, non-condensing) and max steam velocity for inlet and outlet nozzle
    turbine_type = steam_turbine.std_turbine_type
    
    if turbine_type == "Non-Condensing"
      maximum_inlet_steam_velocity = 175
      maximum_exhaust_steam_velocity = 250
    elsif turbine_type == "Condensing"
      maximum_inlet_steam_velocity = 175
      maximum_exhaust_steam_velocity = 450
    end
    
    inlet_nozzle_diameter = ((0.051 * steam_flow_rate) / (inlet_vapor_density * maximum_inlet_steam_velocity)) ** 0.5    
    rupture_diameter = inlet_nozzle_diameter
    determine_nominal_pipe_size_nozzle_values = determine_nominal_pipe_size_nozzle(rupture_diameter)    
    proposed_diameter = determine_nominal_pipe_size_nozzle_values[:proposed_diameter]
    inlet_max_velocity = ((0.051 * steam_flow_rate) / proposed_diameter ** 2) / inlet_vapor_density    
    lbl_inlet_nozzle_diameter = determine_nominal_pipe_size_nozzle_values[:pipe_size]
    lbl_max_velocity_at_inlet_nozzle = inlet_max_velocity.round(0)

    exhaust_nozzle_diameter = ((0.051 * steam_flow_rate) / (exhaust_vapor_density * maximum_exhaust_steam_velocity)) ** 0.5    
    rupture_diameter = exhaust_nozzle_diameter
    determine_nominal_pipe_size_nozzle_values = determine_nominal_pipe_size_nozzle(rupture_diameter)
    proposed_diameter = determine_nominal_pipe_size_nozzle_values[:proposed_diameter]
    exhaust_max_velocity = ((0.051 * steam_flow_rate) / proposed_diameter ** 2) / exhaust_vapor_density    
    lbl_exhaust_nozzle_diameter = determine_nominal_pipe_size_nozzle_values[:pipe_size]
    lbl_max_velocity_at_exhaust_nozzle = exhaust_max_velocity.round(0)
    
    lbl_theoretical_steam_rate = tsr.round(2)
    lbl_actual_steam_rate = asr.round(2)
    lbl_actual_steam_rate_label = "Actual Steam Rate"
    lbl_steam_flow_rate = steam_flow_rate
    lbl_isentropic_enthalpy_change = delta_enthalpy1.round(1)
    
    calculated_values[:lbl_theoretical_steam_rate] = lbl_theoretical_steam_rate
    #calculated_values[:lbl_basic_efficiency] = lbl_basic_efficiency
    #calculated_values[:lbl_degree_of_superheat] = lbl_degree_of_superheat
    #calculated_values[:lbl_superheat_efficiency_cf] = lbl_superheat_efficiency_cf    
    #calculated_values[:lbl_speed_efficiency_cf] = lbl_speed_efficiency_cf
    #calculated_values[:lbl_pressure_ratio_cf] = lbl_pressure_ratio_cf
    #calculated_values[:lbl_corrected_efficiency] = lbl_corrected_efficiency
    calculated_values[:lbl_actual_steam_rate] = lbl_actual_steam_rate
    calculated_values[:lbl_actual_steam_rate_label] = lbl_actual_steam_rate_label
    calculated_values[:lbl_steam_flow_rate] = lbl_steam_flow_rate      
    calculated_values[:lbl_isentropic_enthalpy_change] = lbl_isentropic_enthalpy_change    
    calculated_values[:lbl_inlet_nozzle_diameter] = lbl_inlet_nozzle_diameter
    calculated_values[:lbl_exhaust_nozzle_diameter] = lbl_exhaust_nozzle_diameter
    calculated_values[:lbl_max_velocity_at_inlet_nozzle] = lbl_max_velocity_at_inlet_nozzle
    calculated_values[:lbl_max_velocity_at_exhaust_nozzle] = lbl_max_velocity_at_exhaust_nozzle       
    
    log = CustomLogger.new("steamturbine")
    log.info("inlet_pressure:#{inlet_pressure}")
    log.info("inlet_temperature: #{inlet_temperature}")
    log.info("saturated_temperature: #{saturated_temperature}")
    log.info("inlet_enthalpy:#{inlet_enthalpy}")
    log.info("inlet_entropy: #{inlet_entropy}")
    log.info("inlet_vapor_density: #{inlet_vapor_density}")
    log.info("horsepower: #{horsepower}")
    log.info("speed: #{speed}")
    log.info("inlet_steam_pressure = inlet_pressure + barometric_pressure:#{inlet_pressure} #{barometric_pressure} #{barometric_pressure}")
    log.info("inlet_steam_pressure: #{inlet_steam_pressure}")
    log.info("exhaust_steam_pressure = exhaust_pressure + barometric_pressure: #{exhaust_steam_pressure} #{exhaust_pressure} #{barometric_pressure} ")
    log.info("pressure_ratio = exhaust_steam_pressure / inlet_steam_pressure: #{pressure_ratio} #{exhaust_steam_pressure} #{ inlet_steam_pressure}")
    log.info("degree_of_super_heat = inlet_temperature - saturated_temperature: #{degree_of_super_heat} #{inlet_temperature} #{saturated_temperature}")
    log.info("steam_turbine.std_ee_turbine_type:#{steam_turbine.std_ee_turbine_type}")
    log.info("exhaust_phase: #{exhaust_phase}")
    log.info("exhaust_enthalpy: #{exhaust_enthalpy}")
    log.info("exhaust_entropy: #{exhaust_entropy}")
    log.info("exhaust_liquid_fraction = (inlet_entropy - exhaust_vapor_entropy) / (exhaust_liquid_entropy - exhaust_vapor_entropy)")
    log.info("exhaust_liquid_fraction:#{exhaust_liquid_fraction}")
    log.info("exhaust_enthalpy = (1 - exhaust_liquid_fraction) * exhaust_vapor_enthalpy + (exhaust_liquid_fraction * exhaust_liquid_enthalpy)")
    log.info("delta_enthalpy = (exhaust_enthalpy - inlet_enthalpy) / 2544:#{delta_enthalpy}")
    log.info("tsr = (1 / delta_enthalpy).abs: #{tsr}")
    #log.info("corrected_efficiency = basis_efficiency_value * superheat_cf * speed_cf * pressure_ratio_cf:#{corrected_efficiency} ")
    #log.info("superheat_cf: #{superheat_cf}")
    #log.info("speed_cf: #{speed_cf}")
    #log.info("pressure_ratio_cf: #{pressure_ratio_cf}")
    log.info("asr = tsr / corrected_efficiency:#{asr}")
    log.info("steam_flow_rate = asr * horsepower: #{steam_flow_rate}")
    log.close   
       
    respond_to do |format|
      format.json {render :json => calculated_values}     
    end
  end
  
  def estimate_efficiency_calculation
    calculated_values = {}
    
    steam_turbine = SteamTurbine.find(params[:steam_turbine_id])
    steam_turbine.std_ee_turbine_type = params[:std_ee_turbine_type]
    steam_turbine.save
    
    project = steam_turbine.project
        
    rated_speed = (1..100).to_a
    rated_horsepower = (1..100).to_a
    rated_speed_low = (1..100).to_a
    rated_speed_high = (1..100).to_a
    rated_horsepower_low = (1..100).to_a
    rated_horsepower_high = (1..100).to_a
    rated_speed_cf_low = (1..100).to_a
    rated_speed_cf_high = (1..100).to_a
    inlet_steam_pressure_be = (1..100).to_a
    inlet_steam_pressure_be_low = (1..100).to_a
    inlet_steam_pressure_be_high = (1..100).to_a
    basis_efficiency = (1..100).to_a
    basis_efficiency_low = (1..100).to_a
    basis_efficiency_high = (1..100).to_a
    approximate_steam_rate = (1..100).to_a
    approximate_steam_rate_low = (1..100).to_a
    approximate_steam_rate_high = (1..100).to_a
    single_stage_speed = (1..100).to_a
    single_stage_speed_low = (1..100).to_a
    single_stage_speed_high = (1..100).to_a
    single_stage_pressure_ratio = (1..100).to_a
    single_stage_pressure_ratio_low = (1..100).to_a
    single_stage_pressure_ratio_high = (1..100).to_a
    
    lbl_actual_steam_rate_label = "Actual Steam Rate"
    
    if steam_turbine.ssc_mininum == true
      inlet_pressure = steam_turbine.ssc_min_steam_supply_pressure
      inlet_temperature = steam_turbine.ssc_min_steam_supply_temperature
      saturated_temperature = steam_turbine.ssc_min_steam_saturation_temperature
      inlet_enthalpy = steam_turbine.ssc_min_steam_enthalpy
      inlet_entropy = steam_turbine.ssc_min_steam_entropy
      inlet_vapor_density = steam_turbine.ssc_min_steam_density
      
      inlet_steam_condition = steam_turbine.ssc_steam_phase_min
    elsif steam_turbine.ssc_normal == true
      inlet_pressure = steam_turbine.ssc_nor_steam_supply_pressure
      inlet_temperature = steam_turbine.ssc_nor_steam_supply_temperature
      saturated_temperature = steam_turbine.ssc_nor_steam_saturation_temperature
      inlet_enthalpy = steam_turbine.ssc_nor_steam_enthalpy
      inlet_entropy = steam_turbine.ssc_nor_steam_entropy
      inlet_vapor_density = steam_turbine.ssc_nor_steam_density
      
      inlet_steam_condition = steam_turbine.ssc_steam_phase_nor
    elsif steam_turbine.ssc_maximum == true
      inlet_pressure = steam_turbine.ssc_max_steam_supply_pressure
      inlet_temperature = steam_turbine.ssc_max_steam_supply_temperature
      saturated_temperature = steam_turbine.ssc_max_steam_saturation_temperature
      inlet_enthalpy = steam_turbine.ssc_max_steam_enthalpy
      inlet_entropy = steam_turbine.ssc_max_steam_entropy
      inlet_vapor_density = steam_turbine.ssc_max_steam_density
      
      inlet_steam_condition = steam_turbine.ssc_steam_phase_max
    end
    
    if steam_turbine.sec_mininum == true
      exhaust_pressure = steam_turbine.sec_min_steam_exhaust_pressure
      exhaust_temperature = steam_turbine.sec_min_steam_exhaust_temperature
      #exhaust_saturation_temperature = steam_turbine.sec_min_steam_saturation_temperature
      exhaust_vapor_density = steam_turbine.sec_min_steam_density
      exhaust_vapor_entropy = steam_turbine.sec_min_steam_entropy
      exhaust_vapor_enthalpy = steam_turbine.sec_min_steam_enthalpy
      exhaust_liquid_entropy = steam_turbine.sec_min_water_entropy
      exhaust_liquid_enthalpy = steam_turbine.sec_min_water_enthalpy      
    elsif steam_turbine.sec_normal == true
      exhaust_pressure = steam_turbine.sec_nor_steam_exhaust_pressure
      exhaust_temperature = steam_turbine.sec_nor_steam_exhaust_temperature
      #exhaust_saturation_temperature = steam_turbine.sec_nor_steam_saturation_temperature
      exhaust_vapor_density = steam_turbine.sec_nor_steam_density
      exhaust_vapor_entropy = steam_turbine.sec_nor_steam_entropy
      exhaust_vapor_enthalpy = steam_turbine.sec_nor_steam_enthalpy
      exhaust_liquid_entropy = steam_turbine.sec_nor_water_entropy
      exhaust_liquid_enthalpy = steam_turbine.sec_nor_water_enthalpy
    elsif steam_turbine.sec_maximum == true
      exhaust_pressure = steam_turbine.sec_max_steam_exhaust_pressure
      exhaust_temperature = steam_turbine.sec_max_steam_exhaust_temperature
      #exhaust_saturation_temperature = steam_turbine.sec_max_steam_saturation_temperature
      exhaust_vapor_density = steam_turbine.sec_max_steam_density
      exhaust_vapor_entropy = steam_turbine.sec_max_steam_entropy
      exhaust_vapor_enthalpy = steam_turbine.sec_max_steam_enthalpy
      exhaust_liquid_entropy = steam_turbine.sec_max_water_entropy
      exhaust_liquid_enthalpy = steam_turbine.sec_max_water_enthalpy
    end
    
    horsepower = steam_turbine.std_horsepower
    speed = steam_turbine.std_speed
    
    barometric_pressure = project.barometric_pressure
    
    inlet_steam_pressure = inlet_pressure + barometric_pressure
    exhaust_steam_pressure = exhaust_pressure + barometric_pressure
    pressure_ratio = exhaust_steam_pressure / inlet_steam_pressure
    
    #Determine Degree of Inlet Superheat
    degree_of_super_heat = inlet_temperature - saturated_temperature   
    
    basis_efficiency_value = 0
    superheat_cf = 0
    speed_cf = 0
    pressure_ratio_cf = 0
        
    if steam_turbine.std_ee_turbine_type == "Multi-Stage, Multiple Valves" || steam_turbine.std_ee_turbine_type == "Multi-Stage, Single Valve"
      #Determine Basis Efficiency for both Non-Condensing, Condensing Turbines For Multi-Valve, Multi-Stage
      if steam_turbine.std_ee_turbine_type == "Multi-Stage, Multiple Valves"
        if steam_turbine.std_turbine_type == "Non-Condensing"          
          (1..6).each do |pp|            
            inlet_steam_pressure_be[pp] = SteamTurbine.non_condensing_turbine[0][pp]
            inlet_steam_pressure_be_low[pp] = SteamTurbine.non_condensing_turbine[0][pp]
            inlet_steam_pressure_be_high[pp] = SteamTurbine.non_condensing_turbine[0][pp+1]
            
            if inlet_steam_pressure == inlet_steam_pressure_be[pp]
              (1..15).each do |rr|                
                rated_horsepower[rr] = SteamTurbine.non_condensing_turbine[rr][0]
                rated_horsepower_low[rr] = SteamTurbine.non_condensing_turbine[rr][0]
                rated_horsepower_high[rr] = SteamTurbine.non_condensing_turbine[rr+1][0]
                basis_efficiency_low[rr] = SteamTurbine.non_condensing_turbine[rr][pp]
                basis_efficiency_high[rr] = SteamTurbine.non_condensing_turbine[rr+1][pp]
                
                if horsepower == rated_horsepower[rr]
                  basis_efficiency_value = SteamTurbine.non_condensing_turbine[rr][pp] / 100
                  rr = 15
                elsif horsepower > basis_efficiency_low[rr] && horsepower < basis_efficiency_high[rr]
                  delta_be = basis_efficiency_high[rr] - basis_efficiency_low[rr]
                  delta_hp = rated_horsepower_high[rr] - rated_horsepower_low[rr]
                  slope = delta_be / delta_hp
                  intercept = basis_efficiency_high[rr] - (slope * rated_horsepower_high[rr])
                  basis_efficiency_value = ((slope * horsepower) + intercept) / 100
                  rr = 15
                end
              end #1..15 end
              pp = 6
            elsif inlet_steam_pressure > inlet_steam_pressure_be_low[pp] && inlet_steam_pressure < inlet_steam_pressure_be_high[pp]
              #Determine Basis Efficiency for low end of the range
              if inlet_steam_pressure_be_low[pp] == 100
                basis_efficiency_low[pp] = -8.89958E-22 * horsepower ** 6 + 3.02946E-17 * horsepower ** 5 - 4.07467E-13 * horsepower ** 4 + 0.0000000027662 * horsepower ** 3 - 0.0000101172 * horsepower ** 2 + 0.0202528 * horsepower + 56.5221
              elsif inlet_steam_pressure_be_low[pp] == 200
                basis_efficiency_low[pp] = -8.89958E-22 * horsepower ** 6 + 3.02946E-17 * horsepower ** 5 - 4.07467E-13 * horsepower ** 4 + 0.0000000027662 * horsepower ** 3 - 0.0000101172 * horsepower ** 2 + 0.0202528 * horsepower + 56.5221
              elsif inlet_steam_pressure_be_low[pp] == 400
                basis_efficiency_low[pp] = -1.11067E-21 * horsepower ** 6 + 3.87462E-17 * horsepower ** 5 - 5.36695E-13 * horsepower ** 4 + 0.00000000376798 * horsepower ** 3 - 0.0000142445 * horsepower ** 2 + 0.029104 * horsepower + 45.3846
              elsif inlet_steam_pressure_be_low[pp] == 600
                basis_efficiency_low[pp] = -1.29851E-21 * horsepower ** 6 + 4.40057E-17 * horsepower ** 5 - 5.85842E-13 * horsepower ** 4 + 0.00000000390531 * horsepower ** 3 - 0.0000139451 * horsepower ** 2 + 0.0278771 * horsepower + 42.7226
              elsif inlet_steam_pressure_be_low[pp] == 1200
                basis_efficiency_low[pp] = -4.88525E-22 * horsepower ** 6 + 1.75706E-17 * horsepower ** 5 - 2.53903E-13 * horsepower ** 4 + 0.00000000190329 * horsepower ** 3 - 0.00000807852 * horsepower ** 2 + 0.0207991 * horsepower + 40.5691
              elsif inlet_steam_pressure_be_low[pp] == 1800
                basis_efficiency_low[pp] = 9.77669E-23 * horsepower ** 6 - 2.18634E-18 * horsepower ** 5 + 8.25065E-15 * horsepower ** 4 + 0.000000000170454 * horsepower ** 3 - 0.0000022231 * horsepower ** 2 + 0.0124557 * horsepower + 36.1696
              end

              #Determine Basis Efficiency for High end of the range
              if inlet_steam_pressure_be_high[pp] == 100
                basis_efficiency_high[pp] = -8.89958E-22 * horsepower ** 6 + 3.02946E-17 * horsepower ** 5 - 4.07467E-13 * horsepower ** 4 + 0.0000000027662 * horsepower ** 3 - 0.0000101172 * horsepower ** 2 + 0.0202528 * horsepower + 56.5221
              elsif inlet_steam_pressure_be_high[pp] == 200 
                basis_efficiency_high[pp] = -8.89958E-22 * horsepower ** 6 + 3.02946E-17 * horsepower ** 5 - 4.07467E-13 * horsepower ** 4 + 0.0000000027662 * horsepower ** 3 - 0.0000101172 * horsepower ** 2 + 0.0202528 * horsepower + 56.5221
              elsif inlet_steam_pressure_be_high[pp] == 400
                basis_efficiency_high[pp] = -1.11067E-21 * horsepower ** 6 + 3.87462E-17 * horsepower ** 5 - 5.36695E-13 * horsepower ** 4 + 0.00000000376798 * horsepower ** 3 - 0.0000142445 * horsepower ** 2 + 0.029104 * horsepower + 45.3846
              elsif inlet_steam_pressure_be_high[pp] == 600
                basis_efficiency_high[pp] = -1.29851E-21 * horsepower ** 6 + 4.40057E-17 * horsepower ** 5 - 5.85842E-13 * horsepower ** 4 + 0.00000000390531 * horsepower ** 3 - 0.0000139451 * horsepower ** 2 + 0.0278771 * horsepower + 42.7226
              elsif inlet_steam_pressure_be_high[pp] == 1200
                basis_efficiency_high[pp] = -4.88525E-22 * horsepower ** 6 + 1.75706E-17 * horsepower ** 5 - 2.53903E-13 * horsepower ** 4 + 0.00000000190329 * horsepower ** 3 - 0.00000807852 * horsepower ** 2 + 0.0207991 * horsepower + 40.5691
              elsif inlet_steam_pressure_be_high[pp] == 1800
                basis_efficiency_high[pp] = 9.77669E-23 * horsepower ** 6 - 2.18634E-18 * horsepower ** 5 + 8.25065E-15 * horsepower ** 4 + 0.000000000170454 * horsepower ** 3 - 0.0000022231 * horsepower ** 2 + 0.0124557 * horsepower + 36.1696
              end
                          
              delta_be = basis_efficiency_high[pp] - basis_efficiency_low[pp]
              delta_sp = inlet_steam_pressure_be_high[pp] - inlet_steam_pressure_be_low[pp]
              slope = delta_be / delta_sp
              intercept = basis_efficiency_high[pp] - (slope * inlet_steam_pressure_be_high[pp])
              basis_efficiency_value = ((slope * inlet_steam_pressure) + intercept) / 100
                  
              pp = 6
            end

          end # 1..6 loop
                   
          if inlet_pressure < 100 || inlet_pressure > 1800
            basis_efficiency_value = params[:std_ee_basic_efficiency].to_f / 100
          end

          if horsepower < 300 || horsepower > 15000            
            basis_efficiency_value = params[:std_ee_basic_efficiency].to_f / 100
          end
          
        elsif steam_turbine.std_turbine_type == "Condensing"
          
          (1..6).each do |pp|
            inlet_steam_pressure_be[pp] = SteamTurbine.condensing_turbine[0][pp]
            inlet_steam_pressure_be_low[pp] = SteamTurbine.condensing_turbine[0][pp]
            inlet_steam_pressure_be_high[pp] = SteamTurbine.condensing_turbine[0][pp+1]
            
            if inlet_steam_pressure == inlet_steam_pressure_be[pp]
              (1..14).each do |rr|
                rated_horsepower[rr] = SteamTurbine.condensing_turbine[rr][0]
                rated_horsepower_low[rr] = SteamTurbine.condensing_turbine[rr][0]
                rated_horsepower_high[rr] = SteamTurbine.condensing_turbine[rr+1][0]
                basis_efficiency_low[rr] = SteamTurbine.condensing_turbine[rr][pp]
                basis_efficiency_high[rr] = SteamTurbine.condensing_turbine[rr+1][pp]
                            
                if horsepower == rated_horsepower[rr]
                  basis_efficiency_value = SteamTurbine.condensing_turbine[rr][pp] / 100
                  rr = 14
                elsif horsepower > rated_horsepower_low[rr] && horsepower < rated_horsepower_high[rr]
                  delta_be = basis_efficiency_high[rr] - basis_efficiency_low[rr]
                  delta_hp = rated_horsepower_high[rr] - rated_horsepower_low[rr]
                  slope = delta_be / delta_hp
                  intercept = basis_efficiency_high[rr] - (slope * rated_horsepower_high[rr])
                  basis_efficiency_value = ((slope * horsepower) + intercept) / 100                               
                  rr = 14
                end
              end
              pp = 6
            elsif inlet_steam_pressure > inlet_steam_pressure_be_low[pp] && inlet_steam_pressure < inlet_steam_pressure_be_high[pp]
              #Determine Basis Efficiency for low end of the range
              if inlet_steam_pressure_be_low[pp] == 100
                basis_efficiency_low[pp] = -9.03882E-22 * horsepower ** 6 + 3.09754E-17 * horsepower ** 5 - 4.18188E-13 * horsepower ** 4 + 0.00000000283834 * horsepower ** 3 - 0.0000103393 * horsepower ** 2 + 0.0206624 * horsepower + 54.9615
              elsif inlet_steam_pressure_be_low[pp] == 200 
                basis_efficiency_low[pp] = -7.255682E-22 * horsepower ** 6 + 2.558895E-17 * horsepower ** 5 - 3.584539E-13 * horsepower ** 4 + 0.000000002543549 * horsepower ** 3 - 0.000009731587 * horsepower ** 2 + 0.0204815 * horsepower + 52.98353
              elsif inlet_steam_pressure_be_low[pp] == 400 
                basis_efficiency_low[pp] = -7.99317E-22 * horsepower ** 6 + 2.786156E-17 * horsepower ** 5 - 3.85027E-13 * horsepower ** 4 + 0.000000002698109 * horsepower ** 3 - 0.00001025813 * horsepower ** 2 + 0.02175317 * horsepower + 49.57562
              elsif inlet_steam_pressure_be_low[pp] == 600
                basis_efficiency_low[pp] = -9.4884E-22 * horsepower ** 6 + 3.312976E-17 * horsepower ** 5 - 4.561855E-13 * horsepower ** 4 + 0.000000003157289 * horsepower ** 3 - 0.00001171086 * horsepower ** 2 + 0.02399053 * horsepower + 46.59173
              elsif inlet_steam_pressure_be_low[pp] == 1200 
                basis_efficiency_low[pp] = -1.006642E-21 * horsepower ** 6 + 3.443071E-17 * horsepower ** 5 - 4.654935E-13 * horsepower ** 4 + 0.000000003176374 * horsepower ** 3 - 0.00001167965 * horsepower ** 2 + 0.02398172 * horsepower + 43.66373
              elsif inlet_steam_pressure_be_low[pp] == 1800 
                basis_efficiency_low[pp] = -5.418899E-22 * horsepower ** 6 + 1.909624E-17 * horsepower ** 5 - 2.685988E-13 * horsepower ** 4 + 0.000000001947119 * horsepower ** 3 - 0.000007944772 * horsepower ** 2 + 0.01955674 * horsepower + 42.03876
              end
              
              #Determine Basis Efficiency for High end of the range
              if inlet_steam_pressure_be_high[pp] == 100
                basis_efficiency_high[pp] = -9.03882E-22 * horsepower ** 6 + 3.09754E-17 * horsepower ** 5 - 4.18188E-13 * horsepower ** 4 + 0.00000000283834 * horsepower ** 3 - 0.0000103393 * horsepower ** 2 + 0.0206624 * horsepower + 54.9615
              elsif inlet_steam_pressure_be_high[pp] == 200 
                basis_efficiency_high[pp] = -7.255682E-22 * horsepower ** 6 + 2.558895E-17 * horsepower ** 5 - 3.584539E-13 * horsepower ** 4 + 0.000000002543549 * horsepower ** 3 - 0.000009731587 * horsepower ** 2 + 0.0204815 * horsepower + 52.98353
              elsif inlet_steam_pressure_be_high[pp] == 400 
                basis_efficiency_high[pp] = -7.99317E-22 * horsepower ** 6 + 2.786156E-17 * horsepower ** 5 - 3.85027E-13 * horsepower ** 4 + 0.000000002698109 * horsepower ** 3 - 0.00001025813 * horsepower ** 2 + 0.02175317 * horsepower + 49.57562
              elsif inlet_steam_pressure_be_high[pp] == 600 
                basis_efficiency_high[pp] = -9.4884E-22 * horsepower ** 6 + 3.312976E-17 * horsepower ** 5 - 4.561855E-13 * horsepower ** 4 + 0.000000003157289 * horsepower ** 3 - 0.00001171086 * horsepower ** 2 + 0.02399053 * horsepower + 46.59173
              elsif inlet_steam_pressure_be_high[pp] == 1200 
                basis_efficiency_high[pp] = -1.006642E-21 * horsepower ** 6 + 3.443071E-17 * horsepower ** 5 - 4.654935E-13 * horsepower ** 4 + 0.000000003176374 * horsepower ** 3 - 0.00001167965 * horsepower ** 2 + 0.02398172 * horsepower + 43.66373
              elsif inlet_steam_pressure_be_high[pp] == 1800 
                basis_efficiency_high[pp] = -5.418899E-22 * horsepower ** 6 + 1.909624E-17 * horsepower ** 5 - 2.685988E-13 * horsepower ** 4 + 0.000000001947119 * horsepower ** 3 - 0.000007944772 * horsepower ** 2 + 0.01955674 * horsepower + 42.03876
              end 
 
              delta_be = basis_efficiency_high[pp] - basis_efficiency_low[pp]
              delta_sp = inlet_steam_pressure_be_high[pp] - inlet_steam_pressure_be_low[pp]
              slope = delta_be / delta_sp
              intercept = basis_efficiency_high[pp] - (slope * inlet_steam_pressure_be_high[pp])
              basis_efficiency_value = ((slope * inlet_steam_pressure) + intercept) / 100
              pp = 6
            end 
          
          end # 1..6 loop
                    
          if inlet_pressure < 100 || inlet_pressure > 1800
            basis_efficiency_value = params[:std_ee_basic_efficiency].to_f / 100                        
          end
 
          if horsepower < 300 || horsepower > 15000
            basis_efficiency_value = params[:std_ee_basic_efficiency].to_f / 100            
          end              
        end
        
      elsif steam_turbine.std_ee_turbine_type == "Multi-Stage, Single Valve"
        basis_efficiency_value = params[:std_ee_basic_efficiency].to_f / 100
      end # Multi-Stage, Single Valve

      #Determine Superheat Correction Factor
      if steam_turbine.std_turbine_type == "Non-Condensing"
        superheat_cf = -0.0000002 * degree_of_super_heat ** 2 + 0.000147 * degree_of_super_heat + 0.9765818
        if degree_of_super_heat > 400
          super_heat_cf = params[:std_ee_superheat_efficiency_cf].to_f          
        end
      elsif steam_turbine.std_turbine_type == "Condensing"
        superheat_cf = -0.0000002 * degree_of_super_heat ** 2 + 0.000273 * degree_of_super_heat + 0.9768727
        if degree_of_super_heat > 450
          super_heat_cf = params[:std_ee_superheat_efficiency_cf].to_f
        end
      end
      
      #Determine speed Efficiency Correction Factor
      (1..7).each do |ppp|        
        rated_horsepower[ppp] = SteamTurbine.rated_horsepower[0][ppp]
        rated_horsepower_low[ppp] = SteamTurbine.rated_horsepower[0][ppp]
        rated_horsepower_high[ppp] = SteamTurbine.rated_horsepower[0][ppp+1]
             
        if horsepower == rated_horsepower[ppp]
          (1..16).each do |rrr|
            rated_speed[rrr] =  SteamTurbine.rated_horsepower[rrr][0]            
            rated_speed_low[rrr] = SteamTurbine.rated_horsepower[rrr][0]            
            rated_speed_high[rrr] = SteamTurbine.rated_horsepower[rrr+1][0]            
            rated_speed_cf_low[rrr] = SteamTurbine.rated_horsepower[rrr][ppp]            
            rated_speed_cf_high[rrr] = SteamTurbine.rated_horsepower[rrr+1][ppp] 
            
            if speed == rated_speed[rrr]
              speed_cf = SteamTurbine.rated_horsepower[rrr][ppp]
              rrr = 16
            elsif speed > rated_speed_low[rrr] && speed < rated_speed_high[rrr]
              delta_speed_cf = rated_speed_cf_high[rrr] - rated_speed_cf_low[rrr]
              delta_speed = rated_speed_high[rrr] - rated_speed_low[rrr]
              slope = delta_speed_cf / delta_speed
              intercept = rated_speed_cf_high[rrr] - (slope * rated_speed_high[rrr])
              speed_cf = (slope * speed) + intercept
              rrr = 16
            end
          end 
          ppp = 7
        elsif horsepower > rated_horsepower_low[ppp] && horsepower < rated_horsepower_high[ppp]
          #Determine Rated Speed Correction Factor on the low end of the range
          if rated_horsepower_low[ppp] == 1000
            rated_speed_cf_low[ppp] = -2.292571764E-09 * speed ** 2 + 0.00002594105665 * speed + 0.9358273307
          elsif rated_horsepower_low[ppp] == 2000
            rated_speed_cf_low[ppp] = -2.263269817E-09 * speed ** 2 + 0.00002040271887 * speed + 0.9564053184
          elsif rated_horsepower_low[ppp] == 3000
            rated_speed_cf_low[ppp] = -1.963419056E-09 * speed ** 2 + 0.00001245572766 * speed + 0.9819131776
          elsif rated_horsepower_low[ppp] == 5000
            rated_speed_cf_low[ppp] = -1.694951337E-09 * speed ** 2 + 0.000005675412887 * speed + 1.003059207
          elsif rated_horsepower_low[ppp] == 10000
            rated_speed_cf_low[ppp] = -1.19005782E-09 * speed ** 2 - 0.000003212609376 * speed + 1.028419149
          elsif rated_horsepower_low[ppp] == 12500
            rated_speed_cf_low[ppp] = -1.402568106E-09 * speed ** 2 - 0.000003206178936 * speed + 1.0313321
          elsif rated_horsepower_low[ppp] == 15000
            rated_speed_cf_low[ppp] = -2.06018508E-09 * speed ** 2 + 6.654787988E-07 * speed + 1.024696752
          end

          #Determine Rated speed Correction Factor on the high end of the range
          if rated_horsepower_high[ppp] == 1000
            rated_speed_cf_high[ppp] = -2.292571764E-09 * speed ** 2 + 0.00002594105665 * speed + 0.9358273307
          elsif rated_horsepower_high[ppp] == 2000
            rated_speed_cf_high[ppp] = -2.263269817E-09 * speed ** 2 + 0.00002040271887 * speed + 0.9564053184
          elsif rated_horsepower_high[ppp] == 3000
            rated_speed_cf_high[ppp] = -1.963419056E-09 * speed ** 2 + 0.00001245572766 * speed + 0.9819131776
          elsif rated_horsepower_high[ppp] == 5000
            rated_speed_cf_high[ppp] = -1.694951337E-09 * speed ** 2 + 0.000005675412887 * speed + 1.003059207
          elsif rated_horsepower_high[ppp] == 10000
            rated_speed_cf_high[ppp] = -1.19005782E-09 * speed ** 2 - 0.000003212609376 * speed + 1.028419149
          elsif rated_horsepower_high[ppp] == 12500
            rated_speed_cf_high[ppp] = -1.402568106E-09 * speed ** 2 - 0.000003206178936 * speed + 1.0313321
          elsif rated_horsepower_high[ppp] == 15000
            rated_speed_cf_high[ppp] = -2.06018508E-09 * speed ** 2 + 6.654787988E-07 * speed + 1.024696752
          end         

          delta_speed_cf = rated_speed_cf_high[ppp] - rated_speed_cf_low[ppp]
          delta_hp = rated_horsepower_high[ppp] - rated_horsepower_low[ppp]
          slope = delta_speed_cf / delta_hp
          intercept = rated_speed_cf_high[ppp] - (slope * rated_horsepower_high[ppp])
          speed_cf = (slope * speed) + intercept
          ppp = 7
        end

      end # 1..7 ppp
      
      if horsepower < 1000 || horsepower > 15000
        speed_cf = params[:std_ee_speed_efficiency_cf].to_f
      end

      if speed < 3500 || speed > 10000        
        speed_cf = params[:std_ee_speed_efficiency_cf].to_f
      end  

      #Determine Pressure Ratio Correction Factor
      if steam_turbine.std_turbine_type == "Non-Condensing"
        pressure_ratio_cf = -0.3613 * pressure_ratio ** 3 - 0.512 * pressure_ratio ** 2 + 0.2781 * pressure_ratio + 0.9797        
        if pressure_ratio < 0 || pressure_ratio > 0.5          
          pressure_ratio_cf = params[:std_ee_pressure_ratio_cf].to_f
        end
      elsif steam_turbine.std_turbine_type == "Condensing"
        pressure_ratio_cf = 1
      end

      #Determine Corrected Efficiency           
      corrected_efficiency = basis_efficiency_value * superheat_cf * speed_cf * pressure_ratio_cf
                 
      lbl_basic_efficiency = (basis_efficiency_value * 100).round(2)
      lbl_degree_of_superheat = degree_of_super_heat.round(0)
      lbl_superheat_efficiency_cf = superheat_cf.round(3)
      lbl_speed_efficiency_cf = speed_cf.round(3)
      lbl_pressure_ratio_cf = pressure_ratio_cf.round(3)
      lbl_corrected_efficiency = (corrected_efficiency * 100).round(2)
    elsif steam_turbine.std_ee_turbine_type == "Single Stage, Single Valve" || steam_turbine.std_ee_turbine_type == "Single Stage, Multiple Valves"
      #Estimating steam flow for single stage turbines.
      #Determine Pressure Ratio Correction Factor
      approx_steam_rate = 0
      
      if speed >= 1000 && speed <= 10000        
        if pressure_ratio >= 0.05 && pressure_ratio <= 0.55          
          (1..8).each do |tt|
            single_stage_speed[tt] = SteamTurbine.speed[0][tt]
            single_stage_speed_low[tt] = SteamTurbine.speed[0][tt]
            single_stage_speed_high[tt] = SteamTurbine.speed[0][tt+1]            
            if speed == single_stage_speed[tt]              
              (0..11).each do |xx|                
                single_stage_pressure_ratio[xx] = SteamTurbine.speed[xx][0]
                single_stage_pressure_ratio_low[xx] = SteamTurbine.speed[xx][0]                
                single_stage_pressure_ratio_high[xx] = SteamTurbine.speed[xx+1][0]
                approximate_steam_rate_low[xx] = SteamTurbine.speed[xx][tt]
                approximate_steam_rate_high[xx] = SteamTurbine.speed[xx+1][tt]                   
                if pressure_ratio == single_stage_pressure_ratio[xx]
                  approx_steam_rate = SteamTurbine.speed[xx][tt]
                  xx = 11
                elsif pressure_ratio > single_stage_pressure_ratio_low[xx] && pressure_ratio < single_stage_pressure_ratio_high[xx]
                  delta_asr = approximate_steam_rate_high[xx] - approximate_steam_rate_low[xx]
                  delta_sss = single_stage_pressure_ratio_high[xx] - single_stage_pressure_ratio_low[xx]
                  slope = delta_asr / delta_sss
                  intercept = approximate_steam_rate_high[xx] - (slope * single_stage_pressure_ratio_high[xx])
                  approx_steam_rate = (slope * pressure_ratio) + intercept
                  xx = 11
                end
              end #1..12 xx              
              tt = 8

            elsif speed > single_stage_speed_low[tt] && speed < single_stage_speed_high[tt]
              #Determine Approximately steam rate low of the range
              if single_stage_speed_low[tt] == 1000
                approximate_steam_rate_low[tt] = 23529.41 * pressure_ratio ** 6 - 46033.18 * pressure_ratio ** 5 + 32303.92 * pressure_ratio ** 4 - 9566.67 * pressure_ratio ** 3 + 1056.56 * pressure_ratio ** 2 + 199.49 * pressure_ratio + 83.85
              elsif single_stage_speed_low[tt] == 1400
                approximate_steam_rate_low[tt] = 6433.57 * pressure_ratio ** 4 - 6675.99 * pressure_ratio ** 3 + 2262.24 * pressure_ratio ** 2 - 93.03 * pressure_ratio ** 70
              elsif single_stage_speed_low[tt] == 1800
                approximate_steam_rate_low[tt] = 68496.73 * pressure_ratio ** 6 - 120730.02 * pressure_ratio ** 5 + 83376.07 * pressure_ratio ** 4 - 28078.89 * pressure_ratio ** 3 + 4743.99 * pressure_ratio ** 2 - 218.13 * pressure_ratio + 57.11
              elsif single_stage_speed_low[tt] == 2400
                approximate_steam_rate_low[tt] = -25641.03 * pressure_ratio ** 5 + 38414.92 * pressure_ratio ** 4 - 20364.8 * pressure_ratio ** 3 + 4709.79 * pressure_ratio ** 2 - 331.06 * pressure_ratio ** 51.52
              elsif single_stage_speed_low[tt] == 3000
                approximate_steam_rate_low[tt] = 27712.42 * pressure_ratio ** 6 - 57574.66 * pressure_ratio ** 5 + 48247.86 * pressure_ratio ** 4 - 19722.69 * pressure_ratio ** 3 + 4023.8 * pressure_ratio ** 2 - 256.92 * pressure_ratio + 40.96
              elsif single_stage_speed_low[tt] == 5000
                approximate_steam_rate_low[tt] = -19869.28 * pressure_ratio ** 6 + 39354.45 * pressure_ratio ** 5 - 29401.71 * pressure_ratio ** 4 + 10659.47 * pressure_ratio ** 3 - 1941.78 * pressure_ratio ** 2 + 284.34 * pressure_ratio + 15.45
              elsif single_stage_speed_low[tt] == 7000
                approximate_steam_rate_low[tt] = -22483.66 * pressure_ratio ** 6 + 29701.36 * pressure_ratio ** 5 - 11239.32 * pressure_ratio ** 4 + 318.46 * pressure_ratio ** 3 + 519.89 * pressure_ratio ** 2 + 31.96 * pressure_ratio + 20.13
              elsif single_stage_speed_low[tt] == 10000
                approximate_steam_rate_low[tt] = -101176.47 * pressure_ratio ** 6 + 179809.96 * pressure_ratio ** 5 - 121858.97 * pressure_ratio ** 4 + 39494.85 * pressure_ratio ** 3 - 6186.49 * pressure_ratio ** 2 + 523.19 * pressure_ratio + 6.57
              end

              #Determine Approximately steam rate high of the range
              if single_stage_speed_high[tt] == 1000
                approximate_steam_rate_high[tt] = 23529.41 * pressure_ratio ** 6 - 46033.18 * pressure_ratio ** 5 + 32303.92 * pressure_ratio ** 4 - 9566.67 * pressure_ratio ** 3 + 1056.56 * pressure_ratio ** 2 + 199.49 * pressure_ratio + 83.85
              elsif single_stage_speed_high[tt] == 1400
                approximate_steam_rate_high[tt] = 6433.57 * pressure_ratio ** 4 - 6675.99 * pressure_ratio ** 3 + 2262.24 * pressure_ratio ** 2 - 93.03 * pressure_ratio ** 70#
              elsif single_stage_speed_high[tt] == 1800
                approximate_steam_rate_high[tt] = 68496.73 * pressure_ratio ** 6 - 120730.02 * pressure_ratio ** 5 + 83376.07 * pressure_ratio ** 4 - 28078.89 * pressure_ratio ** 3 + 4743.99 * pressure_ratio ** 2 - 218.13 * pressure_ratio + 57.11
              elsif single_stage_speed_high[tt] == 2400
                approximate_steam_rate_high[tt] = -25641.03 * pressure_ratio ** 5 + 38414.92 * pressure_ratio ** 4 - 20364.8 * pressure_ratio ** 3 + 4709.79 * pressure_ratio ** 2 - 331.06 * pressure_ratio ** 51.52
              elsif single_stage_speed_high[tt] == 3000
                approximate_steam_rate_high[tt] = 27712.42 * pressure_ratio ** 6 - 57574.66 * pressure_ratio ** 5 + 48247.86 * pressure_ratio ** 4 - 19722.69 * pressure_ratio ** 3 + 4023.8 * pressure_ratio ** 2 - 256.92 * pressure_ratio + 40.96
              elsif single_stage_speed_high[tt] == 5000
                approximate_steam_rate_high[tt] = -19869.28 * pressure_ratio ** 6 + 39354.45 * pressure_ratio ** 5 - 29401.71 * pressure_ratio ** 4 + 10659.47 * pressure_ratio ** 3 - 1941.78 * pressure_ratio ** 2 + 284.34 * pressure_ratio + 15.45
              elsif single_stage_speed_high[tt] == 7000
                approximate_steam_rate_high[tt] = -22483.66 * pressure_ratio ** 6 + 29701.36 * pressure_ratio ** 5 - 11239.32 * pressure_ratio ** 4 + 318.46 * pressure_ratio ** 3 + 519.89 * pressure_ratio ** 2 + 31.96 * pressure_ratio + 20.13
              elsif single_stage_speed_high[tt] == 10000
                approximate_steam_rate_high[tt] = -101176.47 * pressure_ratio ** 6 + 179809.96 * pressure_ratio ** 5 - 121858.97 * pressure_ratio ** 4 + 39494.85 * pressure_ratio ** 3 - 6186.49 * pressure_ratio ** 2 + 523.19 * pressure_ratio + 6.57
              end
              
              delta_asr = approximate_steam_rate_high[tt] - approximate_steam_rate_low[tt]
              delta_sss = single_stage_speed_high[tt] - single_stage_speed_low[tt]
              slope = delta_asr / delta_sss
              intercept = approximate_steam_rate_high[tt] - (slope * single_stage_speed_high[tt])
              approx_steam_rate = (slope * pressure_ratio) + intercept
              
              tt = 8
            end
          end #1..8 tt

        elsif pressure_ratio < 0.05 && pressure_ratio > 0 && speed == 1000
          approx_steam_rate = 1.1304 * pressure_ratio + 0.05        
        end
      end
              
      if pressure_ratio < 0 || pressure_ratio > 0.55
        approx_steam_rate = params[:approximate_steam_rate].to_f
      end

      if speed < 1000 || speed > 10000
        approx_steam_rate = params[:approximate_steam_rate].to_f
      end      

      #Determine Superheat Correction Factor      
      if degree_of_super_heat > 0 && degree_of_super_heat < 200
         superheat_factor = -0.0008 * degree_of_super_heat + 1.001
      else        
        superheat_factor = params[:std_ee_superheat_efficiency_cf].to_f
      end

      steam_flow_rate = approx_steam_rate * superheat_factor * horsepower
           
      lbl_basic_efficiency = ""
      lbl_degree_of_superheat = degree_of_super_heat.round(0)
      lbl_superheat_efficiency_cf = superheat_factor.round(2)
      lbl_speed_efficiency_cf = ""
      lbl_pressure_ratio_cf = ""
      lbl_corrected_efficiency = ""      
    end # Multi-Stage, Multiple Valves || Multi-Stage, Single Valve
    
    steam_turbine.std_ee_basic_efficiency = lbl_basic_efficiency
    steam_turbine.std_ee_degree_of_superheat = lbl_degree_of_superheat
    steam_turbine.std_ee_superheat_efficiency_cf = lbl_superheat_efficiency_cf
    steam_turbine.std_ee_speed_efficiency_cf = lbl_speed_efficiency_cf
    steam_turbine.std_ee_pressure_ratio_cf = lbl_pressure_ratio_cf
    steam_turbine.std_ee_corrected_efficiency_cf = lbl_corrected_efficiency
    steam_turbine.save    
    
    calculated_values[:lbl_basic_efficiency] = lbl_basic_efficiency
    calculated_values[:lbl_degree_of_superheat] = lbl_degree_of_superheat
    calculated_values[:lbl_superheat_efficiency_cf] = lbl_superheat_efficiency_cf
    calculated_values[:lbl_speed_efficiency_cf] = lbl_speed_efficiency_cf
    calculated_values[:lbl_pressure_ratio_cf] = lbl_pressure_ratio_cf
    calculated_values[:lbl_corrected_efficiency] = lbl_corrected_efficiency    
        
    respond_to do |format|
      format.json {render :json => calculated_values}     
    end
  end
  
  def determine_nominal_pipe_size_nozzle(rupture_diameter)
    
    if rupture_diameter > 0 && rupture_diameter <= 0.364
      pipe_size = 0.125
      pipe_schedule = "Sch. 40"
      proposed_diameter = 0.364
    elsif rupture_diameter > 0.364 && rupture_diameter <= 0.493
      pipe_size = 0.25
      pipe_schedule = "Sch. 40"
      proposed_diameter = 0.493
    elsif rupture_diameter > 0.493 && rupture_diameter <= 0.622
      pipe_size = 0.375
      pipe_schedule = "Sch. 40"
      proposed_diameter = 0.622
    elsif rupture_diameter > 0.622 && rupture_diameter <= 0.824
      pipe_size = 0.5
      pipe_schedule = "Sch. 40"
      proposed_diameter = 0.824
    elsif rupture_diameter > 0.824 && rupture_diameter <= 1.049
      pipe_size = 0.75
      pipe_schedule = "Sch. 40"
      proposed_diameter = 1.049
    elsif rupture_diameter > 1.049 && rupture_diameter <= 1.38
      pipe_size = 1
      pipe_schedule = "Sch. 40"
      proposed_diameter = 1.38
    elsif rupture_diameter > 1.38 && rupture_diameter <= 1.61
      pipe_size = 1.25
      pipe_schedule = "Sch. 40"
      proposed_diameter = 1.61
    elsif rupture_diameter > 1.61 && rupture_diameter <= 2.067
      pipe_size = 1.5
      pipe_schedule = "Sch. 40"
      proposed_diameter = 2.067
    elsif rupture_diameter > 2.067 && rupture_diameter <= 2.469
      pipe_size = "2"
      pipe_schedule = "Sch. 40"
      proposed_diameter = 2.469
    elsif rupture_diameter > 2.469 && rupture_diameter <= 3.068
      pipe_size = 2.5
      pipe_schedule = "Sch. 40"
      proposed_diameter = 3.068
    elsif rupture_diameter > 3.068 && rupture_diameter <= 3.548
      pipe_size = 3
      pipe_schedule = "Sch. 40"
      proposed_diameter = 3.548
    elsif rupture_diameter > 3.548 && rupture_diameter <= 4.026
      pipe_size = 3.5
      pipe_schedule = "Sch. 40"
      proposed_diameter = 4.026
    elsif rupture_diameter > 4.026 && rupture_diameter <= 5.047
      pipe_size = 4
      pipe_schedule = "Sch. 40"
      proposed_diameter = 5.047
    elsif rupture_diameter > 5.047 && rupture_diameter <= 6.065
      pipe_size = 5
      pipe_schedule = "Sch. 40"
      proposed_diameter = 6.065
    elsif rupture_diameter > 6.065 && rupture_diameter <= 7.981
      pipe_size = 6
      pipe_schedule = "Sch. 40"
      proposed_diameter = 7.981
    elsif rupture_diameter > 7.981 && rupture_diameter <= 10.02
      pipe_size = 8
      pipe_schedule = "Sch. 40"
      proposed_diameter = 10.02
    elsif rupture_diameter > 10.02 && rupture_diameter <= 11.938
      pipe_size = 10
      pipe_schedule = "Sch. 40"
      proposed_diameter = 11.938
    elsif rupture_diameter > 11.938 && rupture_diameter <= 13.124
      pipe_size = 12
      pipe_schedule = "Sch. 40"
      proposed_diameter = 13.124
    elsif rupture_diameter > 13.124 && rupture_diameter <= 15#
      pipe_size = 14
      pipe_schedule = "Sch. 40"
      proposed_diameter = 15
    elsif rupture_diameter > 15 && rupture_diameter <= 16.876
      pipe_size = 16
      pipe_schedule = "Sch. 40"
      proposed_diameter = 16.876
    elsif rupture_diameter > 16.876 && rupture_diameter <= 18.812
      pipe_size = 18
      pipe_schedule = "Sch. 40"
      proposed_diameter = 18.812
    elsif rupture_diameter > 18.812 && rupture_diameter <= 21.25
      pipe_size = 20
      pipe_schedule = "Sch. 20"
      proposed_diameter = 21.25
    elsif rupture_diameter > 21.25 && rupture_diameter <= 22.624
      pipe_size = 22
      pipe_schedule = "Sch. 40"
      proposed_diameter = 22.624
    elsif rupture_diameter > 22.624 && rupture_diameter <= 25
      pipe_size = 26
      pipe_schedule = "Sch. 20"
      proposed_diameter = 25
    elsif rupture_diameter > 25 && rupture_diameter <= 27
      pipe_size = 24
      pipe_schedule = "Sch. 20"
      proposed_diameter = 27
    elsif rupture_diameter > 27 && rupture_diameter <= 29
      pipe_size = 28
      pipe_schedule = "Sch. 20"
      proposed_diameter = 29
    elsif rupture_diameter > 29 && rupture_diameter <= 31
      pipe_size = 30
      pipe_schedule = "Sch. 20"
      proposed_diameter = 31
    elsif rupture_diameter > 31 && rupture_diameter <= 33
      pipe_size = 32
      pipe_schedule = "Sch. 20"
      proposed_diameter = 33
    elsif rupture_diameter > 33 && rupture_diameter <= 35
      pipe_size = 34
      pipe_schedule = "Sch. 20"
      proposed_diameter = 35
    else
      pipe_size = 36
      pipe_schedule = "N/A"
      proposed_diameter = 0
    end
    
    return {:pipe_size => pipe_size, :pipe_schedule => pipe_schedule, :proposed_diameter => proposed_diameter}
  end
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Driver Sizing', :url => admin_driver_sizings_path }
    @breadcrumbs << { :name => 'Steam Turbine', :url => admin_driver_sizings_path(:anchor => "steam_turbine")}
  end
  
  private
  
  def default_form_values

    @steam_turbine = @company.steam_turbines.find(params[:id]) rescue @company.steam_turbines.new
    @comments = @steam_turbine.comments
    @new_comment = @steam_turbine.comments.new

    @attachments = @steam_turbine.attachments
    @new_attachment = @steam_turbine.attachments.new

    @project = @user_project_settings.project
    @streams = []
    @equipment_tag = []
  end
end
