class Admin::TurboExpandersController < AdminController
  
  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]
  
  def new
    @turbo_expander = @company.turbo_expanders.new   
  end
  
  def create
    turbo_expander = params[:turbo_expander]
    turbo_expander[:created_by] = turbo_expander[:updated_by] = current_user.id    
    @turbo_expander = @company.turbo_expanders.new(turbo_expander)    
    
    if @turbo_expander.save
      @turbo_expander.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      if !params[:calculate_btn].blank?
        flash[:notice] = "New turbo expander created successfully."
        redirect_to edit_admin_turbo_expander_path(:id=>@turbo_expander.id, :calculate_btn=>params[:calculate_btn], :anchor=>params[:tab])
      else
        flash[:notice] = "New turbo expander created successfully."
        redirect_to admin_driver_sizings_path(:anchor => "turbo_expander")
      end      
    else
      render :new
    end
  end
  
  def edit
    @turbo_expander = @company.turbo_expanders.find(params[:id])    
    
    if !@turbo_expander.sic_process_basis_id.nil?
      heat_and_material_balance = HeatAndMaterialBalance.find(@turbo_expander.sic_process_basis_id)
      @streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end  
    
    if !@turbo_expander.ed_equipment_type.nil?      
      @equipment_tag = get_equiment_tag(@turbo_expander.ed_equipment_type, @project.id)      
    end
  end
  
  def update
    turbo_expander = params[:turbo_expander]
    turbo_expander[:updated_by] = current_user.id
    @turbo_expander = @company.turbo_expanders.find(params[:id])    
    
    if !@turbo_expander.sic_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@turbo_expander.sic_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
    
    if !turbo_expander[:ed_equipment_type].nil?
      @equipment_tag = get_equiment_tag(turbo_expander[:ed_equipment_type], @project.id)
    end 
            
    if @turbo_expander.update_attributes(turbo_expander)
      if !params[:calculate_btn].blank?
        flash[:notice] = "Updated turbo expander successfully."
        redirect_to edit_admin_turbo_expander_path(:id=>@turbo_expander.id, :calculate_btn=>params[:calculate_btn], :anchor=>params[:tab])
      else
        flash[:notice] = "Updated turbo expander successfully."
        redirect_to admin_driver_sizings_path(:anchor => "turbo_expander")
      end      
    else      
      render :edit
    end
  end
  
  def destroy
    @turbo_expander = @company.turbo_expanders.find(params[:id])
    if @turbo_expander.destroy
      flash[:notice] = "Deleted #{@turbo_expander.turbo_expander_tag} successfully."
      redirect_to admin_driver_sizings_path(:anchor => "turbo_expander")
    end
  end

  def clone
	  @turbo_expander = @company.turbo_expanders.find(params[:id])
	  new = @turbo_expander.clone :except => [:created_at, :updated_at]
	  new.turbo_expander_tag = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_turbo_expander_path(new) }
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
    
    mass_vapour_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    mass_vapour_fraction_stream = mass_vapour_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_vapour_fraction] = mass_vapour_fraction_stream.stream_value.to_f rescue nil
    
    flowrate = property.where(:phase => "Overall", :property => "Mass Flow").first
    flowrate_stream = flowrate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:flowrate] = flowrate_stream.stream_value.to_f rescue nil
    
    density = property.where(:phase => "Overall", :property => "Mass Density").first
    density_stream = density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:density] = density_stream.stream_value.to_f rescue nil
    
    enthalpy = property.where(:phase => "Overall", :property => "Mass Density").first
    enthalpy_stream = enthalpy.streams.where(:stream_no => params[:stream_no]).first
    form_values[:enthalpy] = enthalpy_stream.stream_value.to_f rescue nil
    
    render :json => form_values   
  end
  
  def get_expander_design_stream_values
    form_values = {}
    
    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    property = heat_and_meterial_balance.heat_and_material_properties
    
    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature] = temperature_stream.stream_value.to_f rescue nil
    
    mass_vapour_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    mass_vapour_fraction_stream = mass_vapour_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_vapour_fraction] = mass_vapour_fraction_stream.stream_value.to_f rescue nil
    
    mass_vapour_fraction = property.where(:phase => "Overall", :property => "Molar Enthalpy").first
    mass_vapour_fraction_stream = mass_vapour_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:enthalpy] = mass_vapour_fraction_stream.stream_value.to_f rescue nil
        
    render :json => form_values
  end
  
  def turbo_expanders_summary
    @turbo_expanders = @company.turbo_expanders.all
  end
  
  def expander_design_calculation
    calculated_values = {}
    
    turbo_expander = TurboExpander.find(params[:turbo_expander_id])
    
    #Determined steam supply basis
    if turbo_expander.sic_maximum == true
      inlet_enthalpy = turbo_expander.sic_max_stream_enthalpy
      inlet_entropy = turbo_expander.sic_max_stream_entropy
      inlet_mass_flow_rate = turbo_expander.sic_max_stream_flowrate
      inlet_mass_flow_rate1 = inlet_mass_flow_rate
    elsif turbo_expander.sic_mininum == true
      inlet_enthalpy = turbo_expander.sic_min_stream_enthalpy
      inlet_entropy = turbo_expander.sic_min_stream_entropy
      inlet_mass_flow_rate = turbo_expander.sic_min_stream_flowrate
      inlet_mass_flow_rate1 = inlet_mass_flow_rate
    elsif turbo_expander.sic_normal == true      
      inlet_enthalpy = turbo_expander.sic_nor_stream_enthalpy
      inlet_entropy = turbo_expander.sic_nor_stream_entropy
      inlet_mass_flow_rate = turbo_expander.sic_nor_stream_flowrate
      inlet_mass_flow_rate1 = inlet_mass_flow_rate      
    end
        
    #Determined steam outlet basis
    if turbo_expander.soc_normal == true
      outlet_enthalpy = turbo_expander.soc_nor_stream_enthalpy
      exhaust_vapor_entropy = turbo_expander.soc_nor_stream_entropy
      exhaust_liquid_entropy = turbo_expander.soc_nor_stream_liquid_entropy
    elsif turbo_expander.soc_maximum == true
      outlet_enthalpy = turbo_expander.soc_max_stream_enthalpy
      exhaust_vapor_entropy = turbo_expander.soc_max_stream_entropy
      exhaust_liquid_entropy = turbo_expander.soc_max_stream_liquid_entropy
    elsif turbo_expander.soc_mininum == true
      outlet_enthalpy = turbo_expander.soc_min_stream_enthalpy
      exhaust_vapor_entropy = turbo_expander.soc_min_stream_entropy
      exhaust_liquid_entropy = turbo_expander.soc_min_stream_liquid_entropy
    end
    
    #Determine Exhaust Phase
    if inlet_entropy == exhaust_vapor_entropy
      exhaust_phase = "Vapor - Saturated"
    elsif inlet_entropy > exhaust_vapor_entropy
      exhaust_phase = "Vapor - Superheated"
    elsif inlet_entropy < exhaust_vapor_entropy
      exhaust_phase = "Two Phase"
    elsif InletEntropy == exhaust_liquid_entropy
      exhaust_phase = "Saturated Liquid"
    end
    
    if turbo_expander.soc_mininum == true
      lblExhaustSteamPhaseMin = exhaust_phase
    elsif turbo_expander.soc_normal == true
      lblExhaustSteamPhaseNormal = exhaust_phase
    elsif turbo_expander.soc_maximum == true
      lblExhaustSteamPhaseMax = exhaust_phase
    end
    
    ideal_enthalpy_change = inlet_enthalpy - outlet_enthalpy
    actual_enthalpy_change = ideal_enthalpy_change * (turbo_expander.ed_basis_efficiency / 100)
    
    work_produced = actual_enthalpy_change * inlet_mass_flow_rate

    horsepower = work_produced / 2545

    mechanical_loses = turbo_expander.ed_mechanical_losses
    
    net_horsepower = horsepower * (1 - (mechanical_loses / 100))
         
    equipment_brake_hp = turbo_expander.ed_horsepower #TODO
    
    balance_brake_hp = equipment_brake_hp - net_horsepower
    
    if balance_brake_hp <= 0 
      #Msg2 = MsgBox("The turbo expanded is capable of providing the full complement of horsepower required to power the associated rotating equipment.", vbOKOnly, "Supplemental Driver Required")
      balance_brake_hp = 0
    elsif balance_brake_hp > 0
      #Msg2 = MsgBox("The turbo expanded does not have the full horsepower requirement to power the associated rotating equipment and therefore will need a " & Chr(34) & "helper" & Chr(34) & " driver in supplemental service." & Chr(13) & Chr(13) _
      #& "When possible, the supplemental driver is an electric motor with the full horsepower rating to power the associated equipment on its own.", vbOKOnly, "Supplemental Driver Required")
      balance_brake_hp = balance_brake_hp.abs
    end
    
    calculated_values[:theoretical_enthalpy_change] = ideal_enthalpy_change
    calculated_values[:actual_enthalpy_change] = actual_enthalpy_change
    calculated_values[:basis_flow_rate] = inlet_mass_flow_rate1
    calculated_values[:work_produced] = work_produced
    calculated_values[:horsepower_produced] = horsepower
    calculated_values[:net_horsepower] = net_horsepower.round(1)
    calculated_values[:balance_brake_horsepower] = balance_brake_hp.round(1)
    
    if turbo_expander.sic_maximum == true
      inlet_stream_no = turbo_expander.sic_max_stream_no
    elsif turbo_expander.sic_mininum == true
      inlet_stream_no = turbo_expander.sic_nor_stream_no
    elsif turbo_expander.sic_normal == true      
      inlet_stream_no = turbo_expander.sic_nor_stream_no
    end
    
    respond_to do |format|
      format.json {render :json => calculated_values}     
    end
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
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Driver Sizing', :url => admin_driver_sizings_path }
    @breadcrumbs << { :name => 'Turbo Expander', :url => admin_driver_sizings_path(:anchor => "turbo_expander")}
  end
  
  private
  
  def default_form_values

    @turbo_expander = @company.turbo_expanders.find(params[:id]) rescue @company.turbo_expanders.new
    @comments = @turbo_expander.comments
    @new_comment = @turbo_expander.comments.new

    @attachments = @turbo_expander.attachments
    @new_attachment = @turbo_expander.attachments.new

    @project = @user_project_settings.project
    @streams = []    
    @equipment_tag = []
  end
end
