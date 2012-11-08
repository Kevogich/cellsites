class Admin::ReliefDeviceSizingsController < AdminController

  before_filter :default_form_values, :only => [:new, :create, :edit, :update]

  def index
    @relief_device_sizings = @company.relief_device_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
  end

  def new
	  @relief_device_sizing = @company.relief_device_sizings.new
	  @equipment_type = equipment_type
	  @equipment_tags = []
    #For system design inlet/outlet piping
    p = @user_project_settings.project.convert_pipe_roughness_values
    @pipes = p[:pipes]
    # pump size unit
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
  end

  def create
	  params[:relief_device_sizing][:relief_device_equipments_attributes] = params[:equipment_attributes].values
      @relief_device_sizing = @company.relief_device_sizings.new(params[:relief_device_sizing])    
	  @relief_device_sizing.created_by = current_user.id
	  @relief_device_sizing.updated_by = current_user.id

	  if @relief_device_sizing.save
      @relief_device_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
		  if params[:calculate_btn].blank?
        redirect_to admin_relief_device_sizings_path
      else
        redirect_to edit_admin_relief_device_sizing_path(@relief_device_sizing, :anchor => params[:tab], :calculate_btn => params[:calculate_btn])
      end
	  else
		  flash[:errors] = @relief_device_sizing.errors.full_messages.join("  ")
		  render 'new'
	  end
  end

  def edit
	  @relief_device_sizing = ReliefDeviceSizing.find(params[:id])
	  project = @relief_device_sizing.project
	  @equipment_type = equipment_type
	  @equipment_section = eq_sections
	  @equipment_tags = eq_tags(project)
    @equipment_links = eq_links(project)
    #For system design inlet/outlet piping
    p = project.convert_pipe_roughness_values
    @pipes = p[:pipes]
    # pump size unit
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
  end

  def update
	  @relief_device_sizing = ReliefDeviceSizing.find(params[:id])
	  params[:relief_device_sizing][:relief_device_equipments_attributes] = params[:equipment_attributes].values
    params[:relief_device_sizing][:relief_devices_attributes] = params[:relief_device_attributes].values
    params[:relief_device_sizing][:relief_device_locations_attributes] = params[:location_attributes].values

    params[:relief_device_sizing][:relief_device_rupture_disks_attributes] = params[:rupture_disk_attributes].values
    params[:relief_device_sizing][:relief_device_rupture_locations_attributes] = params[:rupture_location_attributes].values

    params[:relief_device_sizing][:relief_device_open_vent_relief_devices_attributes] = params[:open_vent_relief_device_attributes].values
    params[:relief_device_sizing][:relief_device_open_vent_locations_attributes] = params[:open_vent_location_attributes].values

    params[:relief_device_sizing][:relief_device_low_pressure_vent_relief_devices_attributes] = params[:low_pressure_vent_relief_device_attributes].values

	  @relief_device_sizing.update_attributes(params[:relief_device_sizing])
    #raise params.to_yaml
    if params[:redirect_to].present?
      redirect_to params[:redirect_to]
    elsif params[:calculate_btn].present?
      redirect_to edit_admin_relief_device_sizing_path(@relief_device_sizing, :anchor => params[:tab], :calculate_btn => params[:calculate_btn])
    else
      redirect_to admin_relief_device_sizings_path
    end
  end

  def destroy
	  @relief_device_sizing = ReliefDeviceSizing.find(params[:id])
	  @relief_device_sizing.destroy
	  redirect_to admin_relief_device_sizings_path
  end


  def equipments
	  @equipment = ReliefDeviceEquipment.new
	  @unique_id = Time.now.to_i
	  @equipment_type = equipment_type
	  @equipment_section = eq_sections
	  render :partial => 'equipments'
  end

  #get equipment section based on equipment type
  def equipment_section
	  @relief_device_sizing = ReliefDeviceSizing.find(params[:relief_device_sizing_id])
	  sections = eq_sections
	  tags = [["select","select"]] + equipment_tags(params[:equipment_type],@relief_device_sizing.project)
    #links =  equipment_links(params[:equipment_type],@relief_device_sizing.project)
	  render :json => {:section => sections[params[:equipment_type]], :tags => tags}
  end

  #get design pressure based on equipment type and section
  def design_pressure
	  @relief_device_sizing = ReliefDeviceSizing.find(params[:relief_device_sizing_id])
    links =  equipment_links(params[:equipment_type],@relief_device_sizing.project)
	  project = @relief_device_sizing.project
	  if ["Pressure Vessel", "Filter","Reactor"].include?(params[:equipment_type])
		  vessel = project.vessel_sizings.find(params[:tag_id])
		  pressure = vessel.dc_design_pressure
	  elsif ["Column"].include?(params[:equipment_type])
		  column = project.column_sizings.find(params[:tag_id])
		  pressure = column.c_design_pressure
	  elsif ["Low Pressure Tank"].include?(params[:equipment_type])
		  storage_tank = project.storage_tank_sizings.find(params[:tag_id])
		  pressure = storage_tank.md_design_pressure
	  elsif ["Process Piping"].include?(params[:equipment_type])
		  line = project.line_sizings.find(params[:tag_id])
		  pressure = line.line_number
	  elsif params[:equipment_type] == "HEX (Shell & Tube)"
		  hex = project.heat_exchanger_sizings.find(params[:tag_id])
		  if params[:equipment_section] == "Shell Side"
			  pressure = hex.dc_design_pressure_shell
		  else
			  pressure = hex.dc_design_pressure_tube
		  end
	  elsif params[:equipment_type] == "HEX (Double Pipe)"
		  hex = project.heat_exchanger_sizings.find(params[:tag_id])
  	      if params[:equipment_section] == "Inner Pipe"
			  pressure = hex.dc_design_pressure_shell
		  else
			  pressure = hex.dc_design_pressure_tube
		  end
	  elsif params[:equipment_type] == "HEX (Aerial Cooler)"
 		  hex = project.heat_exchanger_sizings.find(params[:tag_id])
		  pressure = hex.dc_design_pressure_shell
	  elsif params[:equipment_type] == "HEX (Plate & Frame)"
 		  hex = project.heat_exchanger_sizings.find(params[:tag_id])
  	      if params[:equipment_section] == "Hot Side"
			  pressure = hex.dc_design_pressure_shell
		  else
			  pressure = hex.dc_design_pressure_tube
		  end
	  elsif params[:equipment_type] == "Furnace Heater"
 		  hex = project.heat_exchanger_sizings.find(params[:tag_id])
  	      if params[:equipment_section] == "Radiant"
			  pressure = hex.dc_design_pressure_shell
		  else
			  pressure = hex.dc_design_pressure_tube
		  end
	  else
		  pressure = nil
	  end
	  render :json => {:design_pressure =>  pressure, :links => links}
  end


  def analyze
	  @relief_device_sizing = ReliefDeviceSizing.find(params[:relief_device_sizing_id])
	  max_pressure = @relief_device_sizing.relief_device_equipments.maximum("design_pressure")
	  tag = @relief_device_sizing.relief_device_equipments.where(["design_pressure = ?",max_pressure]).first
	  if tag.nil?
		  tag_name = nil
	  else
		  tag_id = tag.equipment_tag
		  unless tag_id.nil?
			  if ["Pressure Vessel", "Filter","Reactor"].include?(tag.equipment_type)
				  tag_name = VesselSizing.find(tag_id).name
			  elsif ["Column"].include?(tag.equipment_type)
				  tag_name = ColumnSizing.find(tag_id).column_system
			  elsif ["Low Pressure Tank"].include?(tag.equipment_type)
				  tag_name = StorageTankSizing.find(tag_id).storage_tank_tag
			  elsif ["HEX (Shell & Tube)", "HEX (Double Pipe)", "HEX (Aerial Cooler)", "HEX (Plate & Frame)", "Furnace Heater"].include?(tag.equipment_type)
				  tag_name = HeatExchangerSizing.find(tag_id).exchanger_tag
			  else
				  tag_name = nil
			  end
		  end
	  end
	  render :json => {:pressure => max_pressure, :tag => tag_name}
  end


  #scenario identification
  def scenario_identification
    @scenario_summary = ScenarioSummary.find(params[:scenario_summary_id])
    @relief_device_sizing = @scenario_summary.relief_device_sizing

    @scenario_identification = @scenario_summary.scenario_identification

    #projects
    @project = @relief_device_sizing.project
    @nominal_pipe_diameter_unit = @project.unit("Length", "Small Dimension Length")
    @uncertainty_factor = @project.pressure_relief_system_design_parameter.rdbp_uncertainty_factor

    #Relief Device Type
    @relief_device_type = @relief_device_sizing.relief_device_type.to_s

    if @scenario_identification.nil?
      @scenario_identification = ScenarioIdentification.new
      @scenario_identification.scenario_summary_id = @scenario_summary.id
      @scenario_identification.scenario_analysis_method = @scenario_summary.scenario

      if @relief_device_type == "Rupture Disk"
        @scenario_identification.rc_discharge_coefficient = @project.pressure_relief_system_design_parameter.rdsb_vdc_rupture_disk
      else
        @scenario_identification.rc_discharge_coefficient = @project.pressure_relief_system_design_parameter.rdsb_vdc_vapor
      end

      @scenario_identification.rc_back_pressure_correction_factor_list = @project.pressure_relief_system_design_parameter.prvcfb_vapor_back_pressure
      @scenario_identification.rc_liquid_back_pressure_correction_factor_list = @project.pressure_relief_system_design_parameter.prvcfb_liquid_back_pressure
      @scenario_identification.rc_overpressure_correction_factor_list = @project.pressure_relief_system_design_parameter.prvcfb_liquid_over_pressure
      @scenario_identification.rc_discharge_coefficient_list = @project.pressure_relief_system_design_parameter.prvcfb_low_pressure_vent_pressure

      @scenario_identification.save
    end

    @comments = @scenario_identification.comments
    @new_comment = @scenario_identification.comments.new

    @attachments = @scenario_identification.attachments
    @new_attachment = @scenario_identification.attachments.new

    @rc_streams = []
    unless @scenario_identification.rc_case.to_s == ""
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.rc_case)
      @rc_streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    @dc_streams = []
    unless @scenario_identification.dc_case.to_s == ""
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.dc_case)
      @dc_streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    @hem_streams_a = []
    unless @scenario_identification.hem_stream_a.to_s == ""
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.hem_stream_a)
      @hem_streams_a = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    @hem_streams_b = []
    unless @scenario_identification.hem_stream_b.to_s == ""
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.hem_stream_b)
      @hem_streams_b = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    @hem_streams_c = []
    unless @scenario_identification.hem_stream_c.to_s == ""
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.hem_stream_c)
      @hem_streams_c = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    p = @project.convert_pipe_roughness_values
    @pipes = p[:pipes]
    @project_pipes = p[:project_pipes]

    @breadcrumbs << { :name => @relief_device_sizing.system_description, :url => edit_admin_relief_device_sizing_path(@relief_device_sizing, :anchor => "scenario_summary") } if params[:action] == "scenario_identification"
    render :layout => false if request.xhr?
  end

  def update_scenario_identification
    @scenario_identification = ScenarioIdentification.find(params[:scenario_identification][:id])
    params[:scenario_identification].each do |attr|
      @scenario_identification[attr[0]] = attr[1]
    end
    @scenario_identification.save

    scenario_summary = @scenario_identification.scenario_summary
    scenario_summary.applicability = @scenario_identification.applicability
    scenario_summary.relief_rate = @scenario_identification.sc_relief_rate
    scenario_summary.required_orifice = @scenario_identification.rc_minimum_required_net_flow_area
    scenario_summary.save

    relief_device_sizing = scenario_summary.relief_device_sizing


    redirect_to edit_admin_relief_device_sizing_path(relief_device_sizing, :anchor => "scenario_summary")
  end

  def get_discharge_coefficient
    scenario_identification = ScenarioIdentification.find(params[:scenario_identification_id])
    scenario_summary = scenario_identification.scenario_summary
    relief_device_sizing = scenario_summary.relief_device_sizing

    #Relief Device Type
    relief_device_type = relief_device_sizing.relief_device_type.to_s
    project = relief_device_sizing.project
    discharge_coefficient_kd = ""

    if relief_device_type == "Pressure Relief Valve"
      if params[:relief_capacity_calculation_method] == "Vapor - Critical" || params[:relief_capacity_calculation_method] == "Vapor - Subcritical" || params[:relief_capacity_calculation_method] == "Vapor - Steam"
        discharge_coefficient_kd = project.pressure_relief_system_design_parameter.rdsb_vdc_vapor
      end

      if params[:relief_capacity_calculation_method] == "Liquid - Certified"
        discharge_coefficient_kd = project.pressure_relief_system_design_parameter.rdsb_vdc_liquid_certified
      end

      if params[:relief_capacity_calculation_method] == "Liquid - Non Certified"
        discharge_coefficient_kd = project.pressure_relief_system_design_parameter.rdsb_vdc_liquid_non_certified
      end

      if params[:relief_capacity_calculation_method] == "Two Phase HEM"
        discharge_coefficient_kd = project.pressure_relief_system_design_parameter.rdsb_vdc_two_phase
      end
    elsif relief_device_type == "Rupture Disk"
        discharge_coefficient_kd = project.pressure_relief_system_design_parameter.rdsb_vdc_rupture_disk
    end

    render :json => {:discharge_coefficient_kd => discharge_coefficient_kd}
  end

  def get_stream_values

    form_values = {}

    heat_and_material_balance = HeatAndMaterialBalance.find(params[:process_basis_id])
    property = heat_and_material_balance.heat_and_material_properties

    pressure = property.where(:phase => "Overall", :property => "Pressure").first
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first if pressure.nil?
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure] = pressure_stream.stream_value.to_f rescue nil

    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature] = temperature_stream.stream_value.to_f rescue nil

    mass_vapor_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    mass_vapor_fraction_stream = mass_vapor_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_vapor_fraction] = mass_vapor_fraction_stream.stream_value.to_f rescue nil

    vapor_density = property.where(:phase => "Vapour", :property => "Mass Density").first
    vapor_density_stream = vapor_density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_density] = vapor_density_stream.stream_value.to_f rescue nil

    vapor_viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
    vapor_viscosity_stream = vapor_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_viscosity] = vapor_viscosity_stream.stream_value.to_f rescue nil

    #not available
    vapor_k = property.where(:phase => "Vapour", :property => "Cp/Cv (Gamma)").first
    vapor_k_stream = vapor_k.streams.where(:stream_no => params[:stream_no]).first rescue nil
    form_values[:vapor_k] = vapor_k_stream.stream_value.to_f rescue nil

    #not available
    vapor_mw = property.where(:phase => "Vapour", :property => "Molecular Weight").first
    vapor_mw_stream = vapor_mw.streams.where(:stream_no => params[:stream_no]).first rescue nil
    form_values[:vapor_mw] = vapor_mw_stream.stream_value.to_f rescue nil

    vapor_z = property.where(:phase => "Vapour", :property => "Compressibility").first
    vapor_z_stream = vapor_z.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_z] = vapor_z_stream.stream_value.to_f rescue nil

    liquid_density = property.where(:phase => "Light Liquid", :property => "Mass Density").first
    liquid_density_stream = liquid_density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_density] = liquid_density_stream.stream_value.to_f rescue nil

    liquid_viscosity = property.where(:phase => "Light Liquid", :property => "Viscosity").first
    liquid_viscosity_stream = liquid_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_viscosity] = liquid_viscosity_stream.stream_value.to_f rescue nil

    liquid_surface_tension = property.where(:phase => "Light Liquid", :property => "Surface Tension").first
    liquid_surface_tension_stream = liquid_surface_tension.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_surface_tension] = liquid_surface_tension_stream.stream_value.to_f rescue nil

    #not available
    liquid_latent_heat = property.where(:phase => "Overall", :property => "Mass Heat Of Vapourisation").first
    liquid_latent_heat_stream = liquid_latent_heat.streams.where(:stream_no => params[:stream_no]).first rescue nil
    form_values[:liquid_latent_heat] = liquid_latent_heat_stream.stream_value.to_f rescue nil

    liquid_mw = property.where(:phase => "Light Liquid", :property => "Molecular Weight").first
    liquid_mw_stream = liquid_mw.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_mw] = liquid_mw_stream.stream_value.to_f rescue nil

    render :json => form_values
  end

  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Relief Device', :url => admin_relief_device_sizings_path }

  end

  def relief_devices
    @relief_device = ReliefDevice.new
    @unique_id = Time.now.to_i
    render :partial => 'relief_devices'
  end

  def locations
    @location = ReliefDeviceLocation.new
    @unique_id = Time.now.to_i
    # pump size unit
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
    render :partial => 'locations'
  end

  def rupture_disks
    @rupture_disk = ReliefDeviceRuptureDisk.new
    @unique_id = Time.now.to_i
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
    render :partial => 'rupture_disks'
  end

  def rupture_locations
    @rupture_location = ReliefDeviceRuptureLocation.new
    @unique_id = Time.now.to_i
    # pump size unit
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
    render :partial => 'rupture_locations'
  end

  def open_vent_relief_devices
    @open_vent_relief_device = ReliefDeviceOpenVentReliefDevice.new
    @unique_id = Time.now.to_i
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
    render :partial => 'open_vent_relief_devices'
  end

  def open_vent_locations
    @open_vent_location = ReliefDeviceOpenVentLocation.new
    @unique_id = Time.now.to_i
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
    render :partial => 'open_vent_locations'
  end

 def low_pressure_vent_relief_devices
   @low_pressure_vent_relief_device = ReliefDeviceLowPressureVentReliefDevice.new
   @unique_id = Time.now.to_i
   @fitting_pipe_size_unit = @user_project_settings.project.unit('Length','Small Dimension Length')
   render :partial => 'low_pressure_vent_relief_devices'
 end

  #get Orifice Area based on designation
  def relief_valve_orificearea
    orifice_areas = StaticData.rv_orificearea
    render :json => {:orifice_area => orifice_areas[params[:designation]]}
  end


  private

  def equipment_type
		 ["Process Line",
      "Pressure Vessel",
		  "Column",
		  "Filter",
		  "Reactor",
		  "Low Pressure Tank",
		  "Centrifugal Pump",
      "Reciprocating Pump",
      "Centrifugal Compressor",
      "Reciprocating Compressor",
		  "Steam Turbine",
		  "Turbo Expander",
		  "Hydraulic Turbine",
		  "HEX (Shell & Tube)",
		  "HEX (Double Pipe)",
		  "HEX (Plate & Frame)",
		  "Furnace Heater",
		  "User Specified"]
  end

  def eq_sections
	  {	"Process Line" => [],
      "Pressure Vessel" => [],
		  "Column" => ["Top","Bottom"],
		  "Filter" => [],
		  "Reactor" => [],
		  "Low Pressure Tank" => [],
      "Centrifugal Pump" => [],
      "Reciprocating Pump" => [],
		  "Centrifugal Compressor" => ["Stage 1","Stage 2","Stage 3","Stage 4","Stage 5","Stage 6","Stage 7","Stage8","Stage 9","Stage 10"],
		  "Reciprocating Compressor" => ["Stage 1","Stage 2","Stage 3","Stage 4","Stage 5","Stage 6","Stage 7","Stage8","Stage 9","Stage 10"],
		  "Steam Turbine" => [],
		  "Turbo Expander" => [],
		  "Hydraulic Turbine" => [],
		  "HEX (Shell & Tube)" => ["Shell","Tube"],
		  "HEX (Double Pipe)" => ["Inner","Outer"],
		  "HEX (Plate & Frame)" => ["Hot","Cold"],
		  "Furnace Heater" => ["Radiant","Convective"],
		  "User Specified" => []
	  }
  end

  def eq_tags(project)
	  t = {}
	  types = equipment_type
	  types.each do |type|
		  tags = equipment_tags(type,project)
		  if tags.empty?
			  t[type] = tags
		  else
			  t[type] = tags.collect! {|ta| [ta[1], ta[0]]}
		  end
	  end
	  return t
  end

  def eq_links(project)
    t = {}
    types = equipment_type
    types.each do |type|
      tags = equipment_links(type,project)
      if tags.empty?
        t[type] = tags
      else
        t[type] = tags.collect! {|ta| [ta[1], ta[0]]}
      end
    end
    return t
  end

  #return equipment tags based on equipment type
  def equipment_tags(equipment_type,project)
    if ["Process Line"].include?(equipment_type)
      project.line_sizings.collect {|v| [v.id, v.line_number]}
    elsif ["Pressure Vessel"].include?(equipment_type)
      project.vessel_sizings.collect {|v| [v.id, v.name]}
    elsif ["Column"].include?(equipment_type)
      project.column_sizings.collect {|v| [v.id, v.column_system]}
    elsif ["Filter"].include?(equipment_type)
      project.vessel_sizings.collect {|v| [v.id, v.name]}
    elsif ["Reactor"].include?(equipment_type)
      project.vessel_sizings.collect {|v| [v.id, v.name]}
    elsif ["Low Pressure Tank"].include?(equipment_type)
      project.storage_tank_sizings.collect {|v| [v.id, v.storage_tank_tag]}
    elsif ["Centrifugal Pump","Reciprocating Pump"].include?(equipment_type)
      project.pump_sizings.collect {|v| [v.id, v.centrifugal_pump_tag]}
    elsif ["Centrifugal Compressor","Reciprocating Compressor"].include?(equipment_type)
      project.compressor_sizing_tags.collect {|v| [v.id, v.compressor_sizing_tag]}
    elsif ["Steam Turbine","Turbo Expander","Hydraulic Turbine"].include?(equipment_type)
      []
	  elsif ["HEX (Shell & Tube)", "HEX (Double Pipe)", "HEX (Plate & Frame)","Furnace Heater"].include?(equipment_type)
		  project.heat_exchanger_sizings.collect {|v| [v.id, v.exchanger_tag]}
	  else
		  []
	  end
  end

  #return equipment view links based on equipment type
  def equipment_links(equipment_type,project)
    if ["Process Line"].include?(equipment_type)
      project.line_sizings.collect {|v| [v.id, 'line_sizings']}
    elsif ["Pressure Vessel"].include?(equipment_type)
      project.vessel_sizings.collect {|v| [v.id, 'vessel_sizings']}
    elsif ["Column"].include?(equipment_type)
      project.column_sizings.collect {|v| [v.id, 'column_sizings']}
    elsif ["Filter"].include?(equipment_type)
      project.vessel_sizings.collect {|v| [v.id, 'vessel_sizings']}
    elsif ["Reactor"].include?(equipment_type)
      project.vessel_sizings.collect {|v| [v.id, 'vessel_sizings']}
    elsif ["Low Pressure Tank"].include?(equipment_type)
      project.storage_tank_sizings.collect {|v| [v.id, 'storage_tank_sizings']}
    elsif ["Centrifugal Pump","Reciprocating Pump"].include?(equipment_type)
      project.pump_sizings.collect {|v| [v.id, 'pump_sizings']}
    elsif ["Centrifugal Compressor","Reciprocating Compressor"].include?(equipment_type)
      project.compressor_sizing_tags.collect {|v| [v.id, 'compressor_sizings']}
    elsif ["Steam Turbine","Turbo Expander","Hydraulic Turbine"].include?(equipment_type)
      []
    elsif ["HEX (Shell & Tube)", "HEX (Double Pipe)", "HEX (Plate & Frame)","Furnace Heater"].include?(equipment_type)
      project.heat_exchanger_sizings.collect {|v| [v.id, 'eat_exchanger_sizings']}
    else
      []
    end
  end

  def default_form_values

    @relief_device_sizing = ReliefDeviceSizing.find(params[:id]) rescue ReliefDeviceSizing.new

    @comments = @relief_device_sizing.comments
    @new_comment = @relief_device_sizing.comments.new

    @attachments = @relief_device_sizing.attachments
    @new_attachment = @relief_device_sizing.attachments.new

    #scenario summary
    @scenario_summaries = @relief_device_sizing.scenario_summaries

    @streams = []
  end



end
