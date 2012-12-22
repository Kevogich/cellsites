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
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
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
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
    # relief design & design summary
    if session[:relief_device_type]
      @relief_device_type = session[:relief_device_type]
    else
      @relief_device_type = @relief_device_sizing.relief_device_type.to_s
    end
    @rupture_disk_design_method = @user_project_settings.project.pressure_relief_system_design_parameter.rddm.to_s

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
    tags = [["select", "select"]] + equipment_tags(params[:equipment_type], @relief_device_sizing.project)
    #links =  equipment_links(params[:equipment_type],@relief_device_sizing.project)
    render :json => {:section => sections[params[:equipment_type]], :tags => tags}
  end

  #get design pressure based on equipment type and section
  def design_pressure
    @relief_device_sizing = ReliefDeviceSizing.find(params[:relief_device_sizing_id])
    links = equipment_links(params[:equipment_type], @relief_device_sizing.project)
    project = @relief_device_sizing.project
    if ["Pressure Vessel", "Filter", "Reactor"].include?(params[:equipment_type])
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
    render :json => {:design_pressure => pressure, :links => links}
  end


  def analyze
    @relief_device_sizing = ReliefDeviceSizing.find(params[:relief_device_sizing_id])
    max_pressure = @relief_device_sizing.relief_device_equipments.maximum("design_pressure")
    tag = @relief_device_sizing.relief_device_equipments.where(["design_pressure = ?", max_pressure]).first
    if tag.nil?
      tag_name = nil
    else
      tag_id = tag.equipment_tag
      unless tag_id.nil?
        if ["Pressure Vessel", "Filter", "Reactor"].include?(tag.equipment_type)
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


  def new_scenario_summary
    @relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    @new_scenario_summary = @relief_device_sizing.scenario_summaries.create
    render :json => {:new_scenario_summary => @new_scenario_summary}
  end

  def delete_scenario_summary
    scenario_summary = ScenarioSummary.find(params[:scenario_summary_id])
    scenario_summary.delete
  end

  #scenario identification
  def scenario_identification
    @scenario_summary = ScenarioSummary.find(params[:scenario_summary_id])
    @relief_device_sizing = @scenario_summary.relief_device_sizing
    @set_pressure = @relief_device_sizing.system_design_pressure

    @scenario_identification = @scenario_summary.scenario_identification

    #projects
    @project = @relief_device_sizing.project
    @barometric_pressure = @project.barometric_pressure

    @nominal_pipe_diameter_unit = @project.unit("Length", "Small Dimension Length")
    @uncertainty_factor = @project.pressure_relief_system_design_parameter.rdbp_uncertainty_factor

    #Relief Device Type
    @relief_device_type = @relief_device_sizing.relief_device_type.to_s
    @relief_capacity_calculation_method_type = @relief_device_type
    if @relief_device_type == "Rupture Disk"
      if @project.pressure_relief_system_design_parameter.rddm == "Coefficient of Discharge Method"
        @relief_capacity_calculation_method_type = "Pressure Relief Valve"
      elsif @project.pressure_relief_system_design_parameter.rddm == "Flow Resistance Method"
        @relief_capacity_calculation_method_type = "Open Vent"
      end
    end

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
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.hem_process_basis_a)
      @hem_streams_a = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    @hem_streams_b = []
    unless @scenario_identification.hem_stream_b.to_s == ""
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.hem_process_basis_b)
      @hem_streams_b = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    @hem_streams_c = []
    unless @scenario_identification.hem_stream_c.to_s == ""
      heat_and_material_balance = HeatAndMaterialBalance.find(@scenario_identification.hem_process_basis_c)
      @hem_streams_c = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    p = @project.convert_pipe_roughness_values
    @pipes = p[:pipes]
    @project_pipes = p[:project_pipes]

    @breadcrumbs << {:name => @relief_device_sizing.system_description, :url => edit_admin_relief_device_sizing_path(@relief_device_sizing, :anchor => "scenario_summary")} if params[:action] == "scenario_identification"
    render :layout => false if request.xhr?
  end

  def update_scenario_identification
    @scenario_identification = ScenarioIdentification.find(params[:scenario_identification][:id])
    params[:scenario_identification].each do |attr|
      @scenario_identification[attr[0]] = attr[1]
    end
    @scenario_identification.save

    @scenario_summary = @scenario_identification.scenario_summary
    @scenario_summary.applicability = @scenario_identification.applicability
    @scenario_summary.relief_rate = @scenario_identification.rc_mass_flow_rate

    # setting Required Orifice based on Required Capacity Calculation Method which involves Effected Discharge Area or  Minimum Required Net Flow Area
    effective_discharge_area_arr = ["Vapor - Critical",
                                    "Vapor - Subcritical",
                                    "Vapor - Steam",
                                    "Liquid - Certified",
                                    "Liquid - Non Certified",
                                    "Two Phase HEM",
                                    "Low Pressure Vent"]

    minimum_required_net_flow_area_arr = ["Line Capacity"]

    if effective_discharge_area_arr.include?(@scenario_identification.relief_capacity_calculation_method)
      @scenario_summary.required_orifice = @scenario_identification.rc_effective_discharge_area
    end

    if minimum_required_net_flow_area_arr.include?(@scenario_identification.relief_capacity_calculation_method)
      @scenario_summary.required_orifice = @scenario_identification.rc_minimum_required_net_flow_area
    end

    if @scenario_identification.applicability == "No"
      @scenario_summary.relief_rate = nil
      @scenario_summary.required_orifice = nil
    end

    @scenario_summary.save

    @relief_device_sizing = @scenario_summary.relief_device_sizing
    @project = @relief_device_sizing.project

    if params[:calculate_btn] == "relief_sizing_method_selection"
      relief_sizing_method_selection

      #required capacity tab pressure calculation
      @required_capacity_tab_values = {}

      begin

        #Point a Pressure = Relief Conditions Pressure + Barometric Pressure
        relief_conditions_pressure = @scenario_identification.rc_pressure
        #uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
        #relief_conditions_pressure = uom[:factor] * relief_conditions_pressure

        barometric_pressure = @project.barometric_pressure
        #uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
        #barometric_pressure = uom[:factor] * barometric_pressure

        point_a_pressure = relief_conditions_pressure + barometric_pressure
        @required_capacity_tab_values["point_a_pressure"] = point_a_pressure

        #Point C Pressure = Discharge Conditions Pressure + Barometric Pressure
        discharge_conditions_pressure = @scenario_identification.dc_pressure
        #uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
        #discharge_conditions_pressure = uom[:factor] * discharge_conditions_pressure

        point_c_pressure = discharge_conditions_pressure + barometric_pressure
        @required_capacity_tab_values["point_c_pressure"] = point_c_pressure

        #Relieving Pressure (p1) = Relief Conditions Pressure + Barometric Pressure
        relieving_pressure = relief_conditions_pressure + barometric_pressure
        @required_capacity_tab_values["relieving_pressure"] = relieving_pressure

        #Total Back Pressure (p2) = Discharge Conditions Pressure + Barometric Pressure
        total_back_pressure = discharge_conditions_pressure + barometric_pressure
        @required_capacity_tab_values["total_back_pressure"] = total_back_pressure

        #Specific Gravity (G) = Relief Conditions Liquid Density / 62.4
        relief_conditions_liquid_density = @scenario_identification.rc_liquid_density
        uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
        relief_conditions_liquid_density = uom[:factor] * relief_conditions_liquid_density

        specific_gravity = relief_conditions_liquid_density / 62.4
        @required_capacity_tab_values["specific_gravity"] = specific_gravity

        #setting Line Capacity Relief Condition
        @line_capacity_relief_condition = @scenario_identification.line_capacity_relief_condition

        if @scenario_identification.rc_mass_vapor_fraction >= 0 and @scenario_identification.rc_mass_vapor_fraction <= 1
          @scenario_identification.line_capacity_relief_condition = "Two Phase"
        end

        if @scenario_identification.rc_mass_vapor_fraction == 0 and @scenario_identification.rc_pressure >= @scenario_identification.dc_pressure
          @scenario_identification.line_capacity_relief_condition = "Liquid"
        end

        if @scenario_identification.dc_mass_vapor_fraction >= 0 and @scenario_identification.dc_mass_vapor_fraction <= 1
          @scenario_identification.line_capacity_relief_condition = "Vapour"
        end

        @line_capacity_relief_condition = @scenario_identification.line_capacity_relief_condition

        @scenario_identification.save

      rescue Exception => e
        logger.debug e.message
        logger.debug e.backtrace.inspect
      end

    elsif params[:calculate_btn] == "effective_discharge_area_calculation"
      effective_discharge_area_calculation
    else
      redirect_to edit_admin_relief_device_sizing_path(@relief_device_sizing, :anchor => "scenario_summary") if !request.xhr?
    end


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

    mass_flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    mass_flow_rate_stream = mass_flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:mass_flow_rate] = mass_flow_rate_stream.stream_value.to_f rescue nil

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

  def set_pressure_system_description
    @relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    @relief_device_system_descriptions = @relief_device_sizing.relief_device_system_descriptions
    @relief_device_system_description = @relief_device_sizing.relief_device_system_descriptions.new

    @selected_system_description = @relief_device_sizing.relief_device_system_descriptions.where("prv_location = true").first

    @equipment_type = equipment_type
    @equipment_section = eq_sections

    project = @relief_device_sizing.project
    @equipment_tags = eq_tags(project)

    render :layout => false if request.xhr?
  end

  def save_system_description
    @relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    params[:relief_device_sizing][:relief_device_system_descriptions_attributes].each_with_index do |sd, i|
      begin
        next if sd[1][:id].to_s == ""
        params[:relief_device_sizing][:relief_device_system_descriptions_attributes][i.to_s][:prv_location] = false
        params[:relief_device_sizing][:relief_device_system_descriptions_attributes][i.to_s][:prv_location] = true if sd[1]["id"] == params[:prv_location_id] and !sd[1]["id"].nil?
      rescue Exception => e
        next
      end
    end

    @relief_device_sizing.update_attributes(params[:relief_device_sizing])
  end

  def refresh_system_description
    @relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    @relief_device_sizing.relief_device_system_descriptions.delete_all

    @relief_device_sizing.relief_device_equipments.each_with_index do |equipment, i|
      @relief_device_sizing.relief_device_system_descriptions.create({
                                                                       "sequence_no" => i+1,
                                                                       "equipment_type" => equipment.equipment_type,
                                                                       "equipment_tag" => equipment.equipment_tag,
                                                                       "section" => equipment.equipment_section,
                                                                       "description" => equipment.equipment_description,
                                                                       "design_pressure" => equipment.design_pressure
                                                                     })
    end
  end


  def set_breadcrumbs
    super
    @breadcrumbs << {:name => 'Relief Device', :url => admin_relief_device_sizings_path}
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
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
    render :partial => 'locations'
  end

  def rupture_disks
    @rupture_disk = ReliefDeviceRuptureDisk.new
    @unique_id = Time.now.to_i
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
    render :partial => 'rupture_disks'
  end

  def rupture_locations
    @rupture_location = ReliefDeviceRuptureLocation.new
    @unique_id = Time.now.to_i
    # pump size unit
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
    render :partial => 'rupture_locations'
  end

  def open_vent_relief_devices
    @open_vent_relief_device = ReliefDeviceOpenVentReliefDevice.new
    @unique_id = Time.now.to_i
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
    render :partial => 'open_vent_relief_devices'
  end

  def open_vent_locations
    @open_vent_location = ReliefDeviceOpenVentLocation.new
    @unique_id = Time.now.to_i
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
    render :partial => 'open_vent_locations'
  end

  def low_pressure_vent_relief_devices
    @low_pressure_vent_relief_device = ReliefDeviceLowPressureVentReliefDevice.new
    @unique_id = Time.now.to_i
    @fitting_pipe_size_unit = @user_project_settings.project.unit('Length', 'Small Dimension Length')
    render :partial => 'low_pressure_vent_relief_devices'
  end

  #get Orifice Area based on designation
  def relief_valve_orificearea
    orifice_areas = StaticData.rv_orificearea
    render :json => {:orifice_area => orifice_areas[params[:designation]]}
  end

  # change design summary based on Relief device type
  def design_summary
    @relief_device_sizing = ReliefDeviceSizing.find(params[:relief_device_sizing_id])
    @relief_device_type = params[:relief_device_type]
    session[:relief_device_type] = @relief_device_type
    @rupture_disk_design_method = @user_project_settings.project.pressure_relief_system_design_parameter.rddm.to_s
    #scenario summary where applicability is yes -- design summary
    @applicable_scenario_summaries = @relief_device_sizing.scenario_summaries.where(:applicability => 'Yes')
    @scenario_summaries_max_area = @applicable_scenario_summaries.maximum("required_orifice")
    render :partial => 'form_system_summary'
  end

  def reset_relief_design
    @relief_device_sizing = ReliefDeviceSizing.find(params[:relief_device_sizing_id])
    if params[:relief_device_type]== "pressure_relief_device"
      @relief_device_sizing.relief_devices.destroy_all
      @relief_device_sizing.relief_device_locations.destroy_all
    elsif params[:relief_device_type]== "rupture_disk"
      @relief_device_sizing.relief_device_rupture_disks.destroy_all
      @relief_device_sizing.relief_device_rupture_locations.destroy_all
    else
      params[:relief_device_type]== "open_vent"
      @relief_device_sizing.relief_device_open_vent_relief_devices.destroy_all
      @relief_device_sizing.relief_device_open_vent_locations.destroy_all
    end
    redirect_to edit_admin_relief_device_sizing_path(@relief_device_sizing, :anchor => "system_design")
  end

  def cal_pressure_relief
    relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    #pump_sizing = PumpSizing.find(1)
    scenario_summaries = relief_device_sizing.scenario_summaries
    project = relief_device_sizing.project
    #log = CustomLogger.new('relief_device_sizing')

    selected_area = (1..100).to_a
    orifice_area = (1..100).to_a
    required_area = (1..100).to_a
    selected_area2 = (1..100).to_a
    split_flow_basis = (1..100).to_a
    required_area2 = (1..100).to_a
    scenario_rate = (1..100).to_a
    relief_phase = (1..100).to_a
    relief_capacity_change = (1..100).to_a
    pi = 3.14159265358979
    set_pressure =0

    max_orifice_designation = project.pressure_relief_system_design_parameter.largest_orifice_size_to_consider
    max_orifice_size_per_valve = (StaticData.rv_orificearea[max_orifice_designation]).to_f

    sizing_basis_required_area = scenario_summaries.where(:applicability => 'Yes').maximum("required_orifice")
    lowest_set_pressure = (relief_device_sizing.system_design_pressure).to_f
    pressure_relief_valve_count = project.pressure_relief_system_design_parameter.pressure_relief_valve_count
    pressure_relief_valve_count_stagger_set_pressure = project.pressure_relief_system_design_parameter.pressure_relief_valve_count_stagger_set_pressure
    reconcile_body_size_api = project.pressure_relief_system_design_parameter.pressure_relief_valve_count_reconcile_body_size_api
    valve_body_size_selection_basis = project.pressure_relief_system_design_parameter.valve_body_size_selection_basis
    relief_devices_count = relief_device_sizing.relief_devices.count
    scenario_count = relief_device_sizing.scenario_summaries.count
    scenario_id_count = relief_device_sizing.scenario_identifications.count


#    uom = project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
#    orifice_area = uom[:factor] * sizing_basis_required_area
#    log.info("converted orifice_area = #{orifice_area}")

    sizing_basis_required_area = relief_device_sizing.convert_to_base_unit(:orifice_area, sizing_basis_required_area)
#log.info("converted SizingBasisRequiredArea = #{sizing_basis_required_area}")

    lowest_set_pressure = relief_device_sizing.convert_to_base_unit(:lowest_set_pressure, lowest_set_pressure)
#log.info("converted LowestSetPressure = #{lowest_set_pressure}")

    if pressure_relief_valve_count=="Minimize Relief Device Count"
      psv_count=1
      (0..relief_devices_count-1).each do |k|
        if sizing_basis_required_area < max_orifice_size_per_valve
          if (0..0.11).include?(sizing_basis_required_area)
            selected_area[k]=0.11
          elsif (0.11..0.196).include?(sizing_basis_required_area)
            selected_area[k]=0.196
          elsif (0.196..0.307).include?(sizing_basis_required_area)
            selected_area[k]=0.307
          elsif (0.307..0.503).include?(sizing_basis_required_area)
            selected_area[k]=0.503
          elsif (0.503..0.785).include?(sizing_basis_required_area)
            selected_area[k]=0.785
          elsif (0.785..1.287).include?(sizing_basis_required_area)
            selected_area[k]=1.287
          elsif (1.287..1.838).include?(sizing_basis_required_area)
            selected_area[k]=1.838
          elsif (1.838..2.853).include?(sizing_basis_required_area)
            selected_area[k]=2.853
          elsif (2.853..3.6).include?(sizing_basis_required_area)
            selected_area[k]=3.6
          elsif (3.6..4.34).include?(sizing_basis_required_area)
            selected_area[k]=4.34
          elsif (4.34..6.38).include?(sizing_basis_required_area)
            selected_area[k]=6.38
          elsif (6.38..11.05).include?(sizing_basis_required_area)
            selected_area[k]=11.05
          elsif (11.05..16).include?(sizing_basis_required_area)
            selected_area[k]=16
          elsif (16..26).include?(sizing_basis_required_area)
            selected_area[k]=26
          end
          selected_area[k] = relief_device_sizing.convert_to_project_unit(:orifice_area, selected_area[k])
          k = relief_devices_count
        elsif sizing_basis_required_area >= max_orifice_size_per_valve
          selected_area[k] = max_orifice_size_per_valve
          selected_area[k] = relief_device_sizing.convert_to_project_unit(:orifice_area, selected_area[k])
          left_over_area = sizing_basis_required_area - (max_orifice_size_per_valve * k)
          if left_over_area < max_orifice_size_per_valve
            k = relief_devices_count
          end
          psv_count = psv_count + 1
        end
      end

      if psv_count > 1
        if left_over_area>0 and left_over_area<0.11
          selected_left_over_area = 0.11
        elsif left_over_area>0.11 and left_over_area<0.196
          selected_left_over_area=0.196
        elsif left_over_area>0.196 and left_over_area<0.307
          selected_left_over_area=0.307
        elsif left_over_area>0.307 and left_over_area<0.503
          selected_left_over_area=0.503
        elsif left_over_area>0.503 and left_over_area<0.785
          selected_left_over_area=0.785
        elsif left_over_area>0.785 and left_over_area<1.287
          selected_left_over_area=1.287
        elsif left_over_area>1.287 and left_over_area<1.838
          selected_left_over_area=1.838
        elsif left_over_area>1.838 and left_over_area<2.853
          selected_left_over_area=2.853
        elsif left_over_area>2.853 and left_over_area<3.6
          selected_left_over_area=3.6
        elsif left_over_area>3.6 and left_over_area<4.34
          selected_left_over_area=4.34
        elsif left_over_area>4.34 and left_over_area<6.38
          selected_left_over_area=6.38
        elsif left_over_area>6.38 and left_over_area<11.05
          selected_left_over_area=11.05
        elsif left_over_area>11.05 and left_over_area<16
          selected_left_over_area=16
        elsif left_over_area>16 and left_over_area<26
          selected_left_over_area=26
        end
        selected_left_over_area = relief_device_sizing.convert_to_project_unit(:orifice_area, selected_left_over_area)
        if pressure_relief_valve_count_stagger_set_pressure
          if scenario_count > 1
            if left_over_area < max_orifice_size_per_valve
              set_pressure = lowest_set_pressure
            end
          else
            set_pressure = lowest_set_pressure
          end
        else
          set_pressure = lowest_set_pressure
        end

        # save set pressure value to db
        relied_device = relief_device_sizing.relief_devices[psv_count-1]
        relied_device.update_attributes(:pressure => set_pressure)
        relied_device.save

        (0..psv_count-2).each do |r|
          if pressure_relief_valve_count_stagger_set_pressure
            if scenario_count > 1
              if psv_count > 1
                if relief_device_sizing.relief_devices[r]['orificearea'] < max_orifice_size_per_valve
                  set_pressure = lowest_set_pressure
                else
                  set_pressure = lowest_set_pressure*1.05 #195
                end
              else
                set_pressure = lowest_set_pressure
              end
            else
              set_pressure = lowest_set_pressure
            end
          else
            set_pressure = lowest_set_pressure
          end
          # save set pressure value to db
          relied_device = relief_device_sizing.relief_devices[r]
          relied_device.update_attributes(:pressure => set_pressure)
          relied_device.save
        end

      elsif psv_count == 1
        if pressure_relief_valve_count_stagger_set_pressure
          set_pressure = lowest_set_pressure
          # save set pressure value to db
          relied_device = relief_device_sizing.relief_devices[psv_count-1]
          relied_device.update_attributes(:pressure => set_pressure)
          relied_device.save
        end
      else
        #this case never comes                                                        #215
        # save set pressure value to db
      end
    elsif pressure_relief_valve_count == "Minimize Possibility of Chattering"
      minimum_required_area = relief_device_sizing.scenario_summaries.minimum("required_orifice")
      minimum_required_area = relief_device_sizing.convert_to_base_unit(:orifice_area, minimum_required_area)

      #Sort scenario required orifice area in ascending order
      scn_summaries=relief_device_sizing.scenario_summaries.order("required_orifice")

      #Determine selected orifice distribution
      if scenario_count > 1
        (0..scenario_count-1).each do |s|
          split_flow_basis[s]=(1/(1+s)) * sizing_basis_required_area
          if !(minimum_required_area < 0.65 * split_flow_basis[s])
            if split_flow_basis[s] > 0 and split_flow_basis[s] <= 0.11
              selected_area2[1] = 0.11
            elsif split_flow_basis[s] > 0.11 and split_flow_basis[s] <= 0.196
              selected_area2[1] = 0.196
            elsif split_flow_basis[s] > 0.196 and split_flow_basis[s] <= 0.307
              selected_area2[1] = 0.307
            elsif split_flow_basis[s] > 0.307 and split_flow_basis[s] <= 0.503
              selected_area2[1] = 0.503
            elsif split_flow_basis[s] > 0.503 and split_flow_basis[s] <= 0.785
              selected_area2[1] = 0.785
            elsif split_flow_basis[s] > 0.785 and split_flow_basis[s] <= 1.287
              selected_area2[1] = 1.287
            elsif split_flow_basis[s] > 1.287 and split_flow_basis[s] <= 1.838
              selected_area2[1] = 1.838
            elsif split_flow_basis[s] > 1.838 and split_flow_basis[s] <= 2.853
              selected_area2[1] = 2.853
            elsif split_flow_basis[s] > 2.853 and split_flow_basis[s] <= 3.6
              selected_area2[1] = 3.6
            elsif split_flow_basis[s] > 3.6 and split_flow_basis[s] <= 4.34
              selected_area2[1] = 4.34
            elsif split_flow_basis[s] > 4.34 and split_flow_basis[s] <= 6.38
              selected_area2[1] = 6.38
            elsif split_flow_basis[s] > 6.38 and split_flow_basis[s] <= 11.05
              selected_area2[1] = 11.05
            elsif split_flow_basis[s] > 11.05 and split_flow_basis[s] <= 16
              selected_area2[1] = 16
            elsif split_flow_basis[s] > 16 and split_flow_basis[s] <= 26
              selected_area2[1] = 26
            end
            s = scenario_count
          end
        end
      end
      psv_grouping = 1
      (2..20).each do |v|
        (0..scenario_count-1).each do |u|
          required_area[v][u]=scn_summaries[u]["required_orifice"]
          required_area[v][u] = relief_device_sizing.convert_to_base_unit(:orifice_area, required_area[v][u])
          sum_of_area=scn_summaries.sum("orificearea")
          sum_of_area = relief_device_sizing.convert_to_base_unit(:orifice_area, sum_of_area)
          if required_area[v][u] > selected_area2[1]
            balance_of_area= required_area[v][u] - sum_of_area

            if balance_of_area > selected_area2[1]
              if balance_of_area > 0 and balance_of_area <=0.11
                selected_area2[v]=0.11
              elsif balance_of_area > 0.11 and balance_of_area <=0.196
                selected_area2[v]=0.196
              elsif balance_of_area > 0.196 and balance_of_area <= 0.307
                selected_area2[v] = 0.307
              elsif balance_of_area > 0.307 and balance_of_area <= 0.503
                selected_area2[v] = 0.503
              elsif balance_of_area > 0.503 and balance_of_area <= 0.785
                selected_area2[v] = 0.785
              elsif balance_of_area > 0.785 and balance_of_area <= 1.287
                selected_area2[v] = 1.287
              elsif balance_of_area > 1.287 and balance_of_area <= 1.838
                selected_area2[v] = 1.838
              elsif balance_of_area > 1.838 and balance_of_area <= 2.853
                selected_area2[v] = 2.853
              elsif balance_of_area > 2.853 and balance_of_area <= 3.6
                selected_area2[v] = 3.6
              elsif balance_of_area > 3.6 and balance_of_area <= 4.34
                selected_area2[v] = 4.34
              elsif balance_of_area > 4.34 and balance_of_area <= 6.38
                selected_area2[v] = 6.38
              elsif balance_of_area > 6.38 and balance_of_area <= 11.05
                selected_area2[v] = 11.05
              end

              if max_orifice_size_per_valve == 16
                if balance_of_area > 11.05 and balance_of_area <=16
                  selected_area2[v]=16
                end
              elsif max_orifice_size_per_valve == 26
                if balance_of_area > 11.05 and balance_of_area <=16
                  selected_area2[v]=16
                elsif balance_of_area > 16 and balance_of_area <=26
                  selected_area2[v]=26
                end
              end
              if balance_of_area > max_orifice_size_per_valve
                selected_area2[v]=max_orifice_size_per_valve
              end
              psv_grouping = psv_grouping + 1
            end
          end
        end
        selected_area2[v] = relief_device_sizing.convert_to_project_unit(:orifice_area, selected_area2[v])
      end
      selected_area2[1] = relief_device_sizing.convert_to_project_unit(:orifice_area, selected_area2[1]) #386

      #Determine staggering of set pressures
      system_count_area = 0
      relief_capacity_change_count = 0
      (1..10).each do |d|
        relief_capacity_change[d]=system_count_area
        (0..scenario_count-1).each do |x|
          scenario_rate[x] = scn_summaries[x]["relief_rate"]
          if scenario_rate[x] > system_count_area
            (1..psv_grouping).each do |y|
              required_area2[x]= scn_summaries[y]["required_orifice"]
              system_count_area =system_count_area + required_area2[x]
              if scenario_rate[x] < system_count_area
                relief_capacity_change[d]=system_count_area
                if relief_capacity_change[d-1] != relief_capacity_change[d]
                  relief_capacity_change_count = relief_capacity_change_count + 1
                  d= d+1
                  system_count_area=0
                end
                y=psv_grouping
              end
            end
          end
          system_count_area = 0
        end
        d=10
      end
      pressure_increment = ((lowest_set_pressure * 0.05)/(relief_capacity_change_count -1))
      psv_count =0
      sumof_relief_capacity = 0
      count=0
      (1..10).each do |cc|
        relief_capacity_change[cc]=sumof_relief_capacity
        (0..scenario_count-1).each do |aa|
          scenario_rate[aa]= scn_summaries[aa]["relief_rate"]
          (1..psv_count).each do |bb|
            required_area2[bb]= scn_summaries.required_orifice[bb+1-1]["orificearea"]
            sumof_relief_capacity = sumof_relief_capacity + required_area2[bb]
            if scenario_rate[aa] > sumof_relief_capacity
            elsif scenario_rate[aa] <= sumof_relief_capacity
              relief_capacity_change[cc]=sumof_relief_capacity
              if relief_capacity_change[cc] != relief_capacity_change[cc-1] and required_area2[bb+1]!=nil
                if relief_device_sizing.relief_devices[bb-1]["pressure"] == nil
                  set_pressure = (lowest_set_pressure + (pressure_increment * count))
                  # save set pressure value to db
                  relied_device = relief_device_sizing.relief_devices[bb-1]
                  relied_device.update_attributes(:pressure => set_pressure)
                  relied_device.save
                  count = count + 1
                  cc = cc + 1
                end
              end
              bb = psv_count
            end
          end
          sumof_relief_capacity = 0
        end
        cc =10
      end
      #Filling in the blanks for set pressures  466
      relied_device = relief_device_sizing.relief_devices[psv_count-1]
      relied_device.update_attributes(:pressure => (lowest_set_pressure * 1.05))
      relied_device.save

      (0..psv_count-1).each do |ddd|
        if relief_device_sizing.relief_devices[psv_count-ddd-1]["pressure"] == nil
          set_pressure = relief_device_sizing.relief_devices[psv_count-ddd]["pressure"]
          # save set pressure value to db
          relied_device = relief_device_sizing.relief_devices[psv_count-ddd-1]
          relied_device.update_attributes(:pressure => set_pressure)
          relied_device.save
        end
      end
    end

    #Associate Orifice Designation
    psv_count = relief_devices_count

    (0..psv_count-1).each do |p|
      orifice_area[p]=relief_device_sizing.relief_devices[p]["orificearea"]
      orifice_area[p]= relief_device_sizing.convert_to_base_unit(:orifice_area, orifice_area[p])

      if orifice_area[p]==0.11
        orifice_designation = "D"
      elsif orifice_area[p]== 0.196
        orifice_designation = "E"
      elsif orifice_area[p]== 0.307
        orifice_designation = "F"
      elsif orifice_area[p]== 0.503
        orifice_designation = "G"
      elsif orifice_area[p]== 0.785
        orifice_designation = "H"
      elsif orifice_area[p]== 2.287
        orifice_designation = "J"
      elsif orifice_area[p]== 2.838
        orifice_designation = "K"
      elsif orifice_area[p]== 2.853
        orifice_designation = "L"
      elsif orifice_area[p]== 3.6
        orifice_designation = "M"
      elsif orifice_area[p]== 4.34
        orifice_designation = "N"
      elsif orifice_area[p]== 6.38
        orifice_designation = "P"
      elsif orifice_area[p]== 11.05
        orifice_designation = "Q"
      elsif orifice_area[p]== 16
        orifice_designation = "R"
      elsif orifice_area[p]== 26
        orifice_designation = "T"
      end
      relied_device = relief_device_sizing.relief_devices[p]
      relied_device.update_attributes(:designation => orifice_designation)
      relied_device.save
    end

    #Associate appropriate body size
    (0..psv_count-1).each do |q|
      orifice_desig= relief_device_sizing.relief_devices[q]["designation"]
      if ["D", "E", "F"].include?(orifice_desig)
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="1\BD x 2\BD"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="1 x 2"
        end
      elsif orifice_desig == "G"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="2 x 3"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="1\BD x 2\BD"
        end
      elsif orifice_desig == "H"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="2 x 3"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="1\BD x 3"
        end
      elsif orifice_desig == "J"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="3 x 4"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="2 x 3"
        end
      elsif orifice_desig == "K"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="3 x 4"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="3 x 4"
        end
      elsif orifice_desig == "L"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="4 x 6"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="3 x 4"
        end
      elsif ["M", "N", "P"].include?(orifice_desig)
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="4 x 6"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="4 x 6"
        end
      elsif orifice_desig == "Q"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="6 x 8"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="6 x 8"
        end
      elsif orifice_desig == "R"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="6 x 10"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="6 x 8"
        end
      elsif orifice_desig == "T"
        if valve_body_size_selection_basis=="Always Use Larger Body Size For Given Orifice"
          body_size="8 x 10"
        elsif valve_body_size_selection_basis=="Always Use Smaller Body Size For Given Orifice"
          body_size="8 x 10"
        end
      end
      relied_device = relief_device_sizing.relief_devices[q]
      relied_device.update_attributes(:bodysize => body_size)
      relied_device.save
    end

    #Determine Relief Device Sub-Type: Relief, Safety Relief, Safety
    count_safety = 0
    count_relief = 0
    count_safety_relief = 0
    (0..scenario_id_count-1).each do |z|
      relief_phase[z]=relief_device_sizing.scenario_identifications[z]["rc_mass_vapor_fraction"]
      relief_phase[z]=(relief_phase[z]).to_f
      if relief_phase[z]==0
        relief_phase[z]="Liquid"
      elsif relief_phase[z]==1
        relief_phase[z]="Vapor"
      elsif relief_phase[z] > 0 and relief_phase[z] < 1
        relief_phase[z]="Two Phase"
      end
      if relief_phase[z]!= "Two Phase" and relief_phase[z]!= "Liquid"
        count_safety+=1
      elsif relief_phase[z]!="Two Phase" and relief_phase[z]!= "Vapor"
        count_relief+=1
      end
    end

    if count_safety==scenario_count
      relief_device_sub_type="Safety"
    elsif count_relief==scenario_count
      relief_device_sub_type="Relief"
    else
      relief_device_sub_type="Safety Relief"
    end

    (0..psv_count-1).each do |a|
      relied_device = relief_device_sizing.relief_devices[a]
      relied_device.update_attributes(:subtype => relief_device_sub_type)
      relied_device.save
    end

    #Determine Relief Device Type: Conventional, Balanced Bellows, Pilot Operated.
    disposition=relief_device_sizing["discharge_location"]
    count_two_phase=0
    (0..scenario_count-1).each do |b|
      if relief_phase[b]=="Two Phase"
        count_two_phase= count_two_phase + 1
      end
    end
    if count_two_phase>0
      relief_device_type="Balanced Bellow"
    else
      if disposition == "Pressurized Collection System" and lowest_set_pressure >= 500
        relief_device_type = "Conventional"
      elsif disposition == "Pressurized Collection System" and lowest_set_pressure < 500
        relif_device_type = "Balanced Bellow"
      elsif disposition == "Pressurized Process Equipment"
        relief_device_type = "Balanced Bellow"
      else
        relief_device_type = "Conventional"
      end
    end
    (0..psv_count-1).each do |c|
      relied_device = relief_device_sizing.relief_devices[c]
      relied_device.update_attributes(:psvtype => relief_device_type)
      relied_device.save
    end

    relief_device_tag = (1..10).to_a
    orifice_area = (1..10).to_a
    orifice_designation = (1..10).to_a
    body_size = (1..10).to_a
    set_pressure = (1..10).to_a
    relief_valve_type = (1..10).to_a
    min_temp = (1..10).to_a
    max_temp = (1..10).to_a
    spring_material = (1..10).to_a
    body_material = (1..10).to_a
    inlet_flange = (1..10).to_a
    outlet_flange = (1..10).to_a
    mechanical_back_pressure_limit = (1..10).to_a
    # find by the max Relief temperature
    relief_max_temp = relief_device_sizing.scenario_identifications.where(:applicability => 'Yes').maximum("rc_temperature")
    discharge_min_temp = relief_device_sizing.scenario_identifications.where(:applicability => 'Yes').minimum("dc_temperature")
    maximum_temp = relief_max_temp
    minimum_temp = discharge_min_temp

    #save values to db
    #relief_device_sizing.update_attributes(:system_min_design_temp => minimum_temp, :system_max_design_temp => maximum_temp)
    #relief_device_sizing.save

    # line 48-73 already done

    #Determine Body/Bonnet and Spring Material and Mechanical Back Pressure Limits
    (0..psv_count-1).each do |n|
      relief_device_tag[n]=relief_device_sizing.relief_devices[n]["psvtag"]
      orifice_designation[n]= relief_device_sizing.relief_devices[n]["designation"]
      body_size[n]=relief_device_sizing.relief_devices[n]["bodysize"]
      set_pressure[n]=relief_device_sizing.relief_devices[n]["pressure"]
      #relief_device_type[n]=relief_device_sizing.relief_devices[n]["psvtype"]
      set_pressure[n] = relief_device_sizing.convert_to_base_unit(:su_pressure, set_pressure[n])
      maximum_temp = relief_device_sizing.convert_to_base_unit(:su_temperature, maximum_temp)
      minimum_temp = relief_device_sizing.convert_to_base_unit(:su_temperature, minimum_temp)


      if orifice_designation[n] == "D"
        if body_size[n] == "1 x 2" or body_size[n] == "1 1/2'' x 2" or body_size[n] == "1 1/2'' x 2 1/2''"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 3600
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3600 and set_pressure[n] <= 4000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 3600
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3600 and set_pressure[n] <= 6000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1480 and set_pressure[n] <= 2220
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2220 and set_pressure[n] <= 3705
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3705 and set_pressure[n] <= 6000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1235
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1235 and set_pressure[n] <= 1845
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1845 and set_pressure[n] <= 3080
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3080 and set_pressure[n] <= 5135
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1015
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1015 and set_pressure[n] <= 1525
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1525 and set_pressure[n] <= 2540
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2540 and set_pressure[n] <= 4230
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1050 and set_pressure[n] <= 1750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1750 and set_pressure[n] <= 2915
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 720
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600"
            if reconcile_body_size_api
              if body_size[n] != "1 x 2"
                body_size[n] = "1 x 2"
              else
              end
            else
            end
          elsif inlet_flange[n] == "900" or inlet_flange[n] == "1500"
            if reconcile_body_size_api
              if body_size[n] != "1 1/2'' x 2"
                body_size[n] = "1 1/2'' x 2"
              else
              end
            else
            end
          elsif inlet_flange[n] == "2500"
            if reconcile_body_size_api
              if body_size[n] != "1 1/2'' x 3"
                body_size[n] = "1 1/2'' x 3"
              else
              end
            else
            end
          else
          end

        else
        end

        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "E"
        if body_size[n] == "1 x 2" or body_size[n] == "1 1/2'' x 2" or body_size[n] == "1 1/2'' x 2 1/2''"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 3600
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3600 and set_pressure[n] <= 4000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 3600
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3600 and set_pressure[n] <= 6000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1480 and set_pressure[n] <= 2220
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2220 and set_pressure[n] <= 3705
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3705 and set_pressure[n] <= 6000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1235
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1235 and set_pressure[n] <= 1845
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1845 and set_pressure[n] <= 3080
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3080 and set_pressure[n] <= 5135
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1015
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1015 and set_pressure[n] <= 1525
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1525 and set_pressure[n] <= 2540
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2540 and set_pressure[n] <= 4230
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1050 and set_pressure[n] <= 1750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1750 and set_pressure[n] <= 2915
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 720
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600"
            if body_size[n] != "1 x 2"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (1 x 2) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              ##msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "1 x 2"
              else
              end
            else
            end
          elsif inlet_flange[n] == "900" or inlet_flange[n] == "1500"
            if body_size[n] != "1 1/2'' x 2"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (1 1/2'' x 2) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "1 1/2'' x 2"
              else
              end
            else
            end
          elsif inlet_flange[n] == "2500"
            if body_size[n] != "1 1/2'' x 3"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (1 1/2'' x 3) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "1 1/2'' x 3"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "F"
        if body_size[n] == "1 x 2" or body_size[n] == "1 1/2'' x 2" or body_size[n] == "1 1/2'' x 2 1/2''"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 2200
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2200 and set_pressure[n] <= 3400
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 3600
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3600 and set_pressure[n] <= 5000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1480 and set_pressure[n] <= 2220
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2220 and set_pressure[n] <= 3705
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3705 and set_pressure[n] <= 5000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1235
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1235 and set_pressure[n] <= 1845
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1845 and set_pressure[n] <= 3080
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3080 and set_pressure[n] <= 5000
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1015
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1015 and set_pressure[n] <= 1525
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1525 and set_pressure[n] <= 2540
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2540 and set_pressure[n] <= 4230
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1050 and set_pressure[n] <= 1750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1750 and set_pressure[n] <= 2915
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 720
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 500
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600"
            if body_size[n] != "1 1/2'' x 2"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (1 1/2'' x 2) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "1 1/2'' x 2"
              else
              end
            else
            end
          elsif inlet_flange[n] == "900" or inlet_flange[n] == "1500" or inlet_flange[n] == "2500"
            if body_size[n] != "1 1/2'' x 3"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (1 1/2'' x 3) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "1 1/2'' x 3"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "G"
        if body_size[n] == "1 1/2'' x 2 1/2''" or body_size[n] == "1 1/2'' x 3" or body_size[n] == "2 x 3"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 2450
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2450 and set_pressure[n] <= 2600
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 3600
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1480 and set_pressure[n] <= 2220
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2220 and set_pressure[n] <= 3705
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1235
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1235 and set_pressure[n] <= 1845
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1845 and set_pressure[n] <= 3080
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 3080 and set_pressure[n] <= 3880
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
              spring_material[n] = "Alloy 20"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1015
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1015 and set_pressure[n] <= 1525
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1525 and set_pressure[n] <= 2540
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2540 and set_pressure[n] <= 3705
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1050 and set_pressure[n] <= 1750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1750 and set_pressure[n] <= 2915
              inlet_flange[n] = "2500"
              outlet_flange[n] = "300"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            elsif inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 720
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Alloy 20"
            if inlet_flange[n] == "2500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 470
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600" or inlet_flange[n] == "900"
            if body_size[n] != "1 1/2'' x 3"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (1 1/2'' x 3) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "1 1/2'' x 3"
              else
              end
            else
            end
          elsif inlet_flange[n] == "1500" or inlet_flange[n] == "2500"
            if body_size[n] != "2 x 3"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (2 x 3) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "2 x 3"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "H"
        if body_size[n] == "1 1/2'' x 3" or body_size[n] == "2 x 3"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 1485
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1485 and set_pressure[n] <= 1600
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 2750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1480 and set_pressure[n] <= 2220
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2220 and set_pressure[n] <= 3000
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
              body_material[n] = "Alloy 20"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1235
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1235 and set_pressure[n] <= 1845
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1845 and set_pressure[n] <= 2750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1015
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1015 and set_pressure[n] <= 1525
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1525 and set_pressure[n] <= 2540
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1050 and set_pressure[n] <= 1750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 415
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 740
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 415
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 415
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Alloy 20"
            if inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 415
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300"
            if body_size[n] != "1 1/2'' x 3"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (1 1/2'' x 3) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "1 1/2'' x 3"
              else
              end
            else
            end
          elsif inlet_flange[n] == "600" or inlet_flange[n] == "900" or inlet_flange[n] == "1500"
            if body_size[n] != "2 x 3"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (2 x 3) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "2 x 3"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "J"
        if body_size[n] == "2 x 3" or body_size[n] == "2 1/2'' x 4" or body_size[n] == "3 x 4"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 500
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 500 and set_pressure[n] <= 625
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 625 and set_pressure[n] <= 800
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 3000
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
              body_material[n] = "Alloy 20"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1480 and set_pressure[n] <= 2220
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2220 and set_pressure[n] <= 3000
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
              body_material[n] = "Alloy 20"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1235
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1235 and set_pressure[n] <= 1845
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1845 and set_pressure[n] <= 2700
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1015
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1015 and set_pressure[n] <= 1525
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1525 and set_pressure[n] <= 2540
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1050 and set_pressure[n] <= 1750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Alloy 20"
            if inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 230
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300"
            if body_size[n] != "2 x 3"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (2 x 3) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "2 x 3"
              else
              end
            else
            end
          elsif inlet_flange[n] == "600" or inlet_flange[n] == "900" or inlet_flange[n] == "1500"
            if body_size[n] != "3 x 4"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (3 x 4) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "3 x 4"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "K"
        if body_size[n] == "3 x 4"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 525
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 525 and set_pressure[n] <= 600
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 600 and set_pressure[n] <= 750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1440
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1440 and set_pressure[n] <= 2160
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 2160 and set_pressure[n] <= 2220
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1480 and set_pressure[n] <= 2220
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1235
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1235 and set_pressure[n] <= 1845
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1845 and set_pressure[n] <= 2200
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 140
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 140 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1015
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1015 and set_pressure[n] <= 1525
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1525 and set_pressure[n] <= 2220
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "300"
            elsif set_pressure[n] > 1050 and set_pressure[n] <= 1750
              inlet_flange[n] = "1500"
              outlet_flange[n] = "300"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Alloy 20"
            if inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 600
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 200
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600"
            if body_size[n] != "3 x 4"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (3 x 4) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "3 x 4"
              else
              end
            else
            end
          elsif inlet_flange[n] == "900" or inlet_flange[n] == "1500"
            if body_size[n] != "3 x 6"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (3 x 6) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "3 x 6"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "L"
        if body_size[n] == "3 x 4" or body_size[n] == "4 x 6"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 535
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 535 and set_pressure[n] <= 700
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1000 and set_pressure[n] <= 1500
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp < 800
            body_material[n] = "Alloy 20"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1200 and maximum_temp <= 300
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1200 and set_pressure[n] <= 1800 and maximum_temp <= 300
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1800 and set_pressure[n] <= 3000 and maximum_temp <= 300
              inlet_flange[n] = "1500"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1000 and maximum_temp <= 800
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 1000 and set_pressure[n] <= 1500 and maximum_temp <= 800
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1000 and set_pressure[n] <= 1500
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1500 and set_pressure[n] <= 2330 and maximum_temp <= 300
              inlet_flange[n] = "1500"
              outlet_flange[n] = "150"
              body_material[n] = "Alloy 20"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1000 and set_pressure[n] <= 1500
              inlet_flange[n] = "1500"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 700 and set_pressure[n] <= 1050
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 140
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Alloy 20"
            if inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 230
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 230
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end

            elsif inlet_flange[n] == "1500"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 230
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 170
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300"
            if body_size[n] != "3 x 4"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (3 x 4) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "3 x 4"
              else
              end
            else
            end
          elsif inlet_flange[n] == "600" or inlet_flange[n] == "900" or inlet_flange[n] == "1500"
            if body_size[n] != "4 x 6"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (4 x 6) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "4 x 6"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "M"
        if body_size[n] == "4 x 6"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 525
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 525 and set_pressure[n] <= 600
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1100
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1100
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 1000 and set_pressure[n] <= 1100
              inlet_flange[n] = "900"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600" or inlet_flange[n] == "900"
            if body_size[n] != "4 x 6"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (4 x 6) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "4 x 6"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "N"
        if body_size[n] == "4 x 6"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 450
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 450 and set_pressure[n] <= 500
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 720
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 720 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 740
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 740 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 615
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 615 and set_pressure[n] <= 1100
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 160
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600" or inlet_flange[n] == "900"
            if body_size[n] != "4 x 6"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (4 x 6) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "4 x 6"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "P"
        if body_size[n] == "4 x 6"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 175
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 175 and set_pressure[n] <= 300
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 300 and set_pressure[n] <= 480
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 275
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 275 and set_pressure[n] <= 525
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 525 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Alloy 20"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 285
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 525
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 525 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 185
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 185 and set_pressure[n] <= 285
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 285 and set_pressure[n] <= 525
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 525 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Chrome Molybdenum Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Austenitic Stainless Steel"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 510
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 510 and set_pressure[n] <= 1000
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 350
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 350 and set_pressure[n] <= 700
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "900"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 285
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 275
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 150
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 140
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 80
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600" or inlet_flange[n] == "900"
            if body_size[n] != "4 x 6"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (4 x 6) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "4 x 6"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "Q"
        if body_size[n] == "6 x 8"
          if minimum_temp >= -450 and minimum_temp <= -76 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 165
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 165 and set_pressure[n] <= 250
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 250 and set_pressure[n] <= 300
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21 and maximum_temp <= 1000
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 165
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 165 and set_pressure[n] <= 300
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 300 and set_pressure[n] <= 600
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100 and maximum_temp <= 800
            body_material[n] = "Nickel/Copper Alloy"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 165
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 165 and set_pressure[n] <= 360 and maximum_temp <= 600
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 360 and set_pressure[n] <= 720 and maximum_temp <= 600
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 165 and set_pressure[n] <= 300 and maximum_temp > 600
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 300 and set_pressure[n] <= 600 and maximum_temp > 600
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450 and maximum_temp <= 800
            body_material[n] = "Nickel/Copper Alloy"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 165
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 165 and set_pressure[n] <= 360 and maximum_temp <= 600
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 360 and set_pressure[n] <= 720 and maximum_temp <= 600
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 165 and set_pressure[n] <= 300 and maximum_temp > 600
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 300 and set_pressure[n] <= 600 and maximum_temp > 600
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Nickel/Copper Alloy"
            if set_pressure[n] <= 140
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 140 and set_pressure[n] <= 360
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 360 and set_pressure[n] <= 720
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 300
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 300 and set_pressure[n] <= 600
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 70
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 70
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 70
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 115
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 115
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300" or inlet_flange[n] == "600" or inlet_flange[n] == "900"
            if body_size[n] != "6 x 8"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (6 x 8) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "6 x 8"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "R"
        if body_size[n] == "6 x 8" or body_size[n] == "6 x 10"
          if minimum_temp >= -450 and minimum_temp <= -76
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 55
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 55 and set_pressure[n] <= 150
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 150 and set_pressure[n] <= 200
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 100
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 100 and set_pressure[n] <= 230
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 230 and set_pressure[n] <= 300
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 100
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 100 and set_pressure[n] <= 230
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 230 and set_pressure[n] <= 300
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 100
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 100 and set_pressure[n] <= 230
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 230 and set_pressure[n] <= 300
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800
            spring_material[n] = "Carbon Steel"
            body_material[n] = "Carbon Steel"
            if set_pressure[n] <= 80
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 80 and set_pressure[n] <= 230
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 230 and set_pressure[n] <= 300
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 230
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 230 and set_pressure[n] <= 300
              inlet_flange[n] = "600"
              outlet_flange[n] = "150"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 60
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 60
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 60
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 60
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 60
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 60
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 60
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 60
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            elsif inlet_flange[n] == "600"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300"
            if body_size[n] != "6 x 8"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (6 x 8) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "6 x 8"
              else
              end
            else
            end
          elsif inlet_flange[n] == "300" or inlet_flange[n] == "600"
            if body_size[n] != "6 x 10"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (6 x 10) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "6 x 10"
              else
              end
            else
            end
          else
          end
        else
        end
        #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      elsif orifice_designation[n] == "T"
        if body_size[n] == "8 x 10"
          if minimum_temp >= -450 and minimum_temp <= -76
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Low Temp Alloy Steel"
            if set_pressure[n] <= 50
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 50 and set_pressure[n] <= 65
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -75 and minimum_temp <= 21
            body_material[n] = "Austenitic Stainless Steel"
            spring_material[n] = "Chrome Alloy Steel"
            if set_pressure[n] <= 65
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 65 and set_pressure[n] <= 120
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= -20 and minimum_temp <= 100
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 65
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 65 and set_pressure[n] <= 300
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 101 and minimum_temp <= 450
            body_material[n] = "Carbon Steel"
            spring_material[n] = "Carbon Steel"
            if set_pressure[n] <= 65
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
              body_material[n] = "Carbon Steel"
            elsif set_pressure[n] > 65 and set_pressure[n] <= 300
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 451 and minimum_temp <= 800
            spring_material[n] = "Carbon Steel"
            body_material[n] = "Carbon Steel"
            if set_pressure[n] <= 65
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 65 and set_pressure[n] <= 300
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
            else
            end
          elsif minimum_temp >= 801 and maximum_temp <= 1000
            spring_material[n] = "High Temp Alloy Steel"
            body_material[n] = "Austenitic Stainless Steel"
            if set_pressure[n] <= 20
              inlet_flange[n] = "150"
              outlet_flange[n] = "150"
            elsif set_pressure[n] > 20 and set_pressure[n] <= 225
              inlet_flange[n] = "300"
              outlet_flange[n] = "150"
              body_material[n] = "Chrome Molybdenum Steel"
            else
            end
          else
          end

          #Determine Mechanical Back Pressure Limit
          if body_material[n] == "Carbon Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 30
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 30
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            else
            end
          elsif body_material[n] == "Chrome Molybdenum Steel"
            if inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 100
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 100
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Austenitic Stainless Steel"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 30
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 30
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 60
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 60
              else
              end
            else
            end
          else
          end

          if body_material[n] == "Nickel/Copper Alloy"
            if inlet_flange[n] == "150"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 30
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 30
              else
              end
            elsif inlet_flange[n] == "300"
              if relief_valve_type[n] == "Conventional"
                mechanical_back_pressure_limit[n] = 60
              elsif relief_valve_type[n] == "Balanced Bellow"
                mechanical_back_pressure_limit[n] = 60
              else
              end
            else
            end
          else
          end

          #Reconcile Body Size Difference From Relief Device Detail Table
          if inlet_flange[n] == "150" or inlet_flange[n] == "300"
            if body_size[n] != "8 x 10"
              #message1 = "The body size basis " & body_size[n] & " selected for relief device " & ReliefDeviceTag[n] & " differs from the body size (8 x 10) recommended in API 526.  Do you want to replace the body size with the recommended body size listed in API 526."
              #msg1 = "Yes"
              if reconcile_body_size_api
                body_size[n] = "8 x 10"
              else
              end
            else
            end
          else
          end
        else
        end

      end

      relied_device = relief_device_sizing.relief_devices[n]
      if body_material[n]!=""
        relied_device.update_attributes(:psvtag => relief_device_tag[n], :bodymatl => body_material[n], :springmatl => spring_material[n], :inletflange => inlet_flange[n], :outletflange => outlet_flange[n])
      end
      mechanical_back_pressure_limit[n] = relief_device_sizing.convert_to_project_unit(:su_pressure, mechanical_back_pressure_limit[n])
      relied_device.update_attributes(:bplimit => mechanical_back_pressure_limit[n], :bodysize => body_size[n])
      relied_device.save
    end

    render :json => {:success => true, :psvtag => relief_device_tag, :bodymatl => body_material, :springmatl => spring_material, :inletflange => inlet_flange, :outletflange => outlet_flange, :bplimit => mechanical_back_pressure_limit, :bodysize => body_size}
  end

  def validate_pressure_relief
    relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    project = relief_device_sizing.project
    relief_devices_count = relief_device_sizing.relief_devices.count
    reconcile_body_size_api = project.pressure_relief_system_design_parameter.pressure_relief_valve_count_reconcile_body_size_api520
    pi = 3.14159265358979

    #Location Validation
    location_diameter = (1..10).to_a
    psv_count = relief_devices_count
    location_count = relief_device_sizing.relief_device_locations.count
    body_size =0

    (0..location_count-1).each do |m|
      sumof_cross_sectional_area = 0
      (0..psv_count-1).each do |k|
        orifice_desig = relief_device_sizing.relief_devices[k]["designation"]
        if relief_device_sizing.relief_device_locations[m]["size"]
          chk_largebody_size = 1
        else
          chk_largebody_size = 0
        end

        if orifice_desig == "D"
          if chk_largebody_size
            body_size = 1.5
          elsif chk_smallbody_size
            body_size = 1
          end
        elsif orifice_desig == "E"
          if chk_largebody_size
            body_size = 1.5
          elsif chk_smallbody_size
            body_size = 1
          end
        elsif orifice_desig == "F"
          if chk_largebody_size
            body_size = 1.5
          elsif chk_smallbody_size
            body_size = 1
          end
        elsif orifice_desig == "G"
          if chk_largebody_size
            body_size = 2
          elsif chk_smallbody_size
            body_size = 1.5
          end
        elsif orifice_desig == "H"
          if chk_largebody_size
            body_size = 2
          elsif chk_smallbody_size
            body_size = 1.5
          end
        elsif orifice_desig == "J"
          if chk_largebody_size
            body_size = 3
          elsif chk_smallbody_size
            body_size = 2
          end
        elsif orifice_desig == "K"
          if chk_largebody_size
            body_size = 3
          elsif chk_smallbody_size
            body_size = 3
          end
        elsif orifice_desig == "L"
          if chk_largebody_size
            body_size = 4
          elsif chk_smallbody_size
            body_size = 3
          end
        elsif orifice_desig == "M"
          if chk_largebody_size
            body_size = 4
          elsif chk_smallbody_size
            body_size = 4
          end
        elsif orifice_desig == "N"
          if chk_largebody_size
            body_size = 4
          elsif chk_smallbody_size
            body_size = 4
          end
        elsif orifice_desig == "P"
          if chk_largebody_size
            body_size = 4
          elsif chk_smallbody_size
            body_size = 4
          end
        elsif orifice_desig == "Q"
          if chk_largebody_size
            body_size = 6
          elsif chk_smallbody_size
            body_size = 6
          end
        elsif orifice_desig == "R"
          if chk_largebody_size
            body_size = 6
          elsif chk_smallbody_size
            body_size = 6
          end
        elsif orifice_desig == "T"
          if chk_largebody_size
            body_size = 8
          elsif chk_smallbody_size
            body_size = 8
          end
        end
        cross_sectional_area = pi * ((body_size / 2) ** 2)
        sumof_cross_sectional_area = sumof_cross_sectional_area + cross_sectional_area
      end
      location_diameter[m] = relief_device_sizing.relief_device_locations[m]["size"]
      if (location_diameter[m]).nil?
        location_diameter[m] = 0
      end
      location_sectional_area = pi * ((location_diameter[m] / 2) ** 2)

      location = relief_device_sizing.relief_device_locations[m]
      if sumof_cross_sectional_area <= location_sectional_area
        location.update_attributes(:acceptability => "Yes")
      else
        location.update_attributes(:acceptability => "No")
      end
      location.save
    end

    #Organize format for Acceptable Location Check

    #Validate the relief device sub-type based on the location of the relief device
    location_phase = ""
    (0..location_count-1).each do |p|
      if relief_device_sizing.relief_device_locations[p]["pressure_relief_valve_location"]
        location_phase = relief_device_sizing.relief_device_locations[p]["contact_fluid_phase"]
      end
    end

    if location_phase == "Vapor"
      location_sub_type = "Safety"
    elsif location_phase == "Liquid"
      location_sub_type = "Relief"
    end

    sub_type = ""
    (0..psv_count-1).each do |q|
      relief_valve_sub_type = relief_device_sizing.relief_devices[q]["subtype"]
      if relief_valve_sub_type != nil
        sub_type = relief_valve_sub_type
      end
    end

    if sub_type == location_sub_type or sub_type == "Safety Relief"
    else
      if reconcile_body_size_api
        (0..psv_count-1).each do |r|
          relief_device = relief_device_sizing.relief_devices[r]
          relief_device.update_attributes(:subtype => "Safety Relief")
        end
      end
    end

    render :json => {:success => true, :sub_type => sub_type}
  end

  def cal_rupture_disk
    relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    scenario_summaries = relief_device_sizing.scenario_summaries
    project = relief_device_sizing.project
    pi = 3.14159265358979
    body_size = (1..10).to_a
    burst_pressure = (1..10).to_a
    estimated_net_flow = (1..10).to_a
    inlet_flange = (1..10).to_a
    outlet_flange = (1..10).to_a

    #Determine Pipe Inner diameter
    max_estimated_net_flow_area = project.pressure_relief_system_design_parameter.rd_estimated_net_flow_area
    #Determine rupture disc count.  Area is based on sch. 40 pipe
    sizbasis_design_scenario = scenario_summaries.where(:applicability => 'Yes').order("required_orifice").order("id").last

    sizing_basis_required_area= sizbasis_design_scenario.required_orifice
    sizing_basis_required_area= relief_device_sizing.convert_to_base_unit(:orifice_area, sizing_basis_required_area)
    sizing_basis_required_area1=sizing_basis_required_area
    max_estimated_net_flow_area = relief_device_sizing.convert_to_base_unit(:orifice_area, max_estimated_net_flow_area)

    rd_count=relief_device_sizing.relief_device_rupture_disks.count
    (0..rd_count-1).each do |k|
      if sizing_basis_required_area < max_estimated_net_flow_area
        if sizing_basis_required_area > 0 and sizing_basis_required_area <= 0.104
          body_size[k] = "1/4''"
          estimated_net_flow[k] = 0.104
        elsif sizing_basis_required_area < 0.104 and sizing_basis_required_area <= 0.304
          body_size[k] = "1/2''"
          estimated_net_flow[k] = 0.304
        elsif sizing_basis_required_area > 0.304 and sizing_basis_required_area <= 0.533
          body_size[k] = "3/4''"
          estimated_net_flow[k] = 0.533
        elsif sizing_basis_required_area > 0.533 and sizing_basis_required_area <= 0.864
          body_size[k] = 1
          estimated_net_flow[k] = 0.864
        elsif sizing_basis_required_area > 0.864 and sizing_basis_required_area <= 1.496
          body_size[k] = "1 1/4''"
          estimated_net_flow[k] = 1.496
        elsif sizing_basis_required_area > 1.496 and sizing_basis_required_area <= 2.036
          body_size[k] = "1 1/2''"
          estimated_net_flow[k] = 2.036
        elsif sizing_basis_required_area > 2.036 and sizing_basis_required_area <= 3.356
          body_size[k] = 2
          estimated_net_flow[k] = 3.356
        elsif sizing_basis_required_area > 3.356 and sizing_basis_required_area <= 4.788
          body_size[k] = "2 1/2''"
          estimated_net_flow[k] = 4.788
        elsif sizing_basis_required_area > 4.788 and sizing_basis_required_area <= 7.393
          body_size[k] = 3
          estimated_net_flow[k] = 7.393
        elsif sizing_basis_required_area > 7.393 and sizing_basis_required_area <= 9.887
          body_size[k] = "3 1/2''"
          estimated_net_flow[k] = 9.887
        elsif sizing_basis_required_area > 9.887 and sizing_basis_required_area <= 12.73
          body_size[k] = 4
          estimated_net_flow[k] = 12.73
        elsif sizing_basis_required_area > 12.73 and sizing_basis_required_area <= 20.006
          body_size[k] = 5
          estimated_net_flow[k] = 20.006
        elsif sizing_basis_required_area > 20.006 and sizing_basis_required_area <= 28.89
          body_size[k] = 6
          estimated_net_flow[k] = 28.89
        elsif sizing_basis_required_area > 28.89 and sizing_basis_required_area <= 50.027
          body_size[k] = 8
          estimated_net_flow[k] = 50.027
        elsif sizing_basis_required_area > 50.027 and sizing_basis_required_area <= 78.854
          body_size[k] = 10
          estimated_net_flow[k] = 78.854
        elsif sizing_basis_required_area > 78.854 and sizing_basis_required_area <= 113.097
          body_size[k] = 12
          estimated_net_flow[k] = 113.097
        elsif sizing_basis_required_area > 113.097 and sizing_basis_required_area <= 137.886
          body_size[k] = 14
          estimated_net_flow[k] = 137.886
        elsif sizing_basis_required_area > 137.886 and sizing_basis_required_area <= 182.654
          body_size[k] = 16
          estimated_net_flow[k] = 182.654
        elsif sizing_basis_required_area > 182.654 and sizing_basis_required_area <= 233.705
          body_size[k] = 18
          estimated_net_flow[k] = 233.705
        elsif sizing_basis_required_area > 233.705 and sizing_basis_required_area <= 291.039
          body_size[k] = 20
          estimated_net_flow[k] = 291.039
        elsif sizing_basis_required_area > 291.039 and sizing_basis_required_area <= 363.05
          body_size[k] = 22
          estimated_net_flow[k] = 363.05
        elsif sizing_basis_required_area > 363.05 and sizing_basis_required_area <= 424.557
          body_size[k] = 24
          estimated_net_flow[k] = 424.557
        elsif sizing_basis_required_area > 424.557 and sizing_basis_required_area <= 500.74
          body_size[k] = 26
          estimated_net_flow[k] = 500.74
        elsif sizing_basis_required_area > 500.74 and sizing_basis_required_area <= 583.207
          body_size[k] = 28
          estimated_net_flow[k] = 583.207
        elsif sizing_basis_required_area > 583.207 and sizing_basis_required_area <= 671.957
          body_size[k] = 30
          estimated_net_flow[k] = 671.957
        elsif sizing_basis_required_area > 671.957 and sizing_basis_required_area <= 766.99
          body_size[k] = 32
          estimated_net_flow[k] = 766.99
        elsif sizing_basis_required_area > 766.99 and sizing_basis_required_area <= 868.307
          body_size[k] = 34
          estimated_net_flow[k] = 868.307
        elsif sizing_basis_required_area > 868.307 and sizing_basis_required_area <= 975.906
          body_size[k] = 36
          estimated_net_flow[k] = 975.906
        end
        #save
        rupture_disk = relief_device_sizing.relief_device_rupture_disks[k]
        rupture_disk.update_attributes(:bodysize => body_size[k])
        rupture_disk.save
        estimated_net_flow[k] = relief_device_sizing.convert_to_project_unit(:orifice_area, estimated_net_flow[k])
        k=rd_count
      elsif sizing_basis_required_area >= max_estimated_net_flow_area
        estimated_net_flow[k] = max_estimated_net_flow_area
        body_size[k] = project.pressure_relief_system_design_parameter.rupture_disk_selection_basis_rd_size
        #save
        rupture_disk = relief_device_sizing.relief_device_rupture_disks[k]
        rupture_disk.update_attributes(:bodysize => body_size[k])
        rupture_disk.save
        estimated_net_flow[k] = relief_device_sizing.convert_to_project_unit(:orifice_area, estimated_net_flow[k])
        left_over_area = sizing_basis_required_area1 - (max_estimated_net_flow_area * k)
        sizing_basis_required_area = left_over_area
        rd_count = rd_count + 1
      end
    end

    #skip Determine Minimum & Maximum Temperature
    # find by the max Relief temperature
    maximum_temp = relief_device_sizing.scenario_identifications.where(:applicability => 'Yes').maximum("rc_temperature")
    minimum_temp = relief_device_sizing.scenario_identifications.where(:applicability => 'Yes').minimum("dc_temperature")
    #Determine Flange Rating based on maximum temperature
    (0..rd_count-1).each do |n|
      burst_pressure[n]= relief_device_sizing.relief_device_rupture_disks[n]["burstpressure"]
      burst_pressure[n]= relief_device_sizing.convert_to_base_unit(:su_pressure, burst_pressure[n])
      maximum_temp = relief_device_sizing.convert_to_base_unit(:su_temperature, maximum_temp)
      minimum_temp = relief_device_sizing.convert_to_base_unit(:su_temperature, minimum_temp)
      kr_max_resistance=project.pressure_relief_system_design_parameter.rdbp_maximum_flow_resistance
      non_fragmented_design = "Yes"

      if maximum_temp >= -20 and maximum_temp <= 100
        if burst_pressure[n] <= 285
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 285 and burst_pressure[n] <= 740
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 740 and burst_pressure[n] <= 985
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 985 and burst_pressure[n] <= 1480
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1480 and burst_pressure[n] <= 2220
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 2220 and burst_pressure[n] <= 3705
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3705 and burst_pressure[n] <= 6170
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp > 100 and maximum_temp <= 200
        if burst_pressure[n] <= 260
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 260 and burst_pressure[n] <= 680
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 680 and burst_pressure[n] <= 905
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 905 and burst_pressure[n] <= 1360
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1360 and burst_pressure[n] <= 2035
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 2035 and burst_pressure[n] <= 3395
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3395 and burst_pressure[n] <= 5655
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 200 and maximum_temp <= 300
        if burst_pressure[n] <= 230
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 230 and burst_pressure[n] <= 655
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 655 and burst_pressure[n] <= 870
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 870 and burst_pressure[n] <= 1310
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1310 and burst_pressure[n] <= 1965
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1965 and burst_pressure[n] <= 3270
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3270 and burst_pressure[n] <= 5450
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 300 and maximum_temp <= 400
        if burst_pressure[n] <= 200
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 200 and burst_pressure[n] <= 635
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 635 and burst_pressure[n] <= 845
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 845 and burst_pressure[n] <= 1265
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1265 and burst_pressure[n] <= 1900
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1900 and burst_pressure[n] <= 3170
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3170 and burst_pressure[n] <= 5280
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 400 and maximum_temp <= 500
        if burst_pressure[n] <= 170
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 170 and burst_pressure[n] <= 605
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 605 and burst_pressure[n] <= 805
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 805 and burst_pressure[n] <= 1205
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1205 and burst_pressure[n] <= 1810
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1810 and burst_pressure[n] <= 3015
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3015 and burst_pressure[n] <= 5025
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 500 and maximum_temp <= 600
        if burst_pressure[n] <= 140
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 140 and burst_pressure[n] <= 570
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 570 and burst_pressure[n] <= 755
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 755 and burst_pressure[n] <= 1135
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1135 and burst_pressure[n] <= 1750
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1750 and burst_pressure[n] <= 2840
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2840 and burst_pressure[n] <= 4730
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 600 and maximum_temp <= 650
        if burst_pressure[n] <= 140
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 140 and burst_pressure[n] <= 570
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 570 and burst_pressure[n] <= 755
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 755 and burst_pressure[n] <= 1135
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1135 and burst_pressure[n] <= 1750
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1750 and burst_pressure[n] <= 2840
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2840 and burst_pressure[n] <= 4730
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 650 and maximum_temp <= 700
        if burst_pressure[n] <= 110
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 110 and burst_pressure[n] <= 530
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 530 and burst_pressure[n] <= 710
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 710 and burst_pressure[n] <= 1060
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1060 and burst_pressure[n] <= 1590
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1590 and burst_pressure[n] <= 2655
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2655 and burst_pressure[n] <= 4425
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 700 and maximum_temp <= 750
        if burst_pressure[n] <= 95
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 95 and burst_pressure[n] <= 505
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 505 and burst_pressure[n] <= 675
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 675 and burst_pressure[n] <= 1015
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1015 and burst_pressure[n] <= 1520
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1520 and burst_pressure[n] <= 2535
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2535 and burst_pressure[n] <= 4230
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 750 and maximum_temp <= 800
        if burst_pressure[n] <= 80
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 80 and burst_pressure[n] <= 410
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 410 and burst_pressure[n] <= 550
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 550 and burst_pressure[n] <= 825
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 825 and burst_pressure[n] <= 1235
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1235 and burst_pressure[n] <= 2055
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2055 and burst_pressure[n] <= 3430
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 800 and maximum_temp <= 850
        if burst_pressure[n] <= 65
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 65 and burst_pressure[n] <= 320
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 320 and burst_pressure[n] <= 425
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 425 and burst_pressure[n] <= 640
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 640 and burst_pressure[n] <= 955
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 955 and burst_pressure[n] <= 1595
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 1595 and burst_pressure[n] <= 2655
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 850 and maximum_temp <= 900
        if burst_pressure[n] <= 50
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 50 and burst_pressure[n] <= 230
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 230 and burst_pressure[n] <= 305
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 305 and burst_pressure[n] <= 460
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 460 and burst_pressure[n] <= 690
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 690 and burst_pressure[n] <= 1150
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 1150 and burst_pressure[n] <= 1915
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 900 and maximum_temp <= 950
        if burst_pressure[n] <= 35
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 35 and burst_pressure[n] <= 135
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 135 and burst_pressure[n] <= 185
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 185 and burst_pressure[n] <= 275
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 275 and burst_pressure[n] <= 410
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 410 and burst_pressure[n] <= 685
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 685 and burst_pressure[n] <= 1145
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp
        if burst_pressure[n] <= 20
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 20 and burst_pressure[n] <= 85
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 85 and burst_pressure[n] <= 115
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 115 and burst_pressure[n] <= 170
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 170 and burst_pressure[n] <= 255
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 255 and burst_pressure[n] <= 430
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 430 and burst_pressure[n] <= 715
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        end
      end
      rupture_disk = relief_device_sizing.relief_device_rupture_disks[n]
      rupture_disk.update_attributes(:inletflange => inlet_flange[n], :outletflange => outlet_flange[n], :burstpressure => burst_pressure[n], :kr => kr_max_resistance, :nonfdesign => non_fragmented_design)
      rupture_disk.save
    end

    render :json => {:success => true, :inletflange => inlet_flange, :outletflange => outlet_flange, :burstpressure => burst_pressure}
  end

  def validate_rupture_disk
    relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    scenario_summaries = relief_device_sizing.scenario_summaries
    project = relief_device_sizing.project
    pi = 3.14159265358979
    location_diameter = (1..10).to_a
    cross_sectional_area = (1..10).to_a
    rd_count=relief_device_sizing.relief_device_rupture_disks.count
    location_count = relief_device_sizing.relief_device_rupture_locations.count

    sumof_cross_sectional_area = 0
    (0..rd_count-1).each do |k|
      diameter = relief_device_sizing.relief_device_rupture_locations[k]["bodysize"]
      if diameter == "1/4''"
        diameter = 0.25
      elsif diameter == "1/2''"
        diameter = 0.5
      elsif diameter == "3/4 ''"
        diameter = 0.75
      elsif diameter == "1 1/4''"
        diameter = 1.25
      elsif diameter == "1 1/2''"
        diameter = 1.5
      elsif diameter == "2 1/2''"
        diameter = 2.5
      elsif diameter == "3 1/2''"
        diameter = 3.5
      end

      diameter = 0 if diameter.nil?
      cross_sectional_area[k] = pi * ((diameter / 2) ** 2)
      sumof_cross_sectional_area = sumof_cross_sectional_area + cross_sectional_area[k]
    end


    (0..location_count-1).each do |m|
      location_diameter[m] = relief_device_sizing.relief_device_rupture_locations[m]["size"]
      if location_diameter[m] == "1/4''"
        location_diameter[m] = 0.25
      elsif location_diameter[m] == "1/2''"
        location_diameter[m] = 0.5
      elsif location_diameter[m] == "3/4 ''"
        location_diameter[m] = 0.75
      elsif location_diameter[m] == "1 1/4''"
        location_diameter[m] = 1.25
      elsif location_diameter[m] == "1 1/2''"
        location_diameter[m] = 1.5
      elsif location_diameter[m] == "2 1/2''"
        location_diameter[m] = 2.5
      elsif location_diameter[m] == "3 1/2''"
        location_diameter[m] = 3.5
      end
      location_diameter[m] = location_diameter[m] + 0
      location_sectional_area = pi * ((location_diameter[m] / 2) ** 2)

      location = relief_device_sizing.relief_device_rupture_locations[m]
      if sumof_cross_sectional_area <= location_sectional_area
        location.update_attributes(:acceptability => "Yes")
      else
        location.update_attributes(:acceptability => "No", :rupture_disk_location => false)
      end
      location.save
    end

    #Organize format for Acceptable Location Check ## added in above 4 line

    render :json => {:success => true}
  end

  def cal_open_vent_disk
    relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    scenario_summaries = relief_device_sizing.scenario_summaries
    project = relief_device_sizing.project
    pi = 3.14159265358979
    body_size = (1..10).to_a
    burst_pressure = (1..10).to_a
    estimated_net_flow = (1..10).to_a
    inlet_flange = (1..10).to_a
    outlet_flange = (1..10).to_a
    #Determine Pipe Inner diameter
    max_estimated_net_flow_area = project.pressure_relief_system_design_parameter.rd_estimated_net_flow_area
    #Determine rupture disc count.  Area is based on sch. 40 pipe
    sizbasis_design_scenario = scenario_summaries.where(:applicability => 'Yes').order("required_orifice").order("id").last

    sizing_basis_required_area= sizbasis_design_scenario.required_orifice
    sizing_basis_required_area= relief_device_sizing.convert_to_base_unit(:orifice_area, sizing_basis_required_area)
    sizing_basis_required_area1=sizing_basis_required_area
    max_estimated_net_flow_area = relief_device_sizing.convert_to_base_unit(:orifice_area, max_estimated_net_flow_area)

    op_count=relief_device_sizing.relief_device_open_vent_relief_devices.count
    (0..op_count-1).each do |k|
      if sizing_basis_required_area < max_estimated_net_flow_area
        if sizing_basis_required_area > 0 and sizing_basis_required_area <= 0.104
          body_size[k] = "1/4''"
          estimated_net_flow[k] = 0.104
        elsif sizing_basis_required_area < 0.104 and sizing_basis_required_area <= 0.304
          body_size[k] = "1/2''"
          estimated_net_flow[k] = 0.304
        elsif sizing_basis_required_area > 0.304 and sizing_basis_required_area <= 0.533
          body_size[k] = "3/4''"
          estimated_net_flow[k] = 0.533
        elsif sizing_basis_required_area > 0.533 and sizing_basis_required_area <= 0.864
          body_size[k] = 1
          estimated_net_flow[k] = 0.864
        elsif sizing_basis_required_area > 0.864 and sizing_basis_required_area <= 1.496
          body_size[k] = "1 1/4''"
          estimated_net_flow[k] = 1.496
        elsif sizing_basis_required_area > 1.496 and sizing_basis_required_area <= 2.036
          body_size[k] = "1 1/2''"
          estimated_net_flow[k] = 2.036
        elsif sizing_basis_required_area > 2.036 and sizing_basis_required_area <= 3.356
          body_size[k] = 2
          estimated_net_flow[k] = 3.356
        elsif sizing_basis_required_area > 3.356 and sizing_basis_required_area <= 4.788
          body_size[k] = "2 1/2''"
          estimated_net_flow[k] = 4.788
        elsif sizing_basis_required_area > 4.788 and sizing_basis_required_area <= 7.393
          body_size[k] = 3
          estimated_net_flow[k] = 7.393
        elsif sizing_basis_required_area > 7.393 and sizing_basis_required_area <= 9.887
          body_size[k] = "3 1/2''"
          estimated_net_flow[k] = 9.887
        elsif sizing_basis_required_area > 9.887 and sizing_basis_required_area <= 12.73
          body_size[k] = 4
          estimated_net_flow[k] = 12.73
        elsif sizing_basis_required_area > 12.73 and sizing_basis_required_area <= 20.006
          body_size[k] = 5
          estimated_net_flow[k] = 20.006
        elsif sizing_basis_required_area > 20.006 and sizing_basis_required_area <= 28.89
          body_size[k] = 6
          estimated_net_flow[k] = 28.89
        elsif sizing_basis_required_area > 28.89 and sizing_basis_required_area <= 50.027
          body_size[k] = 8
          estimated_net_flow[k] = 50.027
        elsif sizing_basis_required_area > 50.027 and sizing_basis_required_area <= 78.854
          body_size[k] = 10
          estimated_net_flow[k] = 78.854
        elsif sizing_basis_required_area > 78.854 and sizing_basis_required_area <= 113.097
          body_size[k] = 12
          estimated_net_flow[k] = 113.097
        elsif sizing_basis_required_area > 113.097 and sizing_basis_required_area <= 137.886
          body_size[k] = 14
          estimated_net_flow[k] = 137.886
        elsif sizing_basis_required_area > 137.886 and sizing_basis_required_area <= 182.654
          body_size[k] = 16
          estimated_net_flow[k] = 182.654
        elsif sizing_basis_required_area > 182.654 and sizing_basis_required_area <= 233.705
          body_size[k] = 18
          estimated_net_flow[k] = 233.705
        elsif sizing_basis_required_area > 233.705 and sizing_basis_required_area <= 291.039
          body_size[k] = 20
          estimated_net_flow[k] = 291.039
        elsif sizing_basis_required_area > 291.039 and sizing_basis_required_area <= 363.05
          body_size[k] = 22
          estimated_net_flow[k] = 363.05
        elsif sizing_basis_required_area > 363.05 and sizing_basis_required_area <= 424.557
          body_size[k] = 24
          estimated_net_flow[k] = 424.557
        elsif sizing_basis_required_area > 424.557 and sizing_basis_required_area <= 500.74
          body_size[k] = 26
          estimated_net_flow[k] = 500.74
        elsif sizing_basis_required_area > 500.74 and sizing_basis_required_area <= 583.207
          body_size[k] = 28
          estimated_net_flow[k] = 583.207
        elsif sizing_basis_required_area > 583.207 and sizing_basis_required_area <= 671.957
          body_size[k] = 30
          estimated_net_flow[k] = 671.957
        elsif sizing_basis_required_area > 671.957 and sizing_basis_required_area <= 766.99
          body_size[k] = 32
          estimated_net_flow[k] = 766.99
        elsif sizing_basis_required_area > 766.99 and sizing_basis_required_area <= 868.307
          body_size[k] = 34
          estimated_net_flow[k] = 868.307
        elsif sizing_basis_required_area > 868.307 and sizing_basis_required_area <= 975.906
          body_size[k] = 36
          estimated_net_flow[k] = 975.906
        end
        #save
        open_vent = relief_device_sizing.relief_device_open_vent_relief_devices[k]
        open_vent.update_attributes(:bodysize => body_size[k], :pipesch => "STD Sch.")
        open_vent.save
        estimated_net_flow[k] = relief_device_sizing.convert_to_project_unit(:orifice_area, estimated_net_flow[k])
        k=op_count
      elsif sizing_basis_required_area >= max_estimated_net_flow_area
        estimated_net_flow[k] = max_estimated_net_flow_area
        body_size[k] = project.pressure_relief_system_design_parameter.vent_line_selection_basis_rd_size
        #save
        open_vent = relief_device_sizing.relief_device_open_vent_relief_devices[k]
        open_vent.update_attributes(:bodysize => body_size[k], :pipesch => "STD Sch.")
        open_vent.save
        estimated_net_flow[k] = relief_device_sizing.convert_to_project_unit(:orifice_area, estimated_net_flow[k])
        left_over_area = sizing_basis_required_area1 - (max_estimated_net_flow_area * k)
        sizing_basis_required_area = left_over_area
        op_count = op_count + 1
      end
    end

    #skip Determine Minimum & Maximum Temperature
    # find by the max Relief temperature
    maximum_temp = relief_device_sizing.scenario_identifications.where(:applicability => 'Yes').maximum("rc_temperature")
    minimum_temp = relief_device_sizing.scenario_identifications.where(:applicability => 'Yes').minimum("dc_temperature")
    #Determine Flange Rating based on maximum temperature
    (0..op_count-1).each do |n|
      burst_pressure[n]= relief_device_sizing.relief_device_open_vent_relief_devices[n]["burstpressure"]
      burst_pressure[n]= relief_device_sizing.convert_to_base_unit(:su_pressure, burst_pressure[n])
      maximum_temp = relief_device_sizing.convert_to_base_unit(:su_temperature, maximum_temp)
      minimum_temp = relief_device_sizing.convert_to_base_unit(:su_temperature, minimum_temp)

      if maximum_temp >= -20 and maximum_temp <= 100
        if burst_pressure[n] <= 285
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 285 and burst_pressure[n] <= 740
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 740 and burst_pressure[n] <= 985
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 985 and burst_pressure[n] <= 1480
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1480 and burst_pressure[n] <= 2220
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 2220 and burst_pressure[n] <= 3705
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3705 and burst_pressure[n] <= 6170
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp > 100 and maximum_temp <= 200
        if burst_pressure[n] <= 260
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 260 and burst_pressure[n] <= 680
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 680 and burst_pressure[n] <= 905
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 905 and burst_pressure[n] <= 1360
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1360 and burst_pressure[n] <= 2035
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 2035 and burst_pressure[n] <= 3395
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3395 and burst_pressure[n] <= 5655
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 200 and maximum_temp <= 300
        if burst_pressure[n] <= 230
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 230 and burst_pressure[n] <= 655
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 655 and burst_pressure[n] <= 870
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 870 and burst_pressure[n] <= 1310
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1310 and burst_pressure[n] <= 1965
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1965 and burst_pressure[n] <= 3270
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3270 and burst_pressure[n] <= 5450
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 300 and maximum_temp <= 400
        if burst_pressure[n] <= 200
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 200 and burst_pressure[n] <= 635
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 635 and burst_pressure[n] <= 845
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 845 and burst_pressure[n] <= 1265
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1265 and burst_pressure[n] <= 1900
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1900 and burst_pressure[n] <= 3170
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3170 and burst_pressure[n] <= 5280
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 400 and maximum_temp <= 500
        if burst_pressure[n] <= 170
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 170 and burst_pressure[n] <= 605
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 605 and burst_pressure[n] <= 805
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 805 and burst_pressure[n] <= 1205
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1205 and burst_pressure[n] <= 1810
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1810 and burst_pressure[n] <= 3015
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 3015 and burst_pressure[n] <= 5025
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 500 and maximum_temp <= 600
        if burst_pressure[n] <= 140
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 140 and burst_pressure[n] <= 570
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 570 and burst_pressure[n] <= 755
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 755 and burst_pressure[n] <= 1135
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1135 and burst_pressure[n] <= 1750
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1750 and burst_pressure[n] <= 2840
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2840 and burst_pressure[n] <= 4730
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 600 and maximum_temp <= 650
        if burst_pressure[n] <= 140
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 140 and burst_pressure[n] <= 570
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 570 and burst_pressure[n] <= 755
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 755 and burst_pressure[n] <= 1135
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1135 and burst_pressure[n] <= 1750
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1750 and burst_pressure[n] <= 2840
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2840 and burst_pressure[n] <= 4730
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 650 and maximum_temp <= 700
        if burst_pressure[n] <= 110
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 110 and burst_pressure[n] <= 530
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 530 and burst_pressure[n] <= 710
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 710 and burst_pressure[n] <= 1060
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1060 and burst_pressure[n] <= 1590
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1590 and burst_pressure[n] <= 2655
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2655 and burst_pressure[n] <= 4425
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 700 and maximum_temp <= 750
        if burst_pressure[n] <= 95
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 95 and burst_pressure[n] <= 505
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 505 and burst_pressure[n] <= 675
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 675 and burst_pressure[n] <= 1015
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 1015 and burst_pressure[n] <= 1520
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1520 and burst_pressure[n] <= 2535
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2535 and burst_pressure[n] <= 4230
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 750 and maximum_temp <= 800
        if burst_pressure[n] <= 80
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 80 and burst_pressure[n] <= 410
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 410 and burst_pressure[n] <= 550
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 550 and burst_pressure[n] <= 825
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 825 and burst_pressure[n] <= 1235
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 1235 and burst_pressure[n] <= 2055
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 2055 and burst_pressure[n] <= 3430
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 800 and maximum_temp <= 850
        if burst_pressure[n] <= 65
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 65 and burst_pressure[n] <= 320
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 320 and burst_pressure[n] <= 425
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 425 and burst_pressure[n] <= 640
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 640 and burst_pressure[n] <= 955
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 955 and burst_pressure[n] <= 1595
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 1595 and burst_pressure[n] <= 2655
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 850 and maximum_temp <= 900
        if burst_pressure[n] <= 50
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 50 and burst_pressure[n] <= 230
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 230 and burst_pressure[n] <= 305
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 305 and burst_pressure[n] <= 460
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 460 and burst_pressure[n] <= 690
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 690 and burst_pressure[n] <= 1150
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 1150 and burst_pressure[n] <= 1915
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp >= 900 and maximum_temp <= 950
        if burst_pressure[n] <= 35
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 35 and burst_pressure[n] <= 135
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 135 and burst_pressure[n] <= 185
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 185 and burst_pressure[n] <= 275
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 275 and burst_pressure[n] <= 410
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 410 and burst_pressure[n] <= 685
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 685 and burst_pressure[n] <= 1145
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        else
        end
      elsif maximum_temp
        if burst_pressure[n] <= 20
          inlet_flange[n] = "150"
          outlet_flange[n] = "150"
        elsif burst_pressure[n] > 20 and burst_pressure[n] <= 85
          inlet_flange[n] = "300"
          outlet_flange[n] = "300"
        elsif burst_pressure[n] > 85 and burst_pressure[n] <= 115
          inlet_flange[n] = "400"
          outlet_flange[n] = "400"
        elsif burst_pressure[n] > 115 and burst_pressure[n] <= 170
          inlet_flange[n] = "600"
          outlet_flange[n] = "600"
        elsif burst_pressure[n] > 170 and burst_pressure[n] <= 255
          inlet_flange[n] = "900"
          outlet_flange[n] = "900"
        elsif burst_pressure[n] > 255 and burst_pressure[n] <= 430
          inlet_flange[n] = "1500"
          outlet_flange[n] = "1500"
        elsif burst_pressure[n] > 430 and burst_pressure[n] <= 715
          inlet_flange[n] = "2500"
          outlet_flange[n] = "2500"
        end
      end
      open_vent = relief_device_sizing.relief_device_open_vent_relief_devices[n]
      open_vent.update_attributes(:inletflange => inlet_flange[n], :outletflange => outlet_flange[n])
      open_vent.save
    end


    render :json => {:success => true}
  end

  def validate_open_vent
    relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    scenario_summaries = relief_device_sizing.scenario_summaries
    project = relief_device_sizing.project
    pi = 3.14159265358979
    location_diameter = (1..10).to_a
    cross_sectional_area = (1..10).to_a
    op_count=relief_device_sizing.relief_device_open_vent_relief_devices.count
    location_count = relief_device_sizing.relief_device_open_vent_locations.count

    sumof_cross_sectional_area = 0
    (0..op_count-1).each do |k|
      diameter = relief_device_sizing.relief_device_open_vent_relief_devices[k]["bodysize"]
      if diameter == "1/4''"
        diameter = 0.25
      elsif diameter == "1/2''"
        diameter = 0.5
      elsif diameter == "3/4 ''"
        diameter = 0.75
      elsif diameter == "1 1/4''"
        diameter = 1.25
      elsif diameter == "1 1/2''"
        diameter = 1.5
      elsif diameter == "2 1/2''"
        diameter = 2.5
      elsif diameter == "3 1/2''"
        diameter = 3.5
      end

      diameter = 0 if diameter.nil?
      cross_sectional_area[k] = pi * ((diameter / 2) ** 2)
      sumof_cross_sectional_area = sumof_cross_sectional_area + cross_sectional_area[k]
    end


    (0..location_count-1).each do |m|
      location_diameter[m] = relief_device_sizing.relief_device_rupture_locations[m]["size"]
      if location_diameter[m] == "1/4''"
        location_diameter[m] = 0.25
      elsif location_diameter[m] == "1/2''"
        location_diameter[m] = 0.5
      elsif location_diameter[m] == "3/4 ''"
        location_diameter[m] = 0.75
      elsif location_diameter[m] == "1 1/4''"
        location_diameter[m] = 1.25
      elsif location_diameter[m] == "1 1/2''"
        location_diameter[m] = 1.5
      elsif location_diameter[m] == "2 1/2''"
        location_diameter[m] = 2.5
      elsif location_diameter[m] == "3 1/2''"
        location_diameter[m] = 3.5
      end
      location_diameter[m] = location_diameter[m] + 0
      location_sectional_area = pi * ((location_diameter[m] / 2) ** 2)

      location = relief_device_sizing.relief_device_rupture_locations[m]
      if sumof_cross_sectional_area <= location_sectional_area
        location.update_attributes(:acceptability => "Yes")
      else
        location.update_attributes(:acceptability => "No", :open_vent_location => false)
      end
      location.save
    end

    #Organize format for Acceptable Location Check ## added in above 4 line

    render :json => {:success => true}

  end

  def select_low_pressure_vent
    relief_device_sizing = ReliefDeviceSizing.find(params[:id])
    project = relief_device_sizing.project
    # Tank Code Change
    if relief_device_sizing["low_pressure_tank_code"] == "API 620"
      chk_api650_frangible_roof = "No"
    else
      chk_api650_frangible_roof = "Yes"
    end
    pressure_rating = relief_device_sizing["low_pressure_pressure_rating"]
    vacuum_rating = relief_device_sizing["low_pressure_vacuum_rating"]
    if relief_device_sizing["low_pressure_tank_code"] == "API 620"
      pressure_setting = pressure_rating
      vacuum_setting = vacuum_rating
    else
      pressure_setting = pressure_rating * 0.5
      vacuum_setting = vacuum_rating * 0.5
    end
    leak_point = pressure_setting * 0.75
    relief_device_sizing.update_attributes(:low_pressure_frangibleroof => chk_api650_frangible_roof, :low_pressure_set_pressure => pressure_setting, :low_pressure_set_vacuum => vacuum_setting, :low_pressure_leak_point => leak_point)
    relief_device_sizing.save

    # Flash point code
    flash_point_temp = relief_device_sizing["low_pressure_flashpoint_temp"]
    flash_point_temp = relief_device_sizing.convert_to_base_unit(:su_temperature, flash_point_temp)
    if flash_point_temp >= 100
      low_pressure_flashpoint = "Yes"
    else
      low_pressure_flashpoint = "No"
    end
    relief_device_sizing.update_attributes(:low_pressure_flashpoint => low_pressure_flashpoint)
    relief_device_sizing.save

    #Emission regulation change
    emission_regulation = relief_device_sizing["low_pressure_emissionstandards"]
    if emission_regulation == "Strict"
      low_pressure_dischargelocation = "Pipe Away"
    else
      low_pressure_dischargelocation = "Atmosphere"
    end
    relief_device_sizing.update_attributes(:low_pressure_dischargelocation => low_pressure_dischargelocation)
    relief_device_sizing.save

    #select Button click
    fluid_temperature = relief_device_sizing["low_pressure_fluid_temp"]
    tank_capacity = relief_device_sizing["low_pressure_tankcapacity"]
    fluid_temperature = relief_device_sizing.convert_to_base_unit(:su_temperature, fluid_temperature)
    tank_capacity = relief_device_sizing.convert_to_base_unit(:orifice_area, tank_capacity)
    flash_point_greater_than_100 = low_pressure_flashpoint
    comparison_volume = 2500
    comparison_volume1 = 126000
    comparison_temp = 100
    comparison_volume = relief_device_sizing.convert_to_project_unit(:orifice_area, comparison_volume)
    comparison_volume1 = relief_device_sizing.convert_to_project_unit(:orifice_area, comparison_volume1)
    comparison_temp = relief_device_sizing.convert_to_project_unit(:su_temperature, comparison_temp)

    count_open_vent_not_acceptable = 0
    count_flame_arrester_needed_for_open_vent = 0
    count_flame_arrester_needed_for_pvto_pipe_away = 0
    count_open_vent_without_flame_arrester = 0
    msg=""

    if flash_point_greater_than_100 == "No" and fluid_temperature > flash_point_temp
      msg = "The stored fluid has a flash point temperature less than ComparisonTemp ComparisonTempUnit and the normal storage temperature in excess of the flash point temperature.  Per API 2000 sec. 4.4.1.2 (5th Edition, April 2008) and API 2000 sec. 4.4.1.3 (5th Edition, April 2008), either a pressure-vacuum vent or an open vent (with flame arrester) may be used for normal venting on storage tanks in such service. Note that a flame arrester is not considered necessary for use in conjuction with a pressure-vacuum vent relieving to atmosphere because flame speeds are less than vapor velocities across the seat of pressure-vacuum vent."
      count_flame_arrester_needed_for_open_vent += 1
      count_flame_arrester_needed_for_pvto_pipe_away += 1
    end

    if flash_point_greater_than_100 == "Yes" and fluid_temperature < flash_point_temp
      msg = "he stored fluid has a flash point temperature greater than ComparisonTemp ComparisonTempUnit and the normal storage temperature below the flash point temperature.  Per API 2000 sec. 4.4.1.4 (5th Edition, April 2008), an open vent without a flame arrester may be used."
      count_open_vent_without_flame_arrester += 1
    end

    if relief_device_sizing["low_pressure_heatedtank"] == "Yes" and fluid_temperature < flash_point_temp
      msg= "The stored fluid has a flash point temperature greater than the normal storage temperature with no expected abnormal heat input.  Per API 2000 sec. 4.4.1.4 (5th Edition, April 2008), an open vent without a flame arrester may be used."
      count_open_vent_without_flame_arrester += 1
    end

    if relief_device_sizing["low_pressure_crudeoilstorage"] == "No" and tank_capacity < 2500
      msg = "The tank has a capacity less than ComparisonVolume ComparisonVolumeUnit Per API 2000 sec. 4.4.1.4 (5th Edition, April 2008), an open vent without a flame arrester may be used."
      count_open_vent_without_flame_arrester += 1
    end

    if relief_device_sizing["low_pressure_crudeoilstorage"] == "Yes" and tank_capacity < 126000
      msg = "The crude oil tank has a capacity less than ComparisonVolume1 ComparisonVolumeUnit1   Per API 2000 sec. 4.4.1.4 (5th Edition, April 2008), an open vent without a flame arrester may be used."
      count_open_vent_without_flame_arrester += 1
    end

    if relief_device_sizing["low_pressure_highviscousfluid"] == "Yes"
      msg = "The tank contains highly viscous oils (such as cutbacks, or penetration-grade asphalt), therefore per API 2000 sec. 4.4.1.5 (5th Edition, April 2008), the possibility of tank collapse resulting from sticking pallets or from plugging of flame arrester is greater than the possibility of flame transmission into the tank As such, an open vent may be used as an exception to the requirements for a pressure-vacuum vent or a open vent with flame arrestor."
      count_open_vent_without_flame_arrester += 1
    end

    if emission_regulation == "Strict"
      msg = "Due to strict fugitive emissions regulations, open vents may not be an acceptable means of venting."
      count_open_vent_not_acceptable = +1
    end

    #Determine acceptable design
    if count_open_vent_not_acceptable > 0
      msg = "Open vent is not an acceptable venting means based on the system characteristics."
    else
      msg = "Open vent is an acceptable venting means based on the system characteristics."
      relief_device_sizing["low_pressure_emergency_venttype"] == "Open Vent"
    end

    if count_open_vent_not_acceptable == 0
      if count_open_vent_without_flame_arrester > 0
        msg = "Flame arresting device is not required based on system characteristics."
      elsif count_open_vent_without_flame_arrester ==0
        if count_flame_arrester_needed_for_open_vent > 0
          msg = "Flame arresting device is required based on system characteristics."
        else
          msg= "Flame arresting device is not required based on system characteristics."
        end
      end
    end

    if relief_device_sizing["low_pressure_dischargelocation"] == "Pipe Away"
      if count_open_vent_not_acceptable > 0
        if count_flame_arrester_needed_for_pvto_pipe_away > 0
          msg = "Flame arresting device is required based on system characteristics."
        else
          msg = "Flame arresting device is not required based on system characteristics."
        end
      end
    elsif relief_device_sizing["low_pressure_dischargelocation"] == "Atmosphere"
      if count_open_vent_not_acceptable > 0
        if count_flame_arrester_needed_for_pvto_pipe_away > 0
          msg = "Flame arresting device is not required based on system characteristics"
        end
      end
    end

    #Define Set Pressure Range
    set_pressure = relief_device_sizing.convert_to_base_unit(:su_pressure, pressure_setting)
    set_vacuum = relief_device_sizing.convert_to_base_unit(:su_pressure, vacuum_setting)

    if set_pressure < 1 or set_vacuum < 0.62366
      if leak_point == "No"
        relief_device_sizing["low_pressure_conservation_venttype"] = "Pressure - Vacuum Vent(Direct Acting - Weight Loaded)"
      end
    elsif set_pressure >= 1 or set_vacuum >= 0.62366
      relief_device_sizing["low_pressure_conservation_venttype"] = "Pressure - Vacuum Vent(Pilot Operated)"
    end

    #Frangible Roof acceptable
    if relief_device_sizing["low_pressure_frangibleroof"] == "Yes"
      if project.pressure_relief_system_design_parameter.frangible_roof_design_for_relief_protection != "Not Considered acceptable means of emergency relief"
        relief_device_sizing["low_pressure_emergency_venttype"] == "Frangible Roof"
      end
    end
    relief_device_sizing.save

    render :json => {:success => true, :mesg => msg}
  end


  # Private methods
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
    {"" => [],
     "Process Line" => [],
     "Pressure Vessel" => [],
     "Column" => ["Top", "Bottom"],
     "Filter" => [],
     "Reactor" => [],
     "Low Pressure Tank" => [],
     "Centrifugal Pump" => [],
     "Reciprocating Pump" => [],
     "Centrifugal Compressor" => ["Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5", "Stage 6", "Stage 7", "Stage8", "Stage 9", "Stage 10"],
     "Reciprocating Compressor" => ["Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5", "Stage 6", "Stage 7", "Stage8", "Stage 9", "Stage 10"],
     "Steam Turbine" => [],
     "Turbo Expander" => [],
     "Hydraulic Turbine" => [],
     "HEX (Shell & Tube)" => ["Shell", "Tube"],
     "HEX (Double Pipe)" => ["Inner", "Outer"],
     "HEX (Plate & Frame)" => ["Hot", "Cold"],
     "Furnace Heater" => ["Radiant", "Convective"],
     "User Specified" => []
    }
  end

  def eq_tags(project)
    t = {}
    types = equipment_type
    types.each do |type|
      tags = equipment_tags(type, project)
      if tags.empty?
        t[type] = tags
      else
        t[type] = tags.collect! { |ta| [ta[1], ta[0]] }
      end
    end
    return t
  end

  def eq_links(project)
    t = {}
    types = equipment_type
    types.each do |type|
      tags = equipment_links(type, project)
      if tags.empty?
        t[type] = tags
      else
        t[type] = tags.collect! { |ta| [ta[1], ta[0]] }
      end
    end
    return t
  end

  #return equipment tags based on equipment type
  def equipment_tags(equipment_type, project)
    if ["Process Line"].include?(equipment_type)
      project.line_sizings.collect { |v| [v.id, v.line_number] }
    elsif ["Pressure Vessel"].include?(equipment_type)
      project.vessel_sizings.collect { |v| [v.id, v.name] }
    elsif ["Column"].include?(equipment_type)
      project.column_sizings.collect { |v| [v.id, v.column_system] }
    elsif ["Filter"].include?(equipment_type)
      project.vessel_sizings.collect { |v| [v.id, v.name] }
    elsif ["Reactor"].include?(equipment_type)
      project.vessel_sizings.collect { |v| [v.id, v.name] }
    elsif ["Low Pressure Tank"].include?(equipment_type)
      project.storage_tank_sizings.collect { |v| [v.id, v.storage_tank_tag] }
    elsif ["Centrifugal Pump", "Reciprocating Pump"].include?(equipment_type)
      project.pump_sizings.collect { |v| [v.id, v.centrifugal_pump_tag] }
    elsif ["Centrifugal Compressor", "Reciprocating Compressor"].include?(equipment_type)
      project.compressor_sizing_tags.collect { |v| [v.id, v.compressor_sizing_tag] }
    elsif ["Steam Turbine", "Turbo Expander", "Hydraulic Turbine"].include?(equipment_type)
      []
    elsif ["HEX (Shell & Tube)", "HEX (Double Pipe)", "HEX (Plate & Frame)", "Furnace Heater"].include?(equipment_type)
      project.heat_exchanger_sizings.collect { |v| [v.id, v.exchanger_tag] }
    else
      []
    end
  end

  #return equipment view links based on equipment type
  def equipment_links(equipment_type, project)
    if ["Process Line"].include?(equipment_type)
      project.line_sizings.collect { |v| [v.id, 'line_sizings'] }
    elsif ["Pressure Vessel"].include?(equipment_type)
      project.vessel_sizings.collect { |v| [v.id, 'vessel_sizings'] }
    elsif ["Column"].include?(equipment_type)
      project.column_sizings.collect { |v| [v.id, 'column_sizings'] }
    elsif ["Filter"].include?(equipment_type)
      project.vessel_sizings.collect { |v| [v.id, 'vessel_sizings'] }
    elsif ["Reactor"].include?(equipment_type)
      project.vessel_sizings.collect { |v| [v.id, 'vessel_sizings'] }
    elsif ["Low Pressure Tank"].include?(equipment_type)
      project.storage_tank_sizings.collect { |v| [v.id, 'storage_tank_sizings'] }
    elsif ["Centrifugal Pump", "Reciprocating Pump"].include?(equipment_type)
      project.pump_sizings.collect { |v| [v.id, 'pump_sizings'] }
    elsif ["Centrifugal Compressor", "Reciprocating Compressor"].include?(equipment_type)
      project.compressor_sizing_tags.collect { |v| [v.id, 'compressor_sizings'] }
    elsif ["Steam Turbine", "Turbo Expander", "Hydraulic Turbine"].include?(equipment_type)
      []
    elsif ["HEX (Shell & Tube)", "HEX (Double Pipe)", "HEX (Plate & Frame)", "Furnace Heater"].include?(equipment_type)
      project.heat_exchanger_sizings.collect { |v| [v.id, 'eat_exchanger_sizings'] }
    else
      []
    end
  end


  #tab change Determine Sizing Method
  def relief_sizing_method_selection

    begin
      relief_device_sizing = @scenario_identification.scenario_summary.relief_device_sizing
      project = relief_device_sizing.project

      barometric_pressure = project.barometric_pressure
      uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure

      #Determined default sizing basis
      relief_condition_phase = ''
      relief_condition_mass_vapor_fraction = @scenario_identification.rc_mass_vapor_fraction
      if relief_condition_mass_vapor_fraction == 0
        relief_condition_phase = "Liquid"
      elsif relief_condition_mass_vapor_fraction == 1
        relief_condition_phase = "Vapor"
      elsif relief_condition_mass_vapor_fraction > 0 and relief_condition_mass_vapor_fraction < 1
        relief_condition_phase = "Two Phase"
      end

      relief_condition_vapor_mw = @scenario_identification.rc_vapor_mw
      uom = project.base_unit_cf(:mtype => 'Molecular Weight', :msub_type => 'Dimensionless')
      relief_condition_vapor_mw = uom[:factor] * relief_condition_vapor_mw.to_f

      discharge_condition_pressure = @scenario_identification.dc_pressure
      uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      discharge_condition_pressure = uom[:factor] * discharge_condition_pressure.to_f

      relief_condition_vapor_pressure = @scenario_identification.rc_liquid_vapor_pressure
      uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      relief_condition_vapor_pressure = uom[:factor] * relief_condition_vapor_pressure.to_f

      relief_device_type = relief_device_sizing.relief_device_type

      if relief_device_type == "Pressure Relief Valve"
        liquid_certified = true
        if project.pressure_relief_system_design_parameter.prvlsd == "Certified liquid sizing"
          liquid_certified = true
        elsif project.pressure_relief_system_design_parameter.prvlsd == "Non Certified liquid sizing"
          liquid_certified = false
        end

        #Determine HEM Two Phase Sizing
        if relief_condition_phase == "Two Phase"
          relief_sizing_method = "Two Phase HEM"
        end

        if relief_condition_phase == "Liquid" && relief_condition_vapor_pressure > discharge_condition_pressure
          relief_sizing_method = "Two Phase HEM"
        end

        #Determine Liquid Sizing
        if relief_condition_phase == "Liquid" and liquid_certified == true and relief_condition_vapor_pressure <= discharge_condition_pressure
          relief_sizing_method = "Liquid - Certified"
        elsif relief_condition_phase == "Liquid" and liquid_certified == false and relief_condition_vapor_pressure <= discharge_condition_pressure
          relief_sizing_method = "Liquid - Non Certified"
        end

        #Determine Steam Sizing
        if relief_condition_phase == "Vapor" and relief_condition_vapor_mw == 18.02
          relief_sizing_method = "Vapor - Steam"
        end

        #Determine Vapor Sizing
        #Determine p_critical
        if relief_condition_phase == "Vapor" and relief_condition_vapor_mw != 18.02
          relief_condition_vapor_k = @scenario_identification.rc_vapor_k
          k = relief_condition_vapor_k

          relief_pressure = @scenario_identification.rc_pressure
          p1 = relief_pressure

          uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
          p1 = uom[:factor] * p1.to_f

          p_critical = ((p1 + barometric_pressure) * (2 / (k + 1)) ** (k / (k - 1))) - barometric_pressure

          if p_critical > discharge_condition_pressure
            relief_sizing_method = "Vapor - Critical"
          elsif p_critical < discharge_condition_pressure
            relief_sizing_method = "Vapor - Subcritical"
          end
        end
      elsif relief_device_type == "Rupture Disk"
        #Determine HEM Two Phase Sizing
        if relief_condition_phase == "Two Phase"
          relief_sizing_method = "Two Phase HEM"
        end

        if relief_condition_phase == "Liquid" and relief_condition_vapor_pressure > discharge_condition_pressure
          relief_sizing_method = "Two Phase HEM"
        end

        #Determine Liquid Sizing
        if relief_condition_phase == "Liquid" and liquid_certified == true and relief_condition_vapor_pressure < discharge_condition_pressure
          relief_sizing_method = "Liquid - Certified"
        elsif relief_condition_phase == "Liquid" and liquid_certified == false and relief_condition_vapor_pressure < discharge_condition_pressure
          relief_sizing_method = "Liquid - Non Certified"
        end

        #Determine Steam Sizing
        if relief_condition_phase == "Vapor" and relief_condition_vapor_mw == 18.02
          relief_sizing_method = "Vapor - Steam"
        end

        #Determine Vapor Sizing
        #Determine p_critical
        if relief_condition_phase == "Vapor" and relief_condition_vapor_mw != 18.02
          relief_condition_vapor_k = @scenario_identification.rc_vapor_k
          k = relief_condition_vapor_k

          relief_pressure = @scenario_identification.rc_pressure
          p1 = relief_pressure
          uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
          p1 = uom[:factor] * p1.to_f

          p_critical = ((p1 + barometric_pressure) * (2 / (k + 1)) ** (k / (k - 1))) - barometric_pressure

          if p_critical > discharge_condition_pressure
            relief_sizing_method = "Vapor - Critical"
          elsif p_critical < discharge_condition_pressure
            relief_sizing_method = "Vapor - Subcritical"
          end
        end
      elsif relief_device_type == "Open Vent"
        relief_sizing_method = "Line Capacity"
      elsif relief_device_type == "Low Pressure Vent"
        relief_sizing_method = "Low Pressure Vent"
      end

      @scenario_identification.relief_capacity_calculation_method = relief_sizing_method
      @scenario_identification.save

    rescue Exception => e
      logger.debug e.message
    end
  end

  def effective_discharge_area_calculation
    area = []
    msg, title = '', ''
    @alert_msg = ''

    if @scenario_identification.relief_capacity_calculation_method == "Liquid - Certified"
      log = CustomLogger.new('liquid_certified')

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      p = @relief_device_sizing.system_design_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      p = uom[:factor] * p
      log.info("converted system_design_pressure = #{p}")

      w = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      w = uom[:factor] * w
      log.info("converted rc_flow_rate = #{w}")

      p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      log.info("converted rc_total_back_pressure = #{p2}")

      back_pressure_percentage = ((p1 - barometric_pressure) / p) * 100
      log.info("back_pressure_percentage = #{back_pressure_percentage}")

      log.info("rc_liquid_back_pressure_correction_factor_list = #{@scenario_identification.rc_liquid_back_pressure_correction_factor_list}")
      if @scenario_identification.rc_liquid_back_pressure_correction_factor_list == "API 520 Fig. 31"
        if back_pressure_percentage >= 17.5 and back_pressure_percentage <= 50
          kw = -0.0098 * back_pressure_percentage + 1.1653
        elsif back_pressure_percentage >= 16 and back_pressure_percentage <= 17.5
          kw = 0.99
        elsif back_pressure_percentage < 16
          kw = 1
        end
      end

      log.info("rc_liquid_back_pressure_correction_factor = #{kw}")
      @scenario_identification.rc_liquid_back_pressure_correction_factor = kw

      t = @scenario_identification.rc_relieving_temperature
      uom = @project.measure_unit('Temperature', 'General')
      t = t.send(uom[:unit_name].downcase.to_sym).to.fahrenheit
      log.info("converted rc_relieving_temperature = #{t}")

      g = @scenario_identification.rc_specific_gravity
      log.info("g = #{g}")

      v = @scenario_identification.rc_viscosity
      uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
      v = uom[:factor] * v
      log.info("converted rc_viscosity = #{v}")

      kc = @scenario_identification.rc_combination_correction_factor
      log.info("kc = #{kc}")
      kd = @scenario_identification.rc_discharge_coefficient
      log.info("kd = #{kd}")
      kw = @scenario_identification.rc_combination_correction_factor
      log.info("kw = #{kw}")

      #convert flowrate rate to volumetric flow rate
      q = (w / g) * 0.00199799679
      log.info("q = #{q}")

      #Determine the required area
      a, kv, re = 0, 0, 0
      (1..100).each do |i|
        area[1] = 1
        re = (q * 2800 * g) / (v * area[i]**0.5)
        kv = (0.9935 + (2.878 / re**0.5) + (342.75 / re**1.5)) ** -1
        if kv > 1
          kv = 1
        end

        area[i + 1] = (q / (38 * kd * kw * kc * kv)) * (g / (p1 - p1))**0.5

        if area[i] == area[i + 1]
          a = area[i]
          i = 100
          break
        end
      end

      log.info("re = #{re}")
      @scenario_identification.rc_reynolds_number = re
      log.info("kv = #{kv}")
      @scenario_identification.rc_viscosity_correction_factor = kv

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      a = a / uom[:factor]
      log.info("a = #{a}")

      @scenario_identification.rc_effective_discharge_area = a.round(uom[:decimals])

      scenario = @scenario_summary.scenario
      log.info("scenario = #{scenario}")
      identifier = @scenario_summary.identifier
      log.info("identifier = #{identifier}")

      kc_comments = ""
      if kc >= 1
        kc_comments = "No rupture disk present on the inlet to the relief device."
      elsif kc < 1
        kc_comments = "Project specified value (in accordance with ASME VIII) to account for the presence of an inlet rupture disk."
      end
      log.info("kc_comments = #{kc_comments}")

      cmbkw = @scenario_identification.rc_liquid_back_pressure_correction_factor_list
      if @scenario_identification.rc_liquid_back_pressure_correction_factor_list == "Estimated"
        cmbkw = "estimation"
      end
      log.info("cmbkw = #{cmbkw}")

      aunit = @project.unit 'Area', 'Orifice'
      funit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      pbunit = @project.unit 'Pressure', 'Absolute'

      sizing_comments = "The required relief area for the " + scenario + " - " + identifier + " scenario is determined to be " + a.round(2) + " " + aunit + " at the relief rate of " + f.round(1) + " " + funit + " (" + q.round(1) + " gpm), based on equation 3.9 in API 520 Section 3.8.1.2 (7th Edition, January 2000). The driving force is the pressure differential across the relief device. The pressure differential is based on the relief pressure of " + (p1 - barometric_pressure).round(1) + " " + p1unit + " and the constant back pressure of " & (p1 - barometric_pressure).round(1) & " " & pbunit & ". Note that this preliminary sizing does not include the effects of inlet and outlet pressure drops which may increase the required relief area. The following correction factors were determined as such:" + "\n" + "\n" +
        "1) Reynold's Number(Re): Specified based on equation 3.10 in API 520 Section 3.8.1.2 (7th Edition, January 2000)." + msg + "\n" +
        "2) Combination Correction Factor (kc): " + kc_comments + "\n" +
        "3) Discharge Coefficient (kd): Project specified value for certified liquid sizing." + "\n" +
        "4) Viscosity Correction Factor (Kv): Specified based on the equation for Kv given in API 520 Section 3.8.1.2 (7th Edition, January 2000)." + msg + "\n" +
        "5) Liquid Back Pressure Correction Factor (Kw):  Obtained from " + cmbkw + ". " + msg + "\n" +

        log.info("sizing_comments = #{sizing_comments}")
      @scenario_identification.rc_comments = sizing_comments

    elsif @scenario_identification.relief_capacity_calculation_method == "Liquid - Non Certified"
      log = CustomLogger.new('liquid_non_certified')

      area = []
      msg, title = '', ''

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      p = @relief_device_sizing.system_design_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      p = uom[:factor] * p
      log.info("converted system_design_pressure = #{p}")

      _w = w = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      w = uom[:factor] * w
      log.info("converted rc_flow_rate = #{w}")

      _p1 = p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      _p2 = p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      _pb = pb = p2
      log.info("converted rc_total_back_pressure = #{pb}")

      #Determine Kp value
      over_pressure = ((((p1 - barometric_pressure) - p) / p) * 100).round(0)
      log.info("over_pressure = #{over_pressure}")
      back_pressure_percentage = ((p2 - barometric_pressure) / p) * 100
      log.info("back_pressure_percentage = #{back_pressure_percentage}")

      log.info("rc_overpressure_correction_factor_list = #{@scenario_identification.rc_overpressure_correction_factor_list}")
      kp = 0
      @change_kp = false
      if @scenario_identification.rc_overpressure_correction_factor_list == "API 520 Fig. 37"
        if over_pressure >= 25 and over_pressure <= 50
          kp = 0.004 * over_pressure + 0.9
        elsif over_pressure >= 10 and over_pressure < 25
          kp = -0.0012 * over_pressure**2 + 0.067 * over_pressure + 0.0475
        elsif over_pressure < 10 and over_pressure > 0
          msg = "API 520 Capacity Correction Factor due to overpressure for Noncertified Pressure Relief Valve in Liquid Service is published and therefore valid for overpressure above 10% and below 50%.  The manufacturer should be contacted for any other condition. Note that noncertified valves operating at low overpressure tend to chatter; therefore, overpressures of less than 10% should be avoided. If the overpressure is less than 10% as a result of excessive inlet pressure drop, the Kp factor of 0.6 can be assumed in the interim for the purpose of sizing the relief device."
          kp = 0.6
          @alert_msg = msg
          @change_kp = true
          return
        else
          msg = "API 520 Capacity Correction Factor due to overpressure for Noncertified Pressure Relief Valve in Liquid Service is published and therefore valid for overpressure above 10% and below 50%.  The manufacturer should be contacted for any other condition."
          @alert_msg = msg
          @change_kp = true
          return
        end
      end

      @scenario_identification.rc_overpressure_correction_factor = kp
      log.info("kp = #{kp}")

      #Determine Kw value
      c = ((pb - barometric_pressure) / p) * 100
      log.info("c = #{c}")
      log.info("rc_liquid_back_pressure_correction_factor_list = #{@scenario_identification.rc_liquid_back_pressure_correction_factor_list}")
      if @scenario_identification.rc_liquid_back_pressure_correction_factor_list == "API 520 Fig. 31"
        if back_pressure_percentage >= 17.5 and back_pressure_percentage <= 50
          kw = -0.0098 * back_pressure_percentage + 1.1653
        elsif back_pressure_percentage >= 16 and back_pressure_percentage <= 17.5
          kw = 0.99
        elsif back_pressure_percentage < 16
          kw = 1
        end
      end

      log.info("rc_liquid_back_pressure_correction_factor = #{kw}")
      @scenario_identification.rc_liquid_back_pressure_correction_factor = kw

      t = @scenario_identification.rc_relieving_temperature
      uom = @project.measure_unit('Temperature', 'General')
      t = t.send(uom[:unit_name].downcase.to_sym).to.fahrenheit
      log.info("converted rc_relieving_temperature = #{t}")

      g = @scenario_identification.rc_specific_gravity
      log.info("g = #{g}")

      v = @scenario_identification.rc_viscosity
      uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
      v = uom[:factor] * v
      log.info("converted rc_viscosity = #{v}")

      kc = @scenario_identification.rc_combination_correction_factor
      log.info("kc = #{kc}")
      kd = @scenario_identification.rc_discharge_coefficient
      log.info("kd = #{kd}")
      kp = @scenario_identification.rc_overpressure_correction_factor
      log.info("kp = #{kp}")
      kw = @scenario_identification.rc_liquid_back_pressure_correction_factor
      log.info("kw = #{kw}")

      #Convert flow rate to volumetric flow rate
      q = (w / g) * 0.00199799679
      log.info("q = #{q}")

      #Determine the required area
      a = 0
      (1..100).each do |i|
        area[1] = 1
        re = (q * 2800 * g) / (v * area[i]**0.5)
        kv = (0.9935 + (2.878 / re**0.5) + (342.75 / re**1.5))**-1

        if kv > 1
          kv = 1
        end

        area[i + 1] = (q / (38 * kd * kw * kc * kv * kp)) * (g / (1.25 * p - (pb - barometric_pressure)))**0.5
        if area[i] == area[i + 1]
          a = area[i]
          i = 100
        end
      end

      log.info("re = #{re}")
      uom = @project.measure_unit("Reynold's number", "Dimensionless")
      @scenario_identification.rc_reynolds_number = re.round(uom[:decimal_places])
      log.info("kv = #{kv}")
      @scenario_identification.rc_viscosity_correction_factor = kv

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      a = a / uom[:factor]
      log.info("converted a = #{a}")

      @scenario_identification.rc_effective_discharge_area = a.round(uom[:decimals])

      scenario = @scenario_summary.scenario
      log.info("scenario = #{scenario}")
      identifier = @scenario_summary.identifier
      log.info("identifier = #{identifier}")

      kc_comments = ""
      if kc >= 1
        kc_comments = "No rupture disk present on the inlet to the relief device."
      elsif kc < 1
        kc_comments = "Project specified value (in accordance with ASME VIII) to account for the presence of an inlet rupture disk."
      end
      log.info("kc_comments = #{kc_comments}")

      cmbkw = @scenario_identification.rc_liquid_back_pressure_correction_factor_list
      if @scenario_identification.rc_liquid_back_pressure_correction_factor_list == "Estimated"
        cmbkw = "estimation"
      end
      log.info("cmbkw = #{cmbkw}")

      cmbkp = @scenario_identification.rc_overpressure_correction_factor_list
      if @scenario_identification.rc_overpressure_correction_factor_list == "Estimated"
        cmbkp = "estimation"
      end
      log.info("cmbkw = #{cmbkp}")

      aunit = @project.unit 'Area', 'Orifice'
      funit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      pbunit = @project.unit 'Pressure', 'Absolute'

      sizing_comments = "The required relief area for the " + scenario + " - " + identifier + " scenario is determined to be " + a.round(2).to_s + " " + aunit + " at the relief rate of " + _w.round(1).to_s + " " + funit + ", based on equation 3.12 in API 520 Section 3.9.2 (7th Edition, January 2000). The driving force is the pressure differential across the relief device. The pressure differential is based on the relief pressure of " + _p1.to_s + " " + p1unit + " and the constant back pressure of " + _pb.to_s + " " + pbunit + ". Note that this preliminary sizing does not include the effects of inlet and outlet pressure drops which may increase the required relief area. The following correction factors were determined as such:" + "\n" + "\n" +
        "1) Reynold's Number(Re): Specified based on equation 3.10 in API 520 Section 3.8.1.3 (7th Edition, January 2000)." + msg + "\n" +
        "2) Combination Correction Factor (Kc): " + kc_comments + "\n" +
        "3) Discharge Coefficient (Kd): Project specified value for certified liquid sizing." + "\n" +
        "4) Over Pressure Correction Factor (Kp): Obtained from " + cmbkp + ". " + msg + "\n" +
        "5) Viscosity Correction Factor (Kv):  Specified based on the equation for Kv given in API 520 Section 3.9.2 (7th Edition, January 2000)." + msg + "\n" +
        "6) Liquid Back Pressure Correction Factor (Kw): Obtained from " + cmbkw + ". " + msg + "\n"

      log.info("sizing_comments = #{sizing_comments}")
      @scenario_identification.rc_comments = sizing_comments

    elsif @scenario_identification.relief_capacity_calculation_method == "Vapor - Critical"
      log = CustomLogger.new('vapor_critical')

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      p = @relief_device_sizing.system_design_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      p = uom[:factor] * p
      log.info("converted system_design_pressure = #{p}")

      _w = w = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      w = uom[:factor] * w
      log.info("converted rc_flow_rate = #{w}")

      _p1 = p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      _p2 = p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      log.info("converted rc_total_back_pressure = #{p2}")

      over_pressure = ((((p1 - barometric_pressure) - p) / p) * 100).round(0)
      log.info("over_pressure = #{over_pressure}")
      back_pressure_percentage = ((p2 - barometric_pressure) / p) * 100
      log.info("back_pressure_percentage = #{back_pressure_percentage}")

      kb = 0
      @change_kb = false
      msg_kb = ""
      if @scenario_identification.rc_back_pressure_correction_factor_list == "API 520 Fig. 30"
        log.info("rc_back_pressure_correction_factor_list = #{@scenario_identification.rc_back_pressure_correction_factor_list}")
        if over_pressure == 10
          if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
            kb = -0.0179 * back_pressure_percentage + 1.5829
          elsif back_pressure_percentage < 38 and back_pressure_percentage >= 30
            kb = -0.000539 * (back_pressure_percentage)**2 + 0.024256 * (back_pressure_percentage) + 0.756854
          elsif back_pressure_percentage < 30
            kb = 1
          elsif back_pressure_percentage > 50
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% Back Pressure. The manufacturer should be contacted for Kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure == 16
          if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
            kb = -0.0076 * back_pressure_percentage + 1.2837
          elsif back_pressure_percentage < 38
            kb = 1
          elsif back_pressure_percentage > 50
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% Back Pressure. The manufacturer should be contacted for Kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure == 21
          if back_pressure_percentage < 50
            kb = 1
          else
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% Back Pressure. The manufacturer should be contacted for Kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure > 10 and over_pressure < 16
          log.info("over_pressure > 10 and over_pressure < 16 = #{over_pressure}")
          log.info("kb_at_over_pressure_between_api_values = #{@project.pressure_relief_system_design_parameter.kb_at_over_pressure_between_api_values}")
          if @project.pressure_relief_system_design_parameter.kb_at_over_pressure_between_api_values
            msg_kb = "the use of the 10% overpressure curve from API 520 Fig. 30 as a conservative estimate"
            if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
              log.info("back_pressure_percentage >= 38 and back_pressure_percentage <= 50 = #{back_pressure_percentage}")
              kb = -0.0179 * back_pressure_percentage + 1.5829
            elsif back_pressure_percentage < 38 and back_pressure_percentage >= 30
              kb = -0.000539 * (back_pressure_percentage)**2 + 0.024256 * (back_pressure_percentage) + 0.756854
            elsif back_pressure_percentage < 30
              kb = 1
            elsif back_pressure_percentage > 50
              @alert_msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% back pressure. The manufacturer should be contacted for Kb values above 50%."
              @change_kb = true
              return
            end
          else
            @alert_msg = "The overpressure of " + over_pressure.round(0).to_s + " % lies between the Back Pressure Correction Factor(Kb) correlation at 10% overpressure and 16% overpressure published in Fig 30 in API 520. The manufacturer should be contacted for Kb values at this overpressure."
            @change_kb = true
            return
          end
        elsif over_pressure > 16 and over_pressure < 21
          if @project.pressure_relief_system_design_parameter.kb_at_over_pressure_between_api_values
            msg_kb = "the use of the 16% overpressure curve from API 520 Fig. 30 as a conservative estimate"
            if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
              kb = -0.0076 * back_pressure_percentage + 1.2837
            elsif back_pressure_percentage < 38
              kb = 1
            elsif back_pressure_percentage > 50
              @alert_msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% back pressure. The manufacturer should be contacted for Kb values above 50%."
              @change_kb = true
              return
            end
          else
            @alert_msg = "The overpressure of " + over_pressure.round(0).to_s + "% lies between the Back Pressure Correction Factor(Kb) correlation at 16% overpressure and 21% overpressure published in Fig 30 in API 520. The manufacturer should be contacted for kb values at this overpressure."
            @change_kb = true
            return
          end
        else
          @alert_msg = "API 520 Back Pressure Correction Factor Kb, is valid at 10%, 16% and 21% overpressure. The manufacturer should be contacted for kb values at any other overpressure."
          @change_kb = true
          return
        end
      else
        kb = @scenario_identification.rc_back_pressure_correction_factor
      end

      uom = @project.measure_unit("Back Pressure Correction Factor", "Dimensionless")
      @scenario_identification.rc_back_pressure_correction_factor = kb.round(uom[:decimal_places])
      log.info("rc_back_pressure_correction_factor = #{kb}")

      t = @scenario_identification.rc_relieving_temperature
      log.info("rc_relieving_temperature = #{t}")
      uom = @project.measure_unit('Temperature', 'General')
      t = t.send(uom[:unit_name].downcase.to_sym).to.fahrenheit
      log.info("converted rc_relieving_temperature = #{t}")

      mw = @scenario_identification.rc_vapor_mw
      log.info("mw = #{mw}")
      z = @scenario_identification.rc_vapor_z
      log.info("z = #{z}")
      cp_cv = @scenario_identification.rc_vapor_k
      log.info("cp_cv = #{cp_cv}")

      kb = @scenario_identification.rc_back_pressure_correction_factor
      log.info("kb = #{kb}")
      kc = @scenario_identification.rc_combination_correction_factor
      log.info("kc = #{kc}")
      kd = @scenario_identification.rc_discharge_coefficient
      log.info("kd = #{kd}")

      c = 520 * (cp_cv * (2 / (cp_cv + 1))**((cp_cv + 1) / (cp_cv - 1)))**0.5
      log.info("c = #{c}")
      a = (w / (c * kd * p1 * kb * kc)) * ((t + 459.67) * z / mw)**0.5
      log.info("a = #{a}")

      uom = @project.measure_unit("Coefficient", "Dimensionless")
      @scenario_identification.rc_coefficient = c.round(uom[:decimal_places])
      log.info("rc_coefficient = #{c}")

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      a = a / uom[:factor]
      log.info("converted a = #{a}")

      @scenario_identification.rc_effective_discharge_area = a.round(uom[:decimals])
      log.info("converted rc_effective_discharge_area = #{@scenario_identification.rc_effective_discharge_area}")

      scenario = @scenario_summary.scenario
      log.info("scenario = #{scenario}")
      identifier = @scenario_summary.identifier
      log.info("identifier = #{identifier}")

      kc_comments = ""
      if kc >= 1
        kc_comments = "No rupture disk present on the inlet to the relief device."
      elsif kc < 1
        kc_comments = "Project specified value (in accordance with ASME VIII) to account for the presence of an inlet rupture disk."
      end
      log.info("kc_comments = #{kc_comments}")

      cmbkb = @scenario_identification.rc_back_pressure_correction_factor_list
      log.info("cmbkb = #{cmbkb}")
      if @scenario_identification.rc_back_pressure_correction_factor_list == "Estimated"
        cmbkb = "estimation"
      end
      log.info("cmbkb = #{cmbkb}")

      if @scenario_identification.rc_back_pressure_correction_factor_list == "API 520 Fig. 30" and msg_kb != ""
        cmbkb = msg_kb
      end

      aunit = @project.unit 'Area', 'Orifice'
      wunit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      p2unit = @project.unit 'Pressure', 'Absolute'

      sizing_comments = "The required relief area for the " + scenario + " - " + identifier + " scenario is determined to be " + a.round(2).to_s + " " + aunit + " at the relief rate of " + _w.round(1).to_s + " " + wunit + ", based on equation 3.2 in API 520 Section 3.6.2.1.1 (7th Edition, January 2000). The driving force is the pressure differential across the relief device. The pressure differential is based on the relief pressure of " + _p1.round(1).to_s + " " + p1unit + " and the constant back pressure of " + _p2.round(1).to_s + " " + p2unit + ". Note that this preliminary sizing does not include the effects of inlet and outlet pressure drops which may increase the required relief area. The following correction factors were determined as such:" + "\n" + "\n" +
        "1) Coefficient Of Specific Heat Ratio (C): As specified by the equation associated with Fig. 32 in API 520 (7th Edition, January 2000)." + "\n" +
        "2) Back Pressure Correction Factor (Kb): Obtained from " + cmbkb + ". " + "\n" +
        "3) Combination Correction Factor (Kc):  " + kc_comments + "\n" +
        "4) Discharge Coefficient (Kd):  Project specified value for vapor sizing." + "\n"

      @scenario_identification.rc_comments = sizing_comments
      log.info("sizing_comments = #{sizing_comments}")

    elsif @scenario_identification.relief_capacity_calculation_method == "Vapor - Subcritical"
      log = CustomLogger.new('vapor_subcritical')

      _w = w = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      w = uom[:factor] * w
      log.info("converted rc_flow_rate = #{w}")

      _p1 = p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      _p2 = p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      log.info("converted rc_total_back_pressure = #{p2}")

      t = @scenario_identification.rc_relieving_temperature
      uom = @project.measure_unit('Temperature', 'General')
      t = t.send(uom[:unit_name].downcase.to_sym).to.fahrenheit
      log.info("converted rc_relieving_temperature = #{t}")

      mw = @scenario_identification.rc_vapor_mw
      log.info("mw = #{mw}")
      z = @scenario_identification.rc_vapor_z
      log.info("z = #{z}")
      cp_cv = @scenario_identification.rc_vapor_k
      log.info("cp_cv = #{cp_cv}")

      kc = @scenario_identification.rc_combination_correction_factor
      log.info("kc = #{kc}")
      kd = @scenario_identification.rc_discharge_coefficient
      log.info("kd = #{kd}")

      r = p2 / p1
      log.info("r = #{r}")
      f2 = ((cp_cv / (cp_cv - 1)) * ((r)**(2 / cp_cv)) * (1 - (r**((cp_cv - 1) / cp_cv))) / (1 - r))**0.5
      log.info("f2 = #{f2}")
      a = (w / (735 * f2 * kd * kc)) * (z * (t + 459.67) / (mw * p1 * (p1 - p2)))**0.5
      log.info("a = #{a}")

      uom = @project.measure_unit("Coefficient of Subcritical Flow", "Dimensionless")
      @scenario_identification.rc_coefficient_of_subcritical_flow = f2.round(uom[:decimal_places])

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      a = a / uom[:factor]
      log.info("converted a = #{a}")

      @scenario_identification.rc_effective_discharge_area = a.round(uom[:decimals])

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      scenario = @scenario_summary.scenario
      log.info("scenario = #{scenario}")
      identifier = @scenario_summary.identifier
      log.info("identifier = #{identifier}")

      kc_comments = ""
      if kc >= 1
        kc_comments = "No rupture disk present on the inlet to the relief device."
      elsif kc < 1
        kc_comments = "Project specified value (in accordance with ASME VIII) to account for the presence of an inlet rupture disk."
      end
      log.info("kc_comments = #{kc_comments}")

      aunit = @project.unit 'Area', 'Orifice'
      wunit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      p2unit = @project.unit 'Pressure', 'Absolute'

      sizing_comments = "The required relief area for the " + scenario + " - " + identifier + " scenario is determined to be " + a.round(2).to_s + " " + aunit + " at the relief rate of " + _w.round(1).to_s + " " + wunit + ", based on equation 3.5 in API 520 Section 3.6.3.1 (7th Edition, January 2000). The driving force is the pressure differential across the relief device. The pressure differential is based on the relief pressure of " + _p1.round(1).to_s + " " + p1unit + " and the constant back pressure of " + _p2.round(1).to_s + " " + p2unit + ". Note that this preliminary sizing does not include the effects of inlet and outlet pressure drops which may increase the required relief area. The following correction factors were determined as such:" + "\n" + "\n" +
        "1) Coefficient Of Subcritical Flow (F2): As specified by the equation for F2 given in API 520 Section 3.6.3.1 (7th Edition, January 2000)." + "\n" +
        "2) Combination Correction Factor (Kc): " + kc_comments + "\n" +
        "3) Discharge Coefficient (Kd):  Project specified value for vapor sizing." + "\n"

      log.info("sizing_comments = #{sizing_comments}")

      @scenario_identification.rc_comments = sizing_comments

    elsif @scenario_identification.relief_capacity_calculation_method == "Vapor - Steam"
      log = CustomLogger.new('vapor_steam')

      msg, title, style = "", "", ""

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      p = @relief_device_sizing.system_design_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      p = uom[:factor] * p
      log.info("converted system_design_pressure = #{p}")

      _w = w = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      w = uom[:factor] * w
      log.info("converted rc_flow_rate = #{w}")

      _p1 = p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      _p2 = p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      log.info("converted rc_total_back_pressure = #{p2}")

      over_pressure = ((((p1 - barometric_pressure) - p) / p) * 100).round(0)
      log.info("over_pressure = #{over_pressure}")
      back_pressure_percentage = ((p2 - barometric_pressure) / p) * 100
      log.info("back_pressure_percentage = #{back_pressure_percentage}")

      log.info("rc_back_pressure_correction_factor_list = #{@scenario_identification.rc_back_pressure_correction_factor_list}")
      if @scenario_identification.rc_back_pressure_correction_factor_list == "API 520 Fig. 30"
        if over_pressure == 10
          if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
            kb = -0.0179 * back_pressure_percentage + 1.5829
          elsif back_pressure_percentage < 38 and back_pressure_percentage >= 30
            kb = -0.000539 * (back_pressure_percentage)**2 + 0.024256 * (back_pressure_percentage) + 0.756854
          elsif back_pressure_percentage < 30
            kb = 1
          elsif back_pressure_percentage > 50
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% back pressure. The manufacturer should be contacted for Kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure == 16
          if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
            kb = -0.0076 * back_pressure_percentage + 1.2837
          elsif back_pressure_percentage < 38
            kb = 1
          elsif back_pressure_percentage > 50
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% back pressure. The manufacturer should be contacted for Kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure == 21
          if back_pressure_percentage < 50
            kb = 1
          else
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% back pressure. The manufacturer should be contacted for Kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure > 10 and over_pressure < 16
          log.info("over_pressure > 10 and over_pressure < 16 = #{over_pressure}")
          log.info("kb_at_over_pressure_between_api_values = #{@project.pressure_relief_system_design_parameter.kb_at_over_pressure_between_api_values}")
          if @project.pressure_relief_system_design_parameter.kb_at_over_pressure_between_api_values
            msg_kb = "the use of the 10% overpressure curve from API 520 Fig. 30 as a conservative estimate"
            if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
              log.info("back_pressure_percentage >= 38 and back_pressure_percentage <= 50 = #{back_pressure_percentage}")
              kb = -0.0179 * back_pressure_percentage + 1.5829
            elsif back_pressure_percentage < 38 and back_pressure_percentage >= 30
              kb = -0.000539 * (back_pressure_percentage)**2 + 0.024256 * (back_pressure_percentage) + 0.756854
            elsif back_pressure_percentage < 30
              kb = 1
            elsif back_pressure_percentage > 50
              @alert_msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% back pressure. The manufacturer should be contacted for Kb values above 50%."
              @change_kb = true
              return
            end
          else
            @alert_msg = "The overpressure of " + over_pressure.round(0).to_s + " % lies between the Back Pressure Correction Factor(Kb) correlation at 10% overpressure and 16% overpressure published in Fig 30 in API 520. The manufacturer should be contacted for Kb values at this overpressure."
            @change_kb = true
            return
          end
        elsif over_pressure > 16 and over_pressure < 21
          if @project.pressure_relief_system_design_parameter.kb_at_over_pressure_between_api_values
            msg_kb = "the use of the 16% overpressure curve from API 520 Fig. 30 as a conservative estimate"
            if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
              kb = -0.0076 * back_pressure_percentage + 1.2837
            elsif back_pressure_percentage < 38
              kb = 1
            elsif back_pressure_percentage > 50
              @alert_msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% back pressure. The manufacturer should be contacted for Kb values above 50%."
              @change_kb = true
              return
            end
          else
            @alert_msg = "The overpressure of " + over_pressure.round(0).to_s + "% lies between the Back Pressure Correction Factor(Kb) correlation at 16% overpressure and 21% overpressure published in Fig 30 in API 520. The manufacturer should be contacted for kb values at this overpressure."
            @change_kb = true
            return
          end
        else
          @alert_msg = "API 520 Back Pressure Correction Factor Kb, is valid at 10%, 16% and 21% overpressure. The manufacturer should be contacted for kb values at any other overpressure."
          @change_kb = true
          return
        end
      else
        kb = @scenario_identification.rc_back_pressure_correction_factor
      end

      log.info("kb = #{kb}")
      @scenario_identification.rc_back_pressure_correction_factor = kb

      t = @scenario_identification.rc_relieving_temperature
      uom = @project.measure_unit('Temperature', 'General')
      t = t.send(uom[:unit_name].downcase.to_sym).to.fahrenheit
      log.info("converted rc_relieving_temperature = #{t}")

      kb = @scenario_identification.rc_back_pressure_correction_factor
      log.info("kb = #{kb}")
      cmbkb = @scenario_identification.rc_back_pressure_correction_factor_list
      log.info("cmbkb = #{cmbkb}")
      kc = @scenario_identification.rc_combination_correction_factor
      log.info("kc = #{kc}")
      kd = @scenario_identification.rc_discharge_coefficient
      log.info("kd = #{kd}")

      #Determine Kn Factor
      kn = 1
      if p1 > 1500
        kn = ((0.1906 * p1) - 1000) / ((0.2294 * p1) - 1061)
      elsif p1 <= 1500
        kn = 1
      end
      log.info("kn = #{kn}")
      uom = @project.measure_unit("Napier Correction Factor", "Dimensionless")
      @scenario_identification.rc_napier_correction_factor = kn.round(uom[:decimal_places])

      #Determine Ksh Factor
      if p == 15
        ksh = -0.0004 * p + 1.1015
      elsif p > 15 and p <= 20
        ksh = -0.0004 * p + 1.1015
      elsif p > 20 and p <= 40
        ksh = -0.0004 * p + 1.1062
      elsif p > 40 and p <= 60
        ksh = -0.0004 * p + 1.1049
      elsif p > 60 and p <= 80
        ksh = -0.0004 * p + 1.1049
      elsif p > 80 and p <= 100
        ksh = -0.0004 * p + 1.1105
      elsif p > 100 and p <= 120
        ksh = -0.0004 * p + 1.1102
      elsif p > 120 and p <= 140
        ksh = -0.0004 * p + 1.1116
      elsif p > 140 and p <= 160
        ksh = -0.0004 * p + 1.1116
      elsif p > 160 and p <= 180
        ksh = -0.0004 * p + 1.1116
      elsif p > 180 and p <= 200
        ksh = -0.0004 * p + 1.1149
      elsif p > 200 and p <= 220
        ksh = -0.0004 * p + 1.1149
      elsif p > 220 and p <= 240
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure. For the purpose of this analysis, the Ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * p + 1.1302
        end
      elsif p > 240 and p <= 260
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure. For the purpose of this analysis, the Ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1302
        end
      elsif p > 260 and p <= 280
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1353
        end
      elsif p > 280 and p <= 300
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1353
        end
      elsif p > 300 and p <= 350
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1389
        end
      elsif p > 350 and p <= 400
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1427
        end
      elsif p > 400 and p <= 500
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1436
        end
      elsif p > 500 and p <= 600
        if t < 399
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1509
        end
      elsif p > 600 and p <= 800
        if t < 499
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.1943
        end
      elsif p > 800 and p <= 1000
        if t < 499
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.2011
        end
      elsif p > 1000 and p <= 1250
        if t < 499
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0004 * t + 1.2131
        end
      elsif p > 1250 and p <= 1500
        if t < 599
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0005 * t + 1.2621
        end
      elsif p > 1500 and p <= 1750
        if t < 599
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0005 * t + 1.2632
        end
      elsif p > 1750 and p <= 2000
        if t < 599
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0005 * t + 1.3046
        end
      elsif p > 2000 and p <= 2500
        if t < 599
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = -0.0006 * t + 1.3421
        end
      elsif p > 2500 and p <= 3000
        if t < 699
          msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  For the purpose of this analysis, the ksh is set to 1.0"
          ksh = 1
        else
          ksh = (1 * 10**-11) * (t)**4 - (6 * 10**-8) * (t)**3 + (9 * 10**-5) * (t)**2 - (0.0645 * t) + 17.655
        end
      elsif p > 3000
        msg = "The Superheat Steam Correction Factor (Ksh) is not published for this degree of superheat at the relief device set pressure.  Therefore the ksh valve could not be determined."
      end

      log.info("ksh = #{ksh}")
      uom = @project.measure_unit("Superheat Correction Factor", "Dimensionless")
      @scenario_identification.rc_superheat_correction_factor = ksh.round(uom[:decimal_places])

      #Determine Effective Area
      a = w / (51.5 * p1 * kd * kb * kc * kn * ksh)
      log.info("Effective Area = #{a}")

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      a = a / uom[:factor]
      log.info("Converted Effective Area = #{a}")
      @scenario_identification.rc_effective_discharge_area = a.round(uom[:decimals])

      #Add comments
      scenario = @scenario_summary.scenario
      log.info("scenario = #{scenario}")
      identifier = @scenario_summary.identifier
      log.info("identifier = #{identifier}")

      kc_comments = ''
      if kc >= 1
        kc_comments = "No rupture disk present on the inlet to the relief device."
      elsif kc < 1
        kc_comments = "Project specified value (in accordance with ASME VIII) to account for the presence of an inlet rupture disk."
      end
      log.info("kc_comments = #{kc_comments}")

      cmbkb = @scenario_identification.rc_back_pressure_correction_factor_list
      if @scenario_identification.rc_back_pressure_correction_factor_list == "Estimated"
        cmbkb = "estimation"
      end
      log.info("cmbkb = #{cmbkb}")

      aunit = @project.unit 'Area', 'Orifice'
      wunit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      p2unit = @project.unit 'Pressure', 'Absolute'

      sizing_comments = "The required relief area for the " + scenario + " - " + identifier + " scenario is determined to be " + a.round(2).to_s + " " + aunit + " at the relief rate of " + _w.round(1).to_s + " " + wunit + ", based on equation 3.8 in API 520 Section 3.7.1 (7th Edition, January 2000). The driving force is the pressure differential across the relief device. The pressure differential is based on the relief pressure of " + _p1.round(1).to_s + " " + p1unit + " and the constant back pressure of " + _p2.round(1).to_s + " " + p2unit + ". Note that this preliminary sizing does not include the effects of inlet and outlet pressure drops which may increase the required relief area. The following correction factors were determined as such:" + "\n" + "\n" +
        "1) Back Pressure Correction Factor (kb):  Obtained from " + cmbkb + ". " + msg + "\n" +
        "2) Combination Correction Factor (Kc):  " + kc_comments + "\n" +
        "3) Discharge Coefficient (Kd):  Project specified value for vapor sizing." + "\n" +
        "4) Napier Correction Factor (Kn):  Specified based on the equation for Kn given in API 520 Section 3.7.1 (7th Edition, January 2000)" + "\n" +
        "5) Superheat Correction Factor (Ksh):  Determined per Table 9 in API 520 Section 3.7.1 (7th Edition, January 2000)." + msg

      log.info("sizing_comments = #{sizing_comments}")
      @scenario_identification.rc_comments = sizing_comments

    elsif @scenario_identification.relief_capacity_calculation_method == "Two Phase HEM"
      log = CustomLogger.new('two_phase_hem')

      x = []
      y = []
      a = mda(10, 10)
      vapor_density = []
      pressure = []
      v = []
      press = []
      vapor_fraction = []
      liquid_fraction = []
      vapor_specific_volume = []
      liquid_density = []
      liquid_specific_volume = []
      two_phase_specific_volume = []
      two_phase_densityty = []
      average = []
      max_flux_square = []
      max_flux = []
      bi_section = []

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      p = @relief_device_sizing.system_design_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      p = uom[:factor] * p
      log.info("converted system_design_pressure = #{p}")

      _w = w = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      w = uom[:factor] * w
      log.info("converted rc_flow_rate = #{w}")

      p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      log.info("converted rc_total_back_pressure = #{p2}")

      over_pressure = ((((p1 - barometric_pressure) - p) / p) * 100).round(0)
      log.info("over_pressure = #{over_pressure}")
      back_pressure_percentage = ((p2 - barometric_pressure) / p) * 100
      log.info("back_pressure_percentage = #{back_pressure_percentage}")

      kb = 0
      log.info("rc_back_pressure_correction_factor_list = #{@scenario_identification.rc_back_pressure_correction_factor_list}")
      if @scenario_identification.rc_back_pressure_correction_factor_list == "API 520 Fig. 30"
        if over_pressure == 10
          if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
            kb = -0.0179 * back_pressure_percentage + 1.5829
          elsif back_pressure_percentage < 38 and back_pressure_percentage >= 30
            kb = (5 * 10**-6) * (back_pressure_percentage)**6 - 0.0009 * (back_pressure_percentage)**5 + 0.0781 * (back_pressure_percentage)**4 - 3.5019 * (back_pressure_percentage)**3 + 88.299 * (back_pressure_percentage)**2 - 1186.4 * (back_pressure_percentage) + 6637
          elsif back_pressure_percentage < 30
            kb = 1
          elsif back_pressure_percentage > 50
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% backpressure. The manufacturer should be contacted for Kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure == 16
          if back_pressure_percentage >= 38 and back_pressure_percentage <= 50
            kb = -0.0076 * back_pressure_percentage + 1.2837
          elsif back_pressure_percentage < 38
            kb = 1
          elsif back_pressure_percentage > 50
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% backpressure. The manufacturer should be contacted for kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure == 21
          if back_pressure_percentage < 50
            kb = 1
          else
            msg = "API 520 Back Pressure Correction Factor, Kb, is valid up to 50% backpressure. The manufacturer should be contacted for kb values above 50%."
            @alert_msg = msg
            @change_kb = true
            return
          end
        elsif over_pressure > 10 and over_pressure < 16
=begin
            126     Message = "The overpressure of " & Round(over_pressure, 0) & " % lies between the Back pressure Correction Factor (kb) correlation at 10% overpressure and 16% overpressure published in Fig 30 in API 520 .  The manufacturer should be contacted for kb values at this overpressure.  Click YES to enter a Back pressure Correction Factor (kb).  Click No to estimate a Back pressure Correction Factor (kb) based conservatively on the 10% overpressure correlation as published."
            127     Msg3 = MsgBox(Message, vbYesNo, "Backpressure Correction Factor (kb) Advisory!")
            128         if Msg3 = vbNo
            129             if back_pressure_percentage >= 38 And back_pressure_percentage <= 50
            130             kb = -0.0179 * back_pressure_percentage + 1.5829
            131             elsif back_pressure_percentage < 38 And back_pressure_percentage >= 30
            132             kb = -0.000539 * (back_pressure_percentage)**2 + 0.024256 * (back_pressure_percentage) + 0.756854
            133             elsif back_pressure_percentage < 30
            134             kb = 1
            135             elsif back_pressure_percentage > 50
            136             Msg = "API 520 Backpressure Correction Factor, kb, is valid up to 50% backpressure.  The manufacturer should be contacted for kb values above 50%.  For the purpose of this calculation a conservative kb value of 0.5 will be specified in the interim for the purpose of preliminary sizing of the relief device and pending verification with a manufacturer."
            137             Style = vbOKOnly
            138             Title = "Backpressure Correction Factor (kb) Advisory!"
            139             Message = MsgBox(Msg, Style, Title)
            140             kb = 0.5
            141             Else
            142             End if
            143         elsif Msg3 = vbYes
            144         kb = InputBox("Enter Back pressure Correction factor (kb) at overpressure of " & Round(over_pressure, 0) & " % and back pressure of " & Round(back_pressure_percentage, 0) & " %.", "User Enter Back pressure Correction Factor!")
            145         Else
            146         End if
=end
        elsif over_pressure > 16 and over_pressure < 21
=begin
            148     Message = "The overpressure of " & Round(over_pressure, 0) & "% lies between the Back pressure Correction Factor (kb) correlation at 16% overpressure and 21% overpressure published in Fig 30 in API 520 .  The manufacturer should be contacted for kb values at this overpressure.  Click YES to enter a Back pressure Correction Factor (kb).  Click No to estimate a Back pressure Correction Factor (kb) based conservatively on the 16% overpressure correlation as published."
            149     Msg3 = MsgBox(Message, vbYesNo, "Backpressure Correction Factor (kb) Advisory!")
            150         if Msg3 = vbNo
            151             if back_pressure_percentage >= 38 And back_pressure_percentage <= 50
            152             kb = -0.0076 * back_pressure_percentage + 1.2837
            153             elsif back_pressure_percentage < 38
            154             kb = 1
            155             elsif back_pressure_percentage > 50
            156             Msg = "API 520 Backpressure Correction Factor, kb, is valid up to 50% backpressure.  The manufacturer should be contacted for kb values above 50%.  For the purpose of this calculation a conservative kb value of 0.7 will be specified in the interim for the purpose of preliminary sizing of the relief device and pending verification with a manufacturer."
            157             Style = vbOKOnly
            158             Title = "Backpressure Correction Factor (kb) Advisory!"
            159             Message = MsgBox(Msg, Style, Title)
            160             kb = 0.7
            161             Else
            162             End if
            163         elsif Msg3 = vbYes
            164         kb = InputBox("Enter Back pressure Correction factor (kb) at overpressure of " & Round(over_pressure, 0) & " % and back pressure of " & Round(back_pressure_percentage, 0) & " %.", "User Enter Back pressure Correction Factor!")
            165         Else
            166         End if
=end
        else
=begin
            168         msg1 = "API 520 Backpressure Correction Factor, kb, is valid at 10%, 16% and 21% overpressure.  The manufacturer should be contacted for kb values at any other overpressure."
            169         Style = vbOKOnly
            170         Title = "Backpressure Correction Factor (kb) Advisory!"
            171         Message = MsgBox(msg1, Style, Title)
            172         kb = InputBox("Enter Back pressure Correction factor (kb) at overpressure of " & Round(over_pressure, 0) & " % and back pressure of " & Round(back_pressure_percentage, 0) & " %.", "User Enter Back pressure Correction Factor!")
=end
        end
      else
        kd = @scenario_identification.rc_back_pressure_correction_factor
      end

      log.info("kb = #{kb}")
      @scenario_identification.rc_back_pressure_correction_factor = kb

      kb = @scenario_identification.rc_back_pressure_correction_factor
      log.info("kb = #{kb}")
      kc = @scenario_identification.rc_combination_correction_factor
      log.info("kc = #{kc}")
      kd = @scenario_identification.rc_discharge_coefficient
      log.info("kd = #{kd}")

      order = 2 #equation order
      log.info("order = #{order}")
      n = 3 #number of datapoint
      log.info("n = #{n}")

      n_hash = {1 => 'a', 2 => 'b', 3 => 'c'}
                #Polynomial Regression For Mass Fraction
      log.info("Polynomial Regression For Mass Fraction")
      (1..order+1).each do |i|
        log.info("= i = #{i}")
        (1..i).each do |j|
          log.info("== j = #{j}")
          k = i + j - 2
          log.info("== k = #{k}")
          sum_x = 0
          log.info("== sum_x = #{sum_x}")
          (1..n).each do |l|
            log.info("=== l = #{l}")
            x[l] = @scenario_identification.send('hem_pressure_'+n_hash[l])
            uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
            x[l] = uom[:factor] * x[l]
            log.info("=== converted x[l] = #{x[l]}")
            sum_x = sum_x + (x[l])**k
            log.info("=== sum_x = #{sum_x}")
          end
          log.info("== sum_x = #{sum_x}")
          log.info("== i,j = #{i}, #{j}")
          a[i][j] = sum_x
          a[j][i] = sum_x
        end
        sum_y = 0
        log.info("= sum_y = #{sum_y}")

        (1..n).each do |l|
          log.info("== l = #{l}")
          y[l] = @scenario_identification.send('hem_mass_vapor_fraction_'+n_hash[l])
          log.info("== y[l]= #{y[l]}")
          sum_y = sum_y + (y[l] * x[l]**(i - 1))
          log.info("== sum_y= #{sum_y}")
        end
        log.info("= sum_y = #{sum_y}")
        log.info("= i, order+2 = #{i}, #{order+2}")
        a[i][order + 2] = sum_y
      end

      #Polynomial Regression For Liquid Density
      log.info("Polynomial Regression For Liquid Density")
      (1..order+1).each do |i|
        log.info("= i = #{i}")
        (1..i).each do |j|
          log.info("== j = #{j}")
          k = i + j - 2
          log.info("== k = #{k}")
          sum_u = 0
          (1..n).each do |l|
            log.info("=== l = #{l}")
            x[l] = @scenario_identification["hem_pressure_"+n_hash[l]]
            uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
            x[l] = uom[:factor] * x[l]
            log.info("=== x[l] = #{x[l]}")
            sum_u = sum_u + (x[l])**k
            log.info("=== sum_u = #{sum_u}")
          end
          log.info("== sum_u = #{sum_u}")
          log.info("== i,j = #{i}, #{j}")
          a[i][j] = sum_u
          a[j][i] = sum_u
        end

        sum_v = 0
        (1..n).each do |l|
          log.info("== l = #{l}")
          y[l] = @scenario_identification.send('hem_liquid_density_'+n_hash[l])
          uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
          y[l] = uom[:factor] * y[l]
          log.info("== y[l] = #{y[l]}")

          sum_v = sum_v + (y[l] * x[l]**(i - 1))
          log.info("== sum_v = #{sum_v}")
        end

        log.info("= sum_v = #{sum_v}")
        log.info("= i, order+2 = #{i}, #{order+2}")
        a[i][order + 2] = sum_v
      end

      #Specific Volume Empirical Fitting Equation using Bisectional Method
      log.info("Specific Volume Empirical Fitting Equation using Bisectional Method")
      (1..3).each do |i|
        log.info("= i = #{i}")
        pressure[i] = @scenario_identification.send('hem_pressure_'+n_hash[i])
        uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
        pressure[i] = uom[:factor] * pressure[i]
        log.info("= pressure[i] = #{pressure[i]}")

        vapor_density[i] = @scenario_identification["hem_vapor_density_"+n_hash[i]]
        uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
        vapor_density[i] = uom[:factor] * vapor_density[i]
        log.info("= vapor_density[i] = #{vapor_density[i]}")

        v[i] = 1 / vapor_density[i]
        log.info("= v[i] = #{v[i]}")
        #TODO
        #176 Worksheets("Two Phase - HEM").Cells(3 + i, 65).Value = pressure[i]
        #177 Worksheets("Two Phase - HEM").Cells(3 + i, 66).Value = v[i]
      end

      #TODO
=begin
        180 'Goal Seek Function
        181 Worksheets("Two Phase - HEM").Cells(12, 65).Value = 1
        182 Worksheets("Two Phase - HEM").Range("BM11").GoalSeek Goal:=0, ChangingCell:=Worksheets("Two Phase - HEM").Range("BM12")
        183 beta = Worksheets("Two Phase - HEM").Cells(12, 65).Value
        184 alpha = Worksheets("Two Phase - HEM").Cells(13, 65).Value
=end
      #TODO
=begin
        199 ' Calculated Max Flux G
        200 mfa0 = Worksheets("Two Phase - HEM").Cells(27, 59).Value
        201 mfa1 = Worksheets("Two Phase - HEM").Cells(28, 59).Value
        202 mfa2 = Worksheets("Two Phase - HEM").Cells(29, 59).Value
        203 lda0 = Worksheets("Two Phase - HEM").Cells(31, 59).Value
        204 lda1 = Worksheets("Two Phase - HEM").Cells(32, 59).Value
        205 lda2 = Worksheets("Two Phase - HEM").Cells(33, 59).Value
=end

      vapor_den = @scenario_identification.hem_vapor_density_a
      uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
      vapor_den = uom[:factor] * vapor_den
      log.info("converted hem_vapor_density_a = #{vapor_den}")

      liquid_den = @scenario_identification.hem_liquid_density_a
      uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
      liquid_den = uom[:factor] * liquid_den
      log.info("converted hem_liquid_density_a = #{liquid_den}")

      vapor_specific_volume[0] = 1 / vapor_den
      log.info("vapor_specific_volume[0] = #{vapor_specific_volume[0]}")
      liquid_specific_volume[0] = 1 / liquid_den
      log.info("liquid_specific_volume[0] = #{liquid_specific_volume[0]}")
      vapor_fraction[0] = @scenario_identification.hem_mass_vapor_fraction_a
      log.info("vapor_fraction[0] = #{vapor_fraction[0]}")
      liquid_fraction[0] = 1 - vapor_fraction[0]
      log.info("liquid_fraction[0] = #{liquid_fraction[0]}")

      press[0] = @scenario_identification.hem_pressure_a
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
      press[0] = uom[:factor] * press[0]
      log.info("converted press[0] = #{press[0]}")

      log.info("(press[0] / 0.1) - 0.1) = #{(press[0] / 0.1) - 0.1}")
      (1..((press[0] / 0.1) - 0.1)).each do |i|
        press[i] = press[0] - (i * 0.1)
        vapor_fraction[i] = mfa2 * press[i]**2 + mfa1 * press[i] + mfa0
        liquid_fraction[i] = 1 - vapor_fraction[i]
        vapor_specific_volume[i] = ((alpha * ((press[0] / press[i])**beta - 1)) + 1) * vapor_specific_volume[0]
        liquid_density[i] = lda2 * press[i]**2 + lda1 * press[i] + lda0
        liquid_specific_volume[i] = 1 / liquid_density[i]
        two_phase_specific_volume[0] = (vapor_fraction[0] * vapor_specific_volume[0]) + (liquid_fraction[0] * liquid_specific_volume[0])
        two_phase_specific_volume[i] = (vapor_fraction[i] * vapor_specific_volume[i]) + (liquid_fraction[i] * liquid_specific_volume[i])
        two_phase_density[i] = 1 / two_phase_specific_volume[i]
        average[0] = 0
        average[i] = average[i - 1] + (-2 * ((two_phase_specific_volume[i] + two_phase_specific_volume[i - 1]) / 2) * (press[i] - press[i - 1]))
        max_flux_square[i] = average[i] / two_phase_specific_volume[i]**2
        if vapor_fraction[i] > 0
          max_flux[0] = 0
          max_flux[i] = (3600 / 144) * (32.174 * 144 * max_flux_square[i])**0.5
          if max_flux[i] < max_flux[i - 1]
            maximum_flux = max_flux[i - 1]
            i = ((press[0] / 0.1) - 0.1)
          elsif max_flux[i] > max_flux[i - 1]
            maximum_flux = max_flux[i]
          end
          #TODO
          #259 Worksheets("Two Phase - HEM").Cells(26 + i, 64).Value = press[i]
          #260 Worksheets("Two Phase - HEM").Cells(26 + i, 65).Value = max_flux[i]
        end
      end

      uom = @project.base_unit_cf(:mtype => 'Mass Flux', :msub_type => 'General')
      maximum_flux = uom[:factor] * maximum_flux
      log.info("converted maximum_flux = #{maximum_flux}")

      @scenario_identification.rc_maximum_mass_flux = maximum_flux

      #Determined Relief Capacity
      area = w / (maximum_flux * kb * kc * kd)
      log.info("area = #{area}")
      @scenario_identification.rc_effective_discharge_area = area

      #Add comments
      scenario = @scenario_summary.scenario
      log.info("scenario = #{scenario}")
      identifier = @scenario_summary.identifier
      log.info("identifier = #{identifier}")

      kc_comments = ""
      if kc >= 1
        kc_comments = "No rupture disk present on the inlet to the relief device."
      elsif kc < 1
        kc_comments = "Project specified value (in accordance with ASME VIII) to account for the presence of an inlet rupture disk."
      end
      log.info("kc_comments = #{kc_comments}")

      cmbkb = @scenario_identification.rc_back_pressure_correction_factor_list
      if @scenario_identification.rc_back_pressure_correction_factor_list == "Estimated"
        cmbkb = "estimation"
      end
      log.info("cmbkb = #{cmbkb}")

      area_unit = @project.unit 'Area', 'Orifice'
      wunit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      maximum_flux_unit = @project.unit 'Mass Flux', 'General'

      sizing_comments = "The required relief area for the " + scenario + " - " + identifier + " scenario is determined to be " + area.round(2).to_s + " " + area_unit + " at the relief rate of " + _w.round(1).to_s + " " + wunit + ", based on procedures and equations provided in Larry L. Simpson's 'Navigating the Two-Phase Maze', presented in the publication of the August 2-4 1995 International Symposium On Runaway Reactions and pressure Relief Design (Pages 394-417). With this methodology, 3 points representing the conditions along the pressure profile" +
        " was selected to serve as a representative basis to determine physical properties along the entire pressure profile. The 3 points are typically (but not necessarily) the conditions at relief, conditions at choke and conditions at discharge. Based on the selections, a model is developed to determine the fluid specific volume from which a profile of the mass flux over a pressure range is developed. The maximum mass flux (" + maximum_flux.round[0].to_s + " " + maximum_flux_unit + " is used to determine the required relief area. Note that this preliminary sizing does not include the effects of inlet and outlet pressure drops which may increase the required relief area. The following correction factors were determined as such:" + "\n" + "\n" +
        "1) Back pressure Correction Factor (kb):  Obtained from " + cmbkb + ". " + msg1 + "\n" +
        "2) Combination Correction Factor (Kc):  " + kc_comments + "\n" +
        "3) Discharge Coefficient (Kd):  Project specified value for two phase sizing." + "\n"

      log.info("sizing_comments = #{sizing_comments}")
      @scenario_identification.rc_comments = sizing_comments

    elsif @scenario_identification.relief_capacity_calculation_method == "Low Pressure Vent"
      log = CustomLogger.new('low_pressure_vent')

      q = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      q = uom[:factor] * q
      log.info("converted rc_flow_rate = #{q}")

      p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      log.info("converted rc_total_back_pressure = #{p2}")

      t = @scenario_identification.rc_relieving_temperature
      uom = @project.measure_unit('Temperature', 'General')
      t = t.send(uom[:unit_name].downcase.to_sym).to.fahrenheit
      log.info("converted rc_relieving_temperature = #{p2}")

      mw = @scenario_identification.rc_vapor_mw
      log.info("mw = #{mw}")
      z = @scenario_identification.rc_vapor_z
      log.info("z = #{z}")
      cp_cv = @scenario_identification.rc_vapor_k
      log.info("cp_cv = #{cp_cv}")

      log.info("rc_discharge_coefficient_list = #{@scenario_identification.rc_discharge_coefficient_list}")
      if @scenario_identification.rc_discharge_coefficient_list == "API 2000 4.6.1.2.3"
        kd = 0.5
        @scenario_identification.rc_discharge_coefficient = kd
      end

      kd = @scenario_identification.rc_discharge_coefficient
      log.info("rc_discharge_coefficient kd = #{kd}")

      part1 = ((p2 / p1)**(2 / k)) - ((p2 / p1)**((k + 1) / k))
      log.info("part1 = #{part1}")
      part2 = k / (mw * (t + 460) * z * (k - 1))
      log.info("part2 = #{part2}")
      a = (q) / (kd * 278700 * p1 * (part1 * part2)**0.5)
      log.info("a = #{a}")

      pi = Math::PI

      d = 2 * (a / pi)**0.5
      log.info("d = #{d}")

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      a = a * uom[:factor]
      log.info("converted a = #{a}")

      uom = @project.base_unit_cf(:mtype => 'Length', :msub_type => 'Small Dimension Length')
      d = d * uom[:factor]
      log.info("converted d = #{d}")

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      scenario = @scenario_summary.scenario
      log.info("scenario = #{scenario}")
      identifier = @scenario_summary.identifier
      log.info("identifier = #{identifier}")

      aunit = @project.unit 'Area', 'Orifice'
      qunit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      p2unit = @project.unit 'Pressure', 'Absolute'

      sizing_comments = "The required relief area for the " + scenario + " - " + identifier + " scenario is determined to be " + a.round(2).to_s + " " + aunit + " at the relief rate of " + _q.round(1).to_s + " " + qunit & ", based on equation 4A in API 2000 Section 4.6.1.2 (5th Edition, April 1998). The driving force is the pressure differential across the relief device. The pressure differential is based on the relief pressure of " + _p1.round(1).to_s + " " + p1unit + " and the constant back pressure of " + _p2.round(1).to_s + " " + p2unit + ". Note that this preliminary sizing does not include the effects of inlet and outlet pressure drops which may increase the required relief area. The following correction factor was determined as such:" + "\n" + "\n" +
        "1) Discharge Coefficient (Kd): Project specified value for vapor sizing for manhole cover at full lift, based on API 2000 Section 4.6.1.2.3 (5th Edition, April 1998)."

      log.info("sizing_comments = #{sizing_comments}")

      @scenario_identification.rc_comments = sizing_comments
    elsif @scenario_identification.relief_capacity_calculation_method == "Line Capacity"
      log = CustomLogger.new('line_capacity')

      f = []
      nre = []
      alpha = []
      pipe_id = []
      kfi = []
      elev = []
      length = []
      flow_rate = []
      relief_flow_rate = []
      g = []
      area = []
      nma1 = []

      barometric_pressure = @project.barometric_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure = uom[:factor] * barometric_pressure
      log.info("converted barometric_pressure = #{barometric_pressure}")

      pi = Math::PI

      #TODO
=begin
      34  'Counting number of fittings in system
      35  For j = 1 To 50
      36      If Worksheets("Line Capacity").Cells(30 + j, 3).Value <> "" Then
      37      Count = j
      38      Else
      39      End If
      40  Next j

      42  'Determine the pipe inner diameter for each fitting
      43  For jj = 1 To Count
      44  PipeSize = Worksheets("Line Capacity").Cells(30 + jj, 19).Value
      45  PipeSchedule = Worksheets("Line Capacity").Cells(30 + jj, 21).Value
      516     If PipeSize = "" Or PipeSchedule = "" Then
      517     Else
      46      Call DeterminePipeDiameter(PipeSize, PipeSchedule, PipeD)                   'Module 5
      47      Worksheets("Line Capacity").Cells(30 + jj, 24).Value = PipeD
      518     End If
      48  Next jj
=end

      relief = @scenario_identification.rc_flow_rate
      uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
      relief = uom[:factor] * relief
      log.info("converted rc_flow_rate = #{relief}")

      p1 = @scenario_identification.rc_relieving_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p1 = uom[:factor] * p1
      log.info("converted rc_relieving_pressure = #{p1}")

      p2 = @scenario_identification.rc_total_back_pressure
      uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      p2 = uom[:factor] * p2
      log.info("converted rc_total_back_pressure = #{p2}")

      t = @scenario_identification.rc_relieving_temperature
      uom = @project.measure_unit('Temperature', 'General')
      t = t.send(uom[:unit_name].downcase.to_sym).to.fahrenheit
      log.info("converted rc_relieving_temperature = #{p2}")

      #TODO
=begin
      99  If Worksheets("Line Capacity").Cells(15, 10).Value <> "" Then
      100 ReliefPhase = Worksheets("Line Capacity").Cells(15, 10).Value
      101 Else
      102 msg1 = MsgBox("No value entered for the relief phase.  Please enter a value for the relief phase.", vbOKOnly, "No Value Entered For The relief Phase!")
      103 Exit Sub
      104 End If
      105
      106 If Worksheets("Line Capacity").Cells(16, 10).Value <> "" Then
      107 vapor_fraction = Worksheets("Line Capacity").Cells(16, 10).Value + 0
      108 Else
      109 msg1 = MsgBox("No value entered for the vapor fraction.  Please enter a value for the vapor fraction.", vbOKOnly, "No Value Entered For The Vapor Fraction!")
      110 Exit Sub
      111 End If
=end

      e = @scenario_identification.rc_pipe_roughness
      uom = @project.base_unit_cf(:mtype => 'Length', :msub_type => 'Small Dimension Length')
      e = uom[:factor] * e
      log.info("converted rc_pipe_roughness = #{e}")

      #TODO
=begin
      125 If Worksheets("Line Capacity").chkRuptureDisk.Value = True Then
      126     If Worksheets("Line Capacity").RDKr.Value <> Empty Then
      127     Kr = Worksheets("Line Capacity").RDKr.Value + 0
      128     Else
      129     msg1 = MsgBox("No value entered for the maximum flow resistance for a rupture disk.  Please enter a value for the maximum flow resistance for a rupture disk.", vbOKOnly, "No Value Entered For Maximum Flow Resistance For Rupture Disk, Kr!")
      130     Exit Sub
      131     End If
      132 Else
      133 End If

      135 If Worksheets("Line Capacity").txtUncertaintyFactor.Value <> Empty Then
      136 uncertainty_f = Worksheets("Line Capacity").txtUncertaintyFactor.Value + 0
      137 Else
      138 msg1 = MsgBox("No value entered for the uncertainty factor for a rupture disk.  Please enter a value for the uncertainty factor for a rupture disk.", vbOKOnly, "No Value Entered For Uncertainty Factor For Rupture Disk!")
      139 Exit Sub
      140 End If
=end

      relief_rate = relief / uncertainty_f
      log.info("relief_rate = #{relief_rate}")

      #Determine diameter for liquid flow
      if relief_phase == "Liquid"
        density1 = @scenario_identification.rc_liquid_density
        uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
        density1 = uom[:factor] * density1
        log.info("converted density1 = #{density1}")

        viscosity = @scenario_identification.rc_liquid_viscosity
        uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
        viscosity = uom[:factor] * viscosity
        log.info("converted viscosity = #{viscosity}")

        #TODO
=begin
        171 'Using equation 7-51 to determine first pass nre and Diameter assuming no fittings
        172 'Check for reverse driven force
        173 If p1 <= P2 Then
        174 msg1 = MsgBox("The downstream pressure is equal to or exceeds the upstream pressure, therefore there is no driving force to drive relief flow through the piping configuration from the system. Please review the upstream and downstream pressures.  The calculation will now be terminated.", vbOKOnly, "Reverse Flow Encountered!")
        175 Exit Sub
        176 Else
        177 End If
=end
        #Determine Pressure Energy, PE
        pe = ((p2 - p1) / density1) * 144 #Unit is lbf-ft/lbm
        log.info("pe = #{pe}")

        #TODO
        #Determine Potential Energy, HE
        log.info("Determine Potential Energy, HE")
        sum_elevation = 0
        sum_length = 0
        (1..count).each do |n|
          log.info("= n = #{n}")
          #elev[n] = Worksheets("Line Capacity").Cells(30 + n, 36).Value
          sum_elevation = sum_elevation + elev[n]
          log.info("= sum_elevation = #{sum_elevation}")
          #length[n] = Worksheets("Line Capacity").Cells(30 + n, 33).Value
          sum_length = sum_length + length(n)
          log.info("= sum_length = #{sum_length}")
        end

        uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
        sum_elevation = uom[:factor] * sum_elevation
        log.info("converted sum_elevation = #{sum_elevation}")

        uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
        sum_length = uom[:factor] * sum_length
        log.info("converted sum_length = #{sum_length}")

        he = sum_elevation #Unit is lbf-ft/lbm
        log.info("he = #{he}")

        #Determine Work Done, W
        w = 0 #Unit is lbf-ft/lbm
        log.info("w = #{w}")

        #Determine Heat Input, Q
        q = 0 #Unit is lbf-ft/lbm
        log.info("w = #{w}")

        #Determine Driving Force, DF       ' Unit is lbf-ft/lbm
        df = -(pe + he + w + q)
        log.info("df = #{df}")

        #Determine if there is enough energy to overcome liquid head in the system
        if pe.abs <= he
          msg1 = "The liquid head for the piping is equal to or exceeds the pressure energy driving the flow, therefore driving force is not sufficient to drive liquid flow through the piping configuration. Please update the proposed piping configuration. The calculation will now be terminated."
          @alert_msg = msg1
          return
        end

        volume_rate = relief_rate / density1
        log.info("df = #{df}")
        nre[0] = ((1.03892 * 10**9 * df * density1**5 * volume_rate**3) / (sum_length * viscosity**5))**(1 / 5)
        log.info("nre[0] = #{nre[0]}")
        pipe_id[0] = (6.316 * volume_rate * density1) / (viscosity * nre[0]) #in
        log.info("pipe_id[0] = #{pipe_id[0]}")

        #Reseting kfi_sum and KfdSum for new k run
        log.info("Reseting kfi_sum and KfdSum for new k run")
        (1..100).each do |k|
          log.info("= k = #{k}")
          kfi_sum = 0
          log.info("= kfi_sum = #{kfi_sum}")
          sum_elevation = 0
          log.info("= sum_elevation = #{sum_elevation}")

          (1..count).each do |m|
            log.info("== m = #{m}")
            #length(m) = Worksheets("Line Capacity").Cells(30 + m, 33).Value
            uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
            length[m] = uom[:factor] * length[m]
            log.info("== length[m] = #{length[m]}")

            nre[k - 1] = (6.316 * relief_rate) / (pipe_id[k - 1] * viscosity)
            log.info("== nre[k - 1] = #{nre[k - 1]}")

            #Determine new friction factor using Churchill's equation
            a = (2.457 * Math.log(1 / (((7 / nre[k - 1])**0.9) + (0.27 * (e / pipe_id[k - 1])))))**16
            log.info("== a = #{a}")
            b = (37530 / nre[k - 1])**16
            log.info("== b = #{b}")
            f[k] = 2 * ((8 / nre[k - 1])**12 + (1 / ([a + b]**(3 / 2))))**(1 / 12)
            log.info("== f[k] = #{f[k]}")

            n_reynolds = nre[k - 1]
            log.info("== n_reynolds = #{n_reynolds}")
            d = pipe_id[k - 1]
            log.info("== d = #{d}")
            #fitting_type = Worksheets("Line Capacity").Cells(30 + m, 3).Value
            log.info("== fitting_type = #{fitting_type}")
            if fitting_type == "Pipe"
              kf = 4 * f[k] * (length[m] / (pipe_id[k - 1] / 12))
              log.info("== kf = #{kf}")
            else
              #Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)                         'module 7
            end
            kfi[m] = kf
            log.info("== kfi[m] = #{kfi[m]}")
            kfi_sum = kfi_sum + kfi[m]
            log.info("== kfi_sum = #{kfi_sum}")
          end

          #Determine new diameter
          pipe_id[k] = 12 * (((1.94393 * 10**-9) * volume_rate**2 * kfi_sum) / df)**(1 / 4)
          log.info("== kfi_sum = #{kfi_sum}")
          rupture_diameter = pipe_id[k]
          log.info("== kfi_sum = #{kfi_sum}")

          if pipe_id[k - 1] == pipe_id[k]
            rupture_diameter = pipe_id[k - 1]
            log.info("== rupture_diameter = #{rupture_diameter}")
            k = 100
            log.info("== k = #{k}")
          end
        end

      elsif relief_phase == "Vapor"

        density = @scenario_identification.rc_vapor_density
        uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
        density = uom[:factor] * density
        log.info("converted density = #{density}")

        viscosity = @scenario_identification.rc_vapor_viscosity
        uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
        viscosity = uom[:factor] * viscosity
        log.info("converted viscosity = #{viscosity}")

        vapor_mw = @scenario_identification.rc_vapor_mw
        log.info("vapor_mw = #{vapor_mw}")
        vapor_k = @scenario_identification.rc_vapor_k
        log.info("vapor_k = #{vapor_k}")
        vapor_z = @scenario_identification.rc_vapor_z
        log.info("vapor_z = #{vapor_z}")

        #Assume Sonic Flow
        nma1[0] = 1
        log.info("nma1[0] = #{nma1[0]}")
        g[0] = 519.5 * nma1[0] * p1 * ((vapor_k * vapor_mw) / (t + 459.57))**0.5
        log.info("g[0] = #{g[0]}")

        (1..100).each do |k|
          log.info("= k = #{k}")
          pipe_id[k] = 1.12838 * (relief_rate / g[k - 1])**0.5
          log.info("= pipe_id[k] = #{pipe_id[k]}")
          area[k] = pi * (pipe_id[k] / 2)**2
          log.info("= area[k] = #{area[k]}")
          relief_flow_rate[0] = g[k - 1] * area[k]
          log.info("= relief_flow_rate[0] = #{relief_flow_rate[0]}")
          nre[k] = (4.96055 * pipe_id[k] * g[k - 1]) / viscosity
          log.info("= nre[k] = #{nre[k]}")

          kfi_sum = 0
          (1..count).each do |m|
            log.info("== m = #{m}")
            #TODO
            #length(m) = Worksheets("Line Capacity").Cells(30 + m, 33).Value
            uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
            length[m] = uom[:factor] * length[m]
            log.info("== length[m] = #{length[m]}")

            #Determine new friction factor using Churchill's equation
            a = (2.457 * Math.log(1 / (((7 / nre[k])**0.9) + (0.27 * (e / pipe_id[k])))))**16
            log.info("== a = #{a}")
            b = (37530 / nre[k])**16
            log.info("== b = #{b}")
            f[k] = 2 * ((8 / nre[k])**12 + (1 / ((a + b)**(3 / 2))))**(1 / 12)
            log.info("== f[k] = #{f[k]}")

            fd = 4 * f[k]
            log.info("== fd = #{fd}")
            n_reynolds = nre[k]
            log.info("== n_reynolds = #{n_reynolds}")
            d = pipe_id[k]
            log.info("== d = #{d}")

            #TODO
            fitting_type = Worksheets("Line Capacity").Cells(30 + m, 3).Value
            log.info("== fitting_type = #{fitting_type}")

            if fitting_type == "Pipe"
              kf = 4 * f[k] * (length[m] / (pipe_id[k] / 12))
              log.info("== kf = #{kf}")
            else
              #Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)                       'Module 7
            end

            kfi[m] = kf
            log.info("== kfi[m] = #{kfi[m]}")
            kfi_sum = kfi_sum + kfi[m]
            log.info("== kfi_sum = #{kfi_sum}")
          end

          #Check for choked flow
          if p2 > barometric_pressure
            criteria = 0.5
            log.info("== criteria = #{criteria}")
          elsif p2 == barometric_pressure
            criteria = 2
            log.info("== criteria = #{criteria}")
          end

          log.info("== vapor_flow_model = #{@project.vapor_flow_model}")
          if @project.vapor_flow_model == "Isothermal"
            (1..1000).each do |r|
              log.info("== r = #{r}")
              p2_critical = p1 - ((0.001 * r) * p1)
              log.info("== p2_critical = #{p2_critical}")
              part1 = (p1 / p2_critical)**2
              log.info("== part1 = #{part1}")
              part2 = 2 * Math.log(p1 / p2_critical)
              log.info("== part2 = #{part2}")
              isothermal_choke_kf = part1 - part2 - 1
              log.info("== isothermal_choke_kf = #{isothermal_choke_kf}")
              percent_diff = (abs(kfi_sum - isothermal_choke_kf) / kfi_sum) * 100
              log.info("== percent_diff = #{percent_diff}")
              if percent_diff < criteria
                r = 1000
                log.info("== r = #{r}")
              end
            end
          elsif @project.vapor_flow_model == "Adiabatic"
            (1..1000).each do |r|
              log.info("== r = #{r}")
              p2_critical = p1 - ((0.001 * r) * p1)
              log.info("== p2_critical = #{p2_critical}")
              part1 = 2 / (vapor_k + 1)
              log.info("== part1 = #{part1}")
              part2 = ((p1 / p2_critical)**((vapor_k + 1) / vapor_k)) - 1
              log.info("== part2 = #{part2}")
              part3 = (2 / vapor_k) * Math.log(p1 / p2_critical)
              log.info("== part3 = #{part3}")
              adiabatic_choke_kf = (part1 * part2) - part3
              log.info("== adiabatic_choke_kf = #{adiabatic_choke_kf}")
              percent_diff = (abs(kfi_sum - adiabatic_choke_kf) / kfi_sum) * 100
              log.info("== percent_diff = #{percent_diff}")
              if percent_diff < criteria
                r = 1000
                log.info("== r = #{r}")
              end
            end
          end

          log.info("== vapor_flow_model = #{@project.vapor_flow_model}")
          if @project.vapor_flow_model == "Isothermal"
            log.info("== p2_critical > p2 = #{p2_critical > p2}")
            if p2_critical > p2
              part1 = p1 * (p2_critical / p1)
              log.info("== p2_critical > p2 = #{p2_critical > p2}")
              part2 = (vapor_mw / (t + 459.69))**0.5
              log.info("== part2 = #{part2}")
              g_critical = 519.5 * part1 * part2
              log.info("== g_critical = #{g_critical}")
              g[k] = g_critical
              log.info("== g[k] = #{g[k]}")
            else
              part1 = (134933 * vapor_mw * (p1**2 - p2**2)) / (t + 459.67)
              log.info("== part1 = #{part1}")
              part2 = kfi_sum / 2
              log.info("== part2 = #{part2}")
              part3 = Math.log(p1 / p2)
              log.info("== part3 = #{part3}")
              g[k] = (part1 / (part2 + part3))**0.5
              log.info("== g[k] = #{g[k]}")
            end
          elsif @project.vapor_flow_model == "Adiabatic"
            log.info("== p2_critical > p2 = #{p2_critical > p2}")
            if p2_critical > p2
              part1 = ((1 / (6.443 * 10**11)) * vapor_k * vapor_mw) / (t + 459.69)
              log.info("== part1 = #{part1}")
              part2 = (p2_critical / p1)**((vapor_k + 1) / vapor_k)
              log.info("== part2 = #{part2}")
              g_critical = (4.16975 * 10**8) * p1 * (part1 * part2)**0.5
              log.info("== g_critical = #{g_critical}")
              g[k] = g_critical
              log.info("== g[k] = #{g[k]}")
            else
              part1 = vapor_k / (vapor_k + 1)
              log.info("== part1 = #{part1}")
              part2 = (269866 * (p1**2 * vapor_mw) / (t + 459.67))
              log.info("== part2 = #{part2}")
              part3 = 1 - ((p2 / p1)**((vapor_k + 1) / vapor_k))
              log.info("== part3 = #{part3}")
              part4 = kfi_sum / 2
              log.info("== part4 = #{part4}")
              part5 = (Math.log(p1 / p2)) / vapor_k
              log.info("== part5 = #{part5}")
              g[k] = ((part1 * part2 * part3) / (part4 + part5))**(0.5)
              log.info("== part5 = #{part5}")
            end
          end

          pipe_id[k] = 1.12838 * (relief_rate / g[k])**0.5
          log.info("== pipe_id[k] = #{pipe_id[k]}")

          if pipe_id[k] == pipe_id[k - 1]
            rupture_diameter = pipe_id[k]
            log.info("== rupture_diameter = #{rupture_diameter}")
            k = 100
            log.info("== k = #{k}")
          elsif pipe_id[k] == pipe_id[k - 2]
            rupture_diameter = pipe_id[k]
            log.info("== rupture_diameter = #{rupture_diameter}")
            k = 100
            log.info("== k = #{k}")
          end
        end
      elsif relief_phase == "Two Phase"

        f = mda(100, 100)
        two_phase_nre = []
        nre = mda(100, 100)
        pipe_id = []
        kfi = [[], []]
        kfd = [[], []]
        elev = []
        outlet_nre = []
        g = [[], []]
        pipe_count_id = []
        x = []
        y = []
        a = [[], []]
        vapor_density = []
        pressure = []
        v = []
        press = []
        press1 = []
        vapor_fraction = []
        liquid_fraction = []
        vapor_specific_volume = []
        liquid_density = []
        liquid_specific_volume = []
        two_phase_specific_volume = []
        two_phase_density = []
        average = []
        max_flux_square = []
        max_flux = []
        bi_section = []
        liquid_viscosity = []
        vapor_viscosity = []
        two_phase_viscosity = []
        delta_pipe_length = []
        original_press = []
        original_vapor_specific_volume = []
        original_liquid_viscosity = []
        pressure_relief_valve_tag = []
        rupture_disk_tag = []

        order = 2 #equation order
        log.info("order = #{order}")
        n = 3 #number of datapoint
        log.info("n = #{n}")

        #Polynomial Regression For Mass Fraction
        log.info("Polynomial Regression For Mass Fraction")
        (1..order+1).each do |i|
          log.info("= i = #{i}")
          (1..i).each do |j|
            log.info("== j = #{j}")
            k = i + j - 2
            log.info("== k = #{k}")
            sum_x = 0
            log.info("== sum_x = #{sum_x}")
            (1..n).each do |l|
              log.info("=== l = #{l}")
              x[1] = @scenario_identification.hem_pressure_a
              log.info("=== x[1] = #{x[1]}")
              x[2] = @scenario_identification.hem_pressure_b
              log.info("=== x[2] = #{x[2]}")
              x[3] = @scenario_identification.hem_pressure_c
              log.info("=== x[3] = #{x[3]}")

              uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
              x[l] = uom[:factor] * x[l]
              log.info("=== x[l] = #{x[l]}")

              sum_x = sum_x + (x[l])**k
              log.info("=== sum_x = #{sum_x}")
            end
            log.info("== i, j = #{i}, #{j}")
            log.info("== sum_x = #{sum_x}")
            a[i][j] = sum_x
            a[j][i] = sum_x
          end

          sum_y = 0
          (1..n).each do |l|
            log.info("== l = #{l}")
            y[1] = @scenario_identification.hem_mass_vapor_fraction_a
            log.info("== y[1] = #{y[1]}")
            y[2] = @scenario_identification.hem_mass_vapor_fraction_b
            log.info("== y[2] = #{y[2]}")
            y[3] = @scenario_identification.hem_mass_vapor_fraction_c
            log.info("== y[3] = #{y[3]}")
            sum_y = sum_y + (y[l] * x[l]**(i - 1))
            log.info("== sum_y = #{sum_y}")
          end
          log.info("= i, order+2 = #{i}, #{order+2}")
          log.info("= sum_y = #{sum_y}")
          a[i][order+2] = sum_y
        end

        #Polynomial Regression For Liquid Density
        log.info("Polynomial Regression For Liquid Density")
        (i..(order+1)).each do |i|
          log.info("= i = #{i}")
          (1..i).each do |j|
            log.info("== j = #{j}")
            k = i + j - 2
            log.info("== k = #{k}")
            sum_u = 0
            log.info("== sum_u = #{sum_u}")
            (1..n).each do |l|
              log.info("=== l = #{l}")
              x[1] = @scenario_identification.hem_pressure_a
              log.info("=== x[1] = #{x[1]}")
              x[2] = @scenario_identification.hem_pressure_b
              log.info("=== x[2] = #{x[2]}")
              x[3] = @scenario_identification.hem_pressure_c
              log.info("=== x[3] = #{x[3]}")
              uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
              x[l] = uom[:factor] * x[l]
              log.info("=== x[l] = #{x[l]}")

              sum_u = sum_u + (x[l])**k
              log.info("=== sum_u = #{sum_u}")
            end
            log.info("== i,j = #{i}, #{j}")
            log.info("== sum_u = #{sum_u}")
            a[i][j] = sum_u
            a[j][i] = sum_u
          end

          sum_v = 0
          log.info("= sum_v = #{sum_v}")
          (1..n).each do |l|
            log.info("== l = #{l}")
            y[1] = @scenario_identification.hem_liquid_density_a
            log.info("== y[1] = #{y[1]}")
            y[2] = @scenario_identification.hem_liquid_density_b
            log.info("== y[2] = #{y[2]}")
            y[3] = @scenario_identification.hem_liquid_density_c
            log.info("== y[3] = #{y[3]}")
            uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
            y[l] = uom[:factor] * y[l]
            log.info("== y[l] = #{y[l]}")

            sum_v = sum_v + (y[l] * x[l]**(i - 1))
            log.info("== sum_v = #{sum_v}")
          end
          log.info("= i, order+2 = #{i}, #{order+2}")
          log.info("= sum_v = #{sum_v}")
          a[i][order + 2] = sum_v
        end

        #Specific Volume Empirical Fitting Equation using Bisectional Method
        log.info("Specific Volume Empirical Fitting Equation using Bisectional Method")
        (1..3).each do |i|
          log.info("= i = #{i}")
          pressure[1] = @scenario_identification.hem_pressure_a
          log.info("= pressure[1] = #{pressure[1]}")
          pressure[2] = @scenario_identification.hem_pressure_b
          log.info("= pressure[2] = #{pressure[2]}")
          pressure[3] = @scenario_identification.hem_pressure_c
          log.info("= pressure[3] = #{pressure[3]}")

          uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
          pressure[i] = uom[:factor] * pressure[i]
          log.info("= converted pressure[i] = #{pressure[i]}")

          vapor_density[1] = @scenario_identification.hem_vapor_density_a
          log.info("= vapor_density[1] = #{vapor_density[1]}")
          vapor_density[2] = @scenario_identification.hem_vapor_density_a
          log.info("= vapor_density[2] = #{vapor_density[2]}")
          vapor_density[3] = @scenario_identification.hem_vapor_density_a
          log.info("= vapor_density[3] = #{vapor_density[3]}")

          uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
          vapor_density[i] = uom[:factor] * vapor_density[i]
          log.info("= converted vapor_density[i] = #{vapor_density[i]}")

          v[i] = 1 / vapor_density[i]
          log.info("= v[i] = #{v[i]}")
=begin
Worksheets("Two Phase Hydraulic").Cells(3 + i, 50).Value = Pressure[i]
Worksheets("Two Phase Hydraulic").Cells(3 + i, 51).Value = V[i]
=end
        end


        #Goal Seek Function
=begin
Worksheets("Two Phase Hydraulic").Cells(12, 50).Value = 1
Worksheets("Two Phase Hydraulic").Range("AX11").GoalSeek Goal:=0, ChangingCell:=Worksheets("Two Phase Hydraulic").Range("AX12")
beta = Worksheets("Two Phase Hydraulic").Cells(12, 50).Value
alpha = Worksheets("Two Phase Hydraulic").Cells(13, 50).Value
=end

        #Liquid Viscosity Empirical Fitting Equation using Bisectional Method
        log.info("Liquid Viscosity Empirical Fitting Equation using Bisectional Method")
        (1..3).each do |i|
          log.info("= i = #{i}")
          pressure[1] = @scenario_identification.hem_pressure_a
          log.info("= pressure[1] = #{pressure[1]}")
          pressure[2] = @scenario_identification.hem_pressure_b
          log.info("= pressure[2] = #{pressure[2]}")
          pressure[3] = @scenario_identification.hem_pressure_c
          log.info("= pressure[3] = #{pressure[3]}")

          uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
          pressure[i] = uom[:factor] * pressure[i]
          log.info("= converted pressure[i] = #{pressure[i]}")

          liquid_viscosity[1] = @scenario_identification.hem_liquid_viscosity_a
          log.info("= liquid_viscosity[1] = #{liquid_viscosity[1]}")
          liquid_viscosity[2] = @scenario_identification.hem_liquid_viscosity_b
          log.info("= liquid_viscosity[2] = #{liquid_viscosity[2]}")
          liquid_viscosity[3] = @scenario_identification.hem_liquid_viscosity_c
          log.info("= liquid_viscosity[3] = #{liquid_viscosity[3]}")

          uom = @project.base_unit_cf(:mtype => 'viscosity_dynamic', :msub_type => 'General')
          liquid_viscosity[i] = uom[:factor] * liquid_viscosity[i]
          log.info("= converted liquid_viscosity[i] = #{liquid_viscosity[i]}")

=begin
Worksheets("Two Phase Hydraulic").Cells(3 + i, 50).Value = Pressure[i]
Worksheets("Two Phase Hydraulic").Cells(3 + i, 51).Value = liquid_viscosity[i]
=end
        end

        #Goal Seek Function
=begin
        Worksheets("Two Phase Hydraulic").Cells(12, 50).Value = 1
        Worksheets("Two Phase Hydraulic").Range("AX11").GoalSeek Goal:=0, ChangingCell:=Worksheets("Two Phase Hydraulic").Range("AX12")
        beta1 = Worksheets("Two Phase Hydraulic").Cells(12, 50).Value
        alpha1 = Worksheets("Two Phase Hydraulic").Cells(13, 50).Value
=end

        # Calculated Max Flux G
=begin
mfa0 = Worksheets("Two Phase Hydraulic").Cells(27, 59).Value
mfa1 = Worksheets("Two Phase Hydraulic").Cells(28, 59).Value
mfa2 = Worksheets("Two Phase Hydraulic").Cells(29, 59).Value
lda0 = Worksheets("Two Phase Hydraulic").Cells(31, 59).Value
lda1 = Worksheets("Two Phase Hydraulic").Cells(32, 59).Value
lda2 = Worksheets("Two Phase Hydraulic").Cells(33, 59).Value
=end

        vapor_den = @scenario_identification.hem_vapor_density_a
        uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
        vapor_den = uom[:factor] * vapor_den
        log.info("converted vapor_den = #{vapor_den}")

        liquid_den = @scenario_identification.hem_liquid_density_a
        uom = @project.base_unit_cf(:mtype => 'Density', :msub_type => 'General')
        liquid_den = uom[:factor] * liquid_den
        log.info("converted liquid_den = #{liquid_den}")

        vapor_specific_volume[0] = 1 / vapor_den
        log.info("vapor_specific_volume[0] = #{vapor_specific_volume[0]}")
        original_vapor_specific_volume[0] = 1 / vapor_den
        log.info("original_vapor_specific_volume[0] = #{original_vapor_specific_volume[0]}")
        liquid_specific_volume[0] = 1 / liquid_den
        log.info("liquid_specific_volume[0] = #{liquid_specific_volume[0]}")
        vapor_fraction[0] = @scenario_identification.hem_mass_vapor_fraction_a
        log.info("vapor_fraction[0] = #{vapor_fraction[0]}")
        liquid_fraction[0] = 1 - vapor_fraction[0]
        log.info("liquid_fraction[0] = #{liquid_fraction[0]}")

        press[0] = @scenario_identification.hem_pressure_a
        uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')
        press[0] = uom[:factor] * press[0]
        log.info("converted press[0] = #{press[0]}")

        liquid_viscosity[0] = @scenario_identification.hem_liquid_viscosity_a
        uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
        liquid_viscosity[0] = uom[:factor] * liquid_viscosity[0]
        log.info("converted liquid_viscosity[0] = #{liquid_viscosity[0]}")

        vapor_viscosity[0] = @scenario_identification.hem_vapor_viscosity_a
        uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
        vapor_viscosity[0] = uom[:factor] * vapor_viscosity[0]
        log.info("converted vapor_viscosity[0] = #{vapor_viscosity[0]}")

        barometric_pressure = @project.barometric_pressure
        uom = @project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
        barometric_pressure = uom[:factor] * barometric_pressure
        log.info("converted barometric_pressure = #{barometric_pressure}")

        initial_pressure = press[0]
        log.info("initial_pressure = #{initial_pressure}")
        initial_v_fraction = vapor_fraction[0]
        log.info("initial_v_fraction = #{initial_v_fraction}")
        initial_l_fraction = liquid_fraction[0]
        log.info("initial_l_fraction = #{initial_l_fraction}")
        initial_v_spec_volume = vapor_specific_volume[0]
        log.info("initial_v_spec_volume = #{initial_v_spec_volume}")
        initial_l_spec_volume = liquid_specific_volume[0]
        log.info("initial_l_spec_volume = #{initial_l_spec_volume}")
        initial_v_viscosity = vapor_viscosity[0]
        log.info("initial_v_viscosity = #{initial_v_viscosity}")
        initial_l_viscosity = liquid_viscosity[0]
        log.info("initial_l_viscosity = #{initial_l_viscosity}")

        #Determine ideal nozzle mass velocity which is the upper limit for the mass velocity.
        log.info("Determine ideal nozzle mass velocity which is the upper limit for the mass velocity")
        (1..((press[0]/0.1)-0.1).round(0)).each do |i|
          log.info("= i = #{i}")
          press[i] = press[0] - [i * 0.1]
          log.info("= press[i] = #{press[i]}")

          vapor_fraction[i] = mfa2 * press[i]**2 + mfa1 * press[i] + mfa0
          log.info("= vapor_fraction[i] = #{vapor_fraction[i]}")
          liquid_fraction[i] = 1 - vapor_fraction[i]
          log.info("= liquid_fraction[i] = #{liquid_fraction[i]}")
          vapor_specific_volume[i] = ((alpha * ((press[0] / press[i])**beta - 1)) + 1) * vapor_specific_volume[0]
          log.info("= vapor_specific_volume[i] = #{vapor_specific_volume[i]}")
          liquid_density[i] = lda2 * press[i]**2 + lda1 * press[i] + lda0
          log.info("= liquid_density[i] = #{liquid_density[i]}")
          liquid_specific_volume[i] = 1 / liquid_density[i]
          log.info("= liquid_specific_volume[i] = #{liquid_specific_volume[i]}")
          liquid_viscosity[i] = ((alpha1 * ((press[0] / press[i])**beta1 - 1)) + 1) * liquid_viscosity[0]
          log.info("= liquid_viscosity[i] = #{liquid_viscosity[i]}")
          two_phase_viscosity[0] = (vapor_fraction[0] * vapor_viscosity[0]) + (liquid_fraction[0] * liquid_viscosity[0])
          log.info("= two_phase_viscosity[i] = #{two_phase_viscosity[i]}")
          two_phase_viscosity[i] = (vapor_fraction[i] * vapor_viscosity[0]) + (liquid_fraction[i] * liquid_viscosity[i])
          log.info("= two_phase_viscosity[i] = #{two_phase_viscosity[i]}")
          two_phase_specific_volume[0] = (vapor_fraction[0] * vapor_specific_volume[0]) + (liquid_fraction[0] * liquid_specific_volume[0])
          log.info("= two_phase_specific_volume[i] = #{two_phase_specific_volume[i]}")
          two_phase_specific_volume[i] = (vapor_fraction[i] * vapor_specific_volume[i]) + (liquid_fraction[i] * liquid_specific_volume[i])
          log.info("= two_phase_specific_volume[i] = #{two_phase_specific_volume[i]}")
          two_phase_density[i] = 1 / two_phase_specific_volume[i]
          log.info("= two_phase_density[i] = #{two_phase_density[i]}")
          average[0] = 0
          log.info("= average[0] = #{average[0]}")
          average[i] = average[i - 1] + (-2 * ((two_phase_specific_volume[i] + two_phase_specific_volume[i - 1]) / 2) * (press[i] - press[i - 1]))
          log.info("= average[i] = #{average[i]}")
          max_flux_square[i] = average[i] / two_phase_specific_volume[i]**2
          log.info("= max_flux_square[i] = #{max_flux_square[i]}")
          log.info("= vapor_fraction[i] > 0 = #{vapor_fraction[i] > 0}")
          if vapor_fraction[i] > 0
            max_flux[0] = 0
            log.info("= max_flux[0] = #{max_flux[0]}")
            max_flux[i] = (3600 / 144) * (32.174 * 144 * max_flux_square[i])**5
            log.info("= max_flux[i] = #{max_flux[i]}")
            log.info("= max_flux[i] < max_flux[i - 1] = #{max_flux[i] < max_flux[i - 1]}")
            if max_flux[i] < max_flux[i - 1]
              maximum_flux = max_flux[i - 1]
              log.info("= max_flux = #{max_flux}")
              i = ((press[0] / 0.1) - 0.1).round(0)
              log.info("= i = #{i}")
            elsif max_flux[i] > max_flux[i - 1]
              maximum_flux = max_flux[i]
              log.info("= maximum_flux = #{maximum_flux}")
            end
          end
        end

        two_phase_line_sizing_preliminary(maximum_flux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)

=begin
'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
If UserFormTwoPhaseHydraulics.lblCalculationType = "Two Phase - HEM Nozzle Sizing" Then
Call TwoPhaseHEMNozzleSizing(MaximumFlux)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "Pipe Capacity" Then
Call TwoPhasePipeCapacity(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressureeee, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "Line Capacity" Then
Call TwoPhaseLineCapacity(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressureeee, initial_v_fraction, initial_l_fractiononononon, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "Line Capacity - Preliminary Sizing" Then
Call TwoPhaseLineSizingPreliminary(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "OP Design" Then
Call TwoPhaseOPDesign(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fractiononononon, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "RD Design" Then
Call TwoPhaseRDDesign(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "Tube Rupture" Then
Call TwoPhaseTubeRupture(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "Orifice Flow" Then
Call TwoPhaseOrificeFlow(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volumeumeumeumeume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "Control Valve Failure" Then
Call TwoPhaseControlValveFailure(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "PSV Design - Inlet Pressure Drop" Then
Call TwoPhaseInletPressureDrop(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volumeumeume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
ElseIf UserFormTwoPhaseHydraulics.lblCalculationType = "PSV Design - Outlet Pressure Drop" Then
Call TwoPhaseOutletPressureDrop(MaximumFlux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
Else
End If
=end
      end

      # DetermineNominalPipeSize(RuptureDiameter, PipeSize, PipeSchedule, ProposedDiameter)        'Module 60
      pipe_size1 = pipe_size
      log.info("pipe_size1 = pipe_size")

      actual_area = pi * (rupture_diameter / 2)**2
      log.info("actual_area = actual_area")
      proposed_area = pi * (proposed_diameter / 2)**2
      log.info("proposed_area = proposed_area")

      uom = @project.base_unit_cf(:mtype => 'Viscosity', :msub_type => 'Dynamic')
      actual_area = uom[:factor] * actual_area
      log.info("actual_area = actual_area")

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      proposed_area = uom[:factor] * proposed_area
      log.info("proposed_area = proposed_area")

      uom = @project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
      proposed_diameter = uom[:factor] * proposed_diameter
      log.info("proposed_diameter = proposed_diameter")

=begin
      472 Worksheets("Line Capacity").Cells(83, 12).Value = rupture_diameter
      473 Worksheets("Line Capacity").Cells(84, 12).Value = PipeSize1
      474 Worksheets("Line Capacity").Cells(85, 12).Value = actual_area
      475 Worksheets("Line Capacity").Cells(86, 12).Value = proposed_area
=end

      if relief_phase == "Two Phase"
=begin
      Worksheets("Line Capacity").Cells(83, 12).Value = ""
      Worksheets("Line Capacity").Cells(84, 12).Value = ""
      Worksheets("Line Capacity").Cells(85, 12).Value = ""
      Worksheets("Line Capacity").Cells(86, 12).Value = ""
=end
      end

      (1..count).each do |h|
        #TODO
        #PipeSize = Worksheets("Line Capacity").Cells(30 + h, 19).Value
        #PipeSchedule = Worksheets("Line Capacity").Cells(30 + h, 21).Value
        #488 Call DeterminePipeDiameter(PipeSize, PipeSchedule, PipeD)                                   'Module 5
        #Worksheets("Line Capacity").Cells(30 + h, 24).Value = PipeD
        #Worksheets("Line Capacity").Cells(30 + h, 27).Value = 100
      end


      #Add comments
      if relief_phase == "Vapor"
        if @project.vapor_flow_model == "Isothermal"
          flow_basis_comment = "using isothermal flow conditions for compressible flow"
        else
          flow_basis_comment = "using adiabatic flow conditions for compressible flow"
        end
      elsif relief_phase == "Liquid"
        flow_basis_comment = "using Bernoulli's equations for non-compressible flow"
      end
      log.info("flow_basis_comment = flow_basis_comment")

      relief_unit = @project.unit 'Mass Flow Rate', 'General'
      p1unit = @project.unit 'Pressure', 'Absolute'
      p2unit = @project.unit 'Pressure', 'Absolute'

=begin
       if Worksheets("Line Capacity").chkRuptureDisk.Value Then
      @scenario_identification.rc_comments = "The size (" + pipe_size1 + " in) of the rupture disk installation required to relief the requirement (" + relief.round[0] + " " + relief_unit + ") for the " & Worksheets("Line Capacity").cmbScenario.Value & " scenario is determined based on methodology presented in Ron Darby's 'Chemical Engineering Fluid Mechanics' (1996), " & flow_basis_comment & ".  All equations are derived from the listed source.  The driving force is the pressure differential across the installation.  The pressure differential is based on the relief pressure of " & (p1 - BarometricPressure) & " " & P1Unit & " and the constant back pressure of " & (p2 - BarometricPressure) & " " & P2Unit & ".   The piping configuration entered is a preliminary proposal." _
      & " The preliminary resistance coefficient of " + rdkrr + " was specified per project guidelines for rupture disks. A factor of 0.90 was used to account for the uncertainties inherent with this method, per API 520 Section 3.11.1.3.1 (7th Edition, January 2000)."
       elsif Worksheets("Line Capacity").chkOpenPipe.Value Then
        @scenario_identification.rc_comments = "The size (" & pipe_size1 & " in) of the open vent installation required to relief the requirement (" & Round(relief, 0) & " " & ReliefUnit & ") for the " & Worksheets("Line Capacity").cmbScenario.Value & " scenario is determined based on methodology presented in Ron Darby's 'Chemical Engineering Fluid Mechanics' (1996), " & flow_basis_comment & ".  All equations are derived from the listed source.  The driving force is the pressure differential across the installation.  The pressure differential is based on the relief pressure of " & (p1 - BarometricPressure) & " " & P1Unit & " and the constant back pressure of " & (p2 - BarometricPressure) & " " & P2Unit & ".   The piping configuration entered is a preliminary proposal.  No uncertainly factor was accounted for in this open vent sizing."
       end
=end @scenario_identification.rc_comments = sizing_comments
      log.info("sizing_comments = sizing_comments")

    end

    @scenario_identification.save
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


    #scenario summary where applicability is yes -- design summary
    @applicable_scenario_summaries = @scenario_summaries.where(:applicability => 'Yes')
    @scenario_summaries_max_area = @applicable_scenario_summaries.maximum("required_orifice")

    #Relief Design scenario calculation
    # find by the largest Required Orifice
    #scenario_summary_id = (@scenario_summaries.where(:required_orifice => @scenario_summaries_max_area)).maximum("id")
    #if !scenario_summary_id.nil?
    #  @sizbasis_design_scenario = @scenario_summaries.find(scenario_summary_id)
    #end

    @sizbasis_design_scenario = @scenario_summaries.where(:applicability => 'Yes').order("required_orifice").order("id").last

    # find by the min Discharge temperature
    scenario_identifications = @relief_device_sizing.scenario_identifications
    #scenario_identifications= ScenarioIdentification.find_by_sql('SELECT si.* FROM scenario_identifications si,scenario_summaries ss where si.scenario_summary_id=ss.id')
    @discharge_min_temp = scenario_identifications.minimum("dc_temperature")
    scenario_summary_id = (scenario_identifications.where(:dc_temperature => @discharge_min_temp, :applicability => 'Yes')).maximum("scenario_summary_id")
    if !scenario_summary_id.nil?
      @min_temp_design_scenario = @scenario_summaries.find(scenario_summary_id)
    end

    # find by the max Relief temperature
    @relief_max_temp = scenario_identifications.maximum("rc_temperature")
    scenario_summary_id = (scenario_identifications.where(:rc_temperature => @relief_max_temp, :applicability => 'Yes')).maximum("scenario_summary_id")
    if !scenario_summary_id.nil?
      @max_temp_design_scenario = @scenario_summaries.find(scenario_summary_id)
    end

    # find by the Inbreathing/Outbreathing
    scenario_summary_id = (@scenario_summaries.where(:applicability => 'Yes', :scenario => 'Inbreathing')).maximum("id")
    if !scenario_summary_id.nil?
      @inbreathing_design_scenario = @scenario_summaries.find(scenario_summary_id)
    end
    scenario_summary_id = (@scenario_summaries.where(:applicability => 'Yes', :scenario => 'Outbreathing')).maximum("id")
    if !scenario_summary_id.nil?
      @outbreathing_design_scenario = @scenario_summaries.find(scenario_summary_id)
    end

    #Relief Design scenario calculation
    #my_sql="select * from scenario_summaries s where s.id=(SELECT max(id) FROM scenario_summaries s where s.required_orifice in (select max(required_orifice) from scenario_summaries))";
    #@design_scenario_summary=ActiveRecord::Base.connection.execute(my_sql)

  end

  def two_phase_line_sizing_preliminary(maximum_flux, mfa0, mfa1, mfa2, alpha, beta, lda0, lda1, lda2, alpha1, beta1, initial_pressure, initial_v_fraction, initial_l_fraction, initial_v_spec_volume, initial_l_spec_volume, initial_v_viscosity, initial_l_viscosity)
    log = CustomLogger.new('line_capacity :: two_phase_line_sizing_preliminary')

    press = []
    vapor_fraction = []
    liquid_fraction = []
    vapor_specific_volume = []
    liquid_specific_volume = []
    vapor_viscosity = []
    liquid_viscosity = []
    liquid_density = []
    two_phase_specific_volume = []
    two_phase_density = []
    average = []
    max_flux_square = []
    max_flux = []
    press1 = []
    two_phase_viscosityty = []
    delta_pipe_length = []

    press[0] = initial_pressure
    log.info("press[0] = #{press[0]}")
    vapor_fraction[0] = initial_v_fraction
    log.info("vapor_fraction[0] = #{vapor_fraction[0]}")
    liquid_fraction[0] = initial_l_fraction
    log.info("liquid_fraction[0] = #{liquid_fraction[0]}")
    vapor_specific_volume[0] = initial_v_spec_volume
    log.info("vapor_specific_volume[0] = #{vapor_specific_volume[0]}")
    liquid_specific_volume[0] = initial_l_spec_volume
    log.info("liquid_specific_volume[0] = #{liquid_specific_volume[0]}")
    vapor_viscosity[0] = initial_v_viscosity
    log.info("vapor_viscosity[0] = #{vapor_viscosity[0]}")
    liquid_viscosity[0] = initial_l_viscosity
    log.info("liquid_viscosity[0] = #{liquid_viscosity[0]}")

    #TODO
=begin
    If Worksheets("Line Capacity").chkRuptureDisk.Value = True Then
    If Worksheets("Line Capacity").RDKr.Value <> Empty Then
    Kr = Worksheets("Line Capacity").RDKr.Value + 0
    Else
    msg1 = MsgBox("No value entered for the maximum flow resistance for a rupture disk.  Please enter a value for the maximum flow resistance for a rupture disk.", vbOKOnly, "No Value Entered For Maximum Flow Resistance For Rupture Disk, Kr!")
    Exit Sub
    End If
    Else
    End If

    If Worksheets("Line Capacity").txtUncertaintyFactor.Value <> Empty Then
    uncertainty_f = Worksheets("Line Capacity").txtUncertaintyFactor.Value + 0
    Else
    msg1 = MsgBox("No value entered for the uncertainty factor for a rupture disk.  Please enter a value for the uncertainty factor for a rupture disk.", vbOKOnly, "No Value Entered For Uncertainty Factor For Rupture Disk!")
    Exit Sub
    End If

    'Determine Relief rate
    SystemDescription = UserFormTwoPhaseHydraulics.lblSystemDescription
    ReliefDeviceTag = UserFormTwoPhaseHydraulics.lblReliefDeviceTag
    EquipmentTag = UserFormTwoPhaseHydraulics.lblEquipmentTag
    Scenario = UserFormTwoPhaseHydraulics.lblScenario
    Identifier = UserFormTwoPhaseHydraulics.lblIdentifier
=end


    (1..16000).each do |r|
=begin
     If Worksheets("Line Capacity").Cells(2, 78 + r).Value = SystemDescription And Worksheets("Line Capacity").Cells(4, 78 + r).Value = EquipmentTag And Worksheets("Line Capacity").Cells(5, 78 + r).Value = Scenario And Worksheets("Line Capacity").Cells(6, 78 + r).Value = Identifier Then
        relief_rate = Worksheets("Line Capacity").Cells(78 + r).Value
        outlet_pressure = Worksheets("Line Capacity").Cells(13, 78 + r).Value
     end
    If Worksheets("Line Capacity").Cells(2, 78 + r).Value = "" And Worksheets("Line Capacity").Cells(4, 78 + r).Value = "" And Worksheets("Line Capacity").Cells(5, 78 + r).Value = "" And Worksheets("Line Capacity").Cells(6, 78 + r).Value = "" Then
    r = 16000
    Else
    End If
=end
    end

=begin
    'Determine Outlet Pressure
    UOM = "Vacuum"
    UOMUnit = Worksheets("Line Capacity").Cells(12, 35).Value
    UOMValue = outlet_pressure
    Call UnitConversionCalculation(UOMValue, UOM, UOMUnit)                  'Module 87
    outlet_pressure = UOMValue
=end

    relief_rate1 = @scenario_identification.rc_flow_rate
    uom = @project.base_unit_cf(:mtype => 'Mass Flow Rate', :msub_type => 'General')
    relief_rate1 = uom[:factor] * relief_rate1
    log.info("relief_rate1 = #{relief_rate1}")

    relief_rate = relief_rate1 / uncertainty_f
    log.info("relief_rate = #{relief_rate}")

    #Determine interval for iterations
    pressure_range = (initial_pressure - outlet_pressure)
    log.info("pressure_range = #{pressure_range}")

    if pressure_range <= 50
      pressure_interval = 1
    elsif pressure_range > 50 and pressure_range <= 100
      pressure_intervall = 2
    elsif pressure_range > 100 and pressure_range <= 150
      pressure_interval = 3
    elsif pressure_range > 150 and pressure_range <= 200
      pressure_interval = 4
    elsif pressure_range > 200 and pressure_range <= 250
      pressure_interval = 5
    elsif pressure_range > 250 and pressure_range <= 300
      pressure_interval = 6
    elsif pressure_range > 300 and pressure_range <= 350
      pressure_interval = 7
    elsif pressure_range > 350 and pressure_range <= 400
      pressure_interval = 8
    elsif pressure_range > 400 and pressure_range <= 450
      pressure_interval = 9
    elsif pressure_range > 450 and pressure_range <= 500
      pressure_interval = 10
    elsif pressure_range > 500 and pressure_range <= 550
      pressure_interval = 11
    elsif pressure_range > 550 and pressure_range <= 600
      pressure_interval = 12
    elsif pressure_range > 600 and pressure_range <= 650
      pressure_interval = 13
    elsif pressure_range > 650 and pressure_range <= 700
      pressure_interval = 14
    elsif pressure_range > 700 and pressure_range <= 750
      pressure_interval = 15
    elsif pressure_range > 750 and pressure_range <= 800
      pressure_interval = 16
    elsif pressure_range > 800 and pressure_range <= 850
      pressure_interval = 17
    elsif pressure_range > 850 and pressure_range <= 900
      pressure_interval = 18
    elsif pressure_range > 900 and pressure_range <= 950
      pressure_interval = 19
    elsif pressure_range > 950 and pressure_range <= 1000
      pressure_interval = 20
    elsif pressure_range > 1000
      pressure_interval = 25
    end

    #Calculate Mass Velocity that corresponds to the entrance pressure to the piping system
    initial_flux = 0
    finished = false
    log.info("finished = #{finished}")
    until finished == true
      mass_velocity = (initial_flux + maximum_flux) / 2
      log.info("mass_velocity = #{mass_velocity}")
      area = relief_rate / mass_velocity
      log.info("area = #{area}")
      rupture_diameter = 2 * (area / PI)**0.5
      log.info("rupture_diameter = #{rupture_diameter}")

      #TODO
      #first_fitting = Worksheets("Line Capacity").Cells(31, 3).Value
      log.info("first_fitting = #{first_fitting}")
      if first_fitting == "Entrance - Inward Projecting (Borda)" or first_fitting == "Entrance - Flush (Sharply Edged, r/D = 0)" or first_fitting == "Entrance - Flush (Rounded, r/D = 0.02)" or first_fitting == "Entrance - Flush (Rounded, r/D = 0.04)" or first_fitting == "Entrance - Flush (Rounded, r/D = 0.06)" or first_fitting == "Entrance - Flush (Rounded, r/D = 0.10)" or first_fitting == "Entrance - Flush (Rounded, r/D > 0.15)"
        log.info("(1..((press[0] / pressure_interval) - pressure_interval).round(0)) = #{(1..((press[0] / pressure_interval) - pressure_interval).round(0))}")
        (1..((press[0] / pressure_interval) - pressure_interval).round(0)).each do |j|
          log.info("= j = #{j}")
          press[j] = press[0] - (j * pressure_interval)
          log.info("= press[j] = #{press[j]}")
          vapor_fraction[j] = mfa2 * press[j]**2 + mfa1 * press[j] + mfa0
          log.info("= vapor_fraction[j] = #{vapor_fraction[j]}")
          liquid_fraction[j] = 1 - vapor_fraction[j]
          log.info("= liquid_fraction[j] = #{liquid_fraction[j]}")
          vapor_specific_volume[j] = ((alpha * ((press[0] / press[j])**beta - 1)) + 1) * vapor_specific_volume[0]
          log.info("= vapor_specific_volume[j] = #{vapor_specific_volume[j]}")
          liquid_density[j] = lda2 * press[j]**2 + lda1 * press[j] + lda0
          log.info("= liquid_density[j] = #{liquid_density[j]}")
          liquid_specific_volume[j] = 1 / liquid_density[j]
          log.info("= liquid_specific_volume[j] = #{liquid_specific_volume[j]}")
          two_phase_specific_volume[0] = (vapor_fraction[0] * vapor_specific_volume[0]) + (liquid_fraction[0] * liquid_specific_volume[0])
          log.info("= two_phase_specific_volume[j] = #{two_phase_specific_volume[j]}")
          two_phase_specific_volume[j] = (vapor_fraction[j] * vapor_specific_volume[j]) + (liquid_fraction[j] * liquid_specific_volume[j])
          log.info("= two_phase_specific_volume[j] = #{two_phase_specific_volume[j]}")
          two_phase_density[j] = 1 / two_phase_specific_volume[j]
          log.info("= two_phase_density[j] = #{two_phase_density[j]}")
          average[0] = 0
          log.info("= average[0] = #{average[0]}")
          average[j] = average[j - 1] + (-2 * ((two_phase_specific_volume[j] + two_phase_specific_volume[j - 1]) / 2) * (press[j] - press[j - 1]))
          log.info("= average[j] = #{average[j]}")
          max_flux_square[j] = average[j] / two_phase_specific_volume[j]**2
          log.info("= max_flux_square[j] = #{max_flux_square[j]}")
          if vapor_fraction[j] > 0
            max_flux[0] = 0
            max_flux[j] = (3600 / 144) * (32.174 * 144 * max_flux_square[j])**0.5
            log.info("= max_flux[j] = #{max_flux[j]}")
            if mass_velocity <= max_flux[j] and mass_velocityy >= max_flux[j - 1]
              pipe_entrance_pressure = press[j]
              log.info("= pipe_entrance_pressure[j] = #{pipe_entrance_pressure[j]}")
              first_two_phase_specific_volume = two_phase_specific_volume[j]
              log.info("= first_two_phase_specific_volume = #{first_two_phase_specific_volume}")
              j = ((press[0] / pressure_interval) - pressure_interval).round(0)
              log.info("= j = #{j}")
            elsif max_flux[j] >= mass_velocity
              pipe_entrance_pressure = press[j]
              log.info("= pipe_entrance_pressure = #{pipe_entrance_pressure}")
              first_two_phase_specific_volume = two_phase_specific_volume[j]
              log.info("= first_two_phase_specific_volume = #{first_two_phase_specific_volume}")
              j = ((press[0] / pressure_interval) - pressure_interval).round(0)
              log.info("= j = #{j}")
            end
          end
        end
      else
        pipe_entrance_pressure = press[0]
        log.info("= pipe_entrance_pressure = #{j}")
        two_phase_specific_volume[0] = first_two_phase_specific_volume
        log.info("= two_phase_specific_volume = #{two_phase_specific_volume}")
      end

      sum_length = 0
      log.info("= sum_length = #{sum_length}")
      log.info("= (1..((pipe_entrance_pressure / pressure_interval) - pressure_interval).round(0)) = #{(1..((pipe_entrance_pressure / pressure_interval) - pressure_interval).round(0))}")
      (1..((pipe_entrance_pressure / pressure_interval) - pressure_interval).round(0)).each do |jj|
        log.info("== jj = #{jj}")
        press1[jj] = pipe_entrance_pressure - (jj * pressure_interval)
        log.info("== press1[jj] = #{press1[jj]}")
        vapor_fraction[jj] = mfa2 * press1[jj]**2 + mfa1 * press1[jj] + mfa0
        log.info("== vapor_fraction[jj] = #{vapor_fraction[jj]}")
        liquid_fraction[jj] = 1 - vapor_fraction[jj]
        log.info("== liquid_fraction[jj] = #{liquid_fraction[jj]}")
        vapor_specific_volume[jj] = ((alpha * ((press[0] / press1[jj])**beta - 1)) + 1) * vapor_specific_volume[0]
        log.info("== vapor_specific_volume[jj] = #{vapor_specific_volume[jj]}")
        liquid_density[jj] = lda2 * press1[jj]**2 + lda1 * press1[jj] + lda0
        log.info("== liquid_density[jj] = #{liquid_density[jj]}")
        liquid_specific_volume[jj] = 1 / liquid_density[jj]
        log.info("== liquid_specific_volume[jj] = #{liquid_specific_volume[jj]}")
        liquid_viscosity[jj] = ((alpha1 * ((press[0] / press1[jj])**beta1 - 1)) + 1) * liquid_viscosity[0]
        log.info("== liquid_viscosity[jj] = #{liquid_viscosity[jj]}")
        two_phase_viscosity[0] = (vapor_fraction[0] * vapor_viscosity[0]) + (liquid_fraction[0] * liquid_viscosity[0])
        log.info("== two_phase_viscosity[0] = #{two_phase_viscosity[0]}")
        two_phase_viscosity[jj] = (vapor_fraction[jj] * vapor_viscosity[0]) + (liquid_fraction[jj] * liquid_viscosity[jj])
        log.info("== two_phase_viscosity[jj] = #{two_phase_viscosity[jj]}")
        two_phase_specific_volume[jj] = (vapor_fraction[jj] * vapor_specific_volume[jj]) + (liquid_fraction[jj] * liquid_specific_volume[jj])
        log.info("== two_phase_specific_volume[jj] = #{two_phase_specific_volume[jj]}")
        two_phase_density[jj] = 1 / two_phase_specific_volume[jj]
        log.info("== two_phase_specific_volume[jj] = #{two_phase_specific_volume[jj]}")

        viscosity = two_phase_viscosity[jj]
        line_capacity_calc_prelim(mass_velocity, viscosity, kfi_sum, outlet_pressure, exit_pressure, elevation_change, rupture_diameter, count, kr)

        two_phase_specific_volume[0] = first_two_phase_specific_volume
        press1[0] = pipe_entrance_pressure
        avg_specific_volume = (two_phase_specific_volume[jj] + two_phase_specific_volume[jj - 1]) / 2
        delta_p = 32.174 * 3600**2 * 12 * (press1[jj] - press1[jj - 1])
        delta_v = two_phase_specific_volume[jj] - two_phase_specific_volume[jj - 1]
        velocity_head = 144 * mass_velocity**2 * delta_v
        potential_energy = (32.174 * 3600**2 * (1 / 12)) * (elevation_change / avg_specific_volume)
        frictional_loss = (kfi_sum * avg_specific_volume * mass_velocity**2 * 144 * 12) / 2
        delta_pipe_length[jj] = -((delta_p + velocity_head) / (potential_energy + frictional_loss))

        if press1[jj] >= outlet_pressure
          if delta_pipe_length[jj] >= 0
            sum_length = sum_length + delta_pipe_length[jj]
          elsif delta_pipe_length[jj] < 0
            choke_pressure = press1[jj]
            exit_pressure = choke_pressure
            jj = ((pipe_entrance_pressure / pressure_interval) - pressure_interval).round(0)
            if (sum_length - 1).abs < 0.001 #0.1% convergence
              finished = true
            else
              if sum_length > 1
                initial_flux = mass_velocity
              elsif sum_length < 1
                maximum_flux = mass_velocity
              end
            end
          end
        else
          jj = ((pipe_entrance_pressure / pressure_interval) - pressure_interval).round(0)
          if (sum_length - 1).abs < 0.001 #0.1% convergence
            finished = true
          else
            if sum_length > 1
              initial_flux = mass_velocity
            elsif sum_length < 1
              maximum_flux = mass_velocity
            end
          end
        end
      end
    end

    #TODO
    #Call DetermineNominalPipeSize(rupture_diameter, PipeSize, PipeSchedule, ProposedDiameter)        'Module 60

    pipe_size1 = pipe_size
    actual_area = PI * (rupture_diameter / 2)**2
    proposed_area = PI * (proposed_diameter / 2)**2

    uom = project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
    actual_area = uom[:factor] * actual_area

    uom = project.base_unit_cf(:mtype => 'Area', :msub_type => 'Orifice')
    proposed_area = uom[:factor] * proposed_area

    uom = project.base_unit_cf(:mtype => 'Length', :msub_type => 'PipeTubeDiameter')
    rupture_diameter = uom[:factor] * rupture_diameter

    uom = project.base_unit_cf(:mtype => 'Length', :msub_type => 'PipeTubeDiameter')
    proposed_diameter = uom[:factor] * proposed_diameter

    relief_unit = @project.unit 'Mass Flow Rate', 'General'
    p1unit = @project.unit 'Pressure', 'Absolute'
    p2unit = @project.unit 'Pressure', 'Absolute'

    #if Worksheets("Line Capacity").chkRuptureDisk.Value = True
    #elsif Worksheets("Line Capacity").chkOpenPipe.Value = True Then
=begin
    if true
      sizing_comments = "The size (" + pipe_size + " in) of the rupture disk installation required to relief the requirement (" + (relief_rate1).round(0) + " " + relief_unit + ") for the " + scenario + " scenario is determined based on procedures and equations provided in Larry L. Simpson's 'Navigating the Two-Phase Maze', presented in the publication of the August 2-4 1995 International Symposium On Runaway Reactions and Pressure Relief Design (Pages 394-417). With this methodology, 3 points representing the conditions along the pressure profile was selected to serve as a representative basis to determine physical properties along the entire pressure profile." +
      + " The 3 points are typically (but not necessarily) the conditions at relief, conditions at choke and conditions at discharge. Based on the selections, a model is developed to determine the fluid specific volume from which a profile of the mass flux over a pressure range is developed. The driving force is the pressure differential across the installation. The pressure differential is based on the relief pressure of " + p1 + " " + p1unit + " and the constant back pressure of " + outlet_pressure + " " + p2unit + ". The piping configuration entered is a preliminary proposal." +
      + " The preliminary resistance coefficient of " + rdkr + " was specified per project guidelines for rupture disks. A factor of 0.90 was used to account for the uncertainties inherent with this method, per API 520 Section 3.11.1.3.1 (7th Edition, January 2000)."
    else
      sizing_comments = "The size (" + pipe_size + " in) of the open vent installation required to relief the requirement (" + (relief_rate1).round(0) + " " + relief_unit + ") for the " + scenario + " scenario is determined based on procedures and equations provided in Larry L. Simpson's 'Navigating the Two-Phase Maze', presented in the publication of the August 2-4 1995 International Symposium On Runaway Reactions and Pressure Relief Design (Pages 394-417).  With this methodology, 3 points representing the conditions along the pressure profile was selected to serve as a representative basis to determine physical properties along the entire pressure profile." +
      + " The 3 points are typically (but not necessarily) the conditions at relief, conditions at choke and conditions at discharge.  Based on the selections, a model is developed to determine the fluid specific volume from which a profile of the mass flux over a pressure range is developed.  The driving force is the pressure differential across the installation.  The pressure differential is based on the relief pressure of " + P1 + " " + P1Unit + " and the constant back pressure of " + outlet_pressure + " " + p2unit + ". The piping configuration entered is a preliminary proposal." +
      + " No uncertainly factor was accounted for in this open vent sizing."
    end
=end


=begin
    (1..16000).each do |rr|
    If Worksheets("Line Capacity").Cells(2, 78 + rr).Value = SystemDescription and Worksheets("Line Capacity").Cells(4, 78 + rr).Value = EquipmentTag and Worksheets("Line Capacity").Cells(5, 78 + rr).Value = Scenario and Worksheets("Line Capacity").Cells(6, 78 + rr).Value = Identifier Then
    Worksheets("Line Capacity").Cells(26, 78 + rr).Value = rupture_diameter
    Worksheets("Line Capacity").Cells(27, 78 + rr).Value = PipeSize1
    Worksheets("Line Capacity").Cells(28, 78 + rr).Value = ActualArea
    Worksheets("Line Capacity").Cells(29, 78 + rr).Value = proposed_area
    rr = 16000
    end

    #TODO
    if true
    #if Worksheets("Line Capacity").Cells(2, 78 + rr).Value = "" and Worksheets("Line Capacity").Cells(4, 78 + rr).Value = "" and Worksheets("Line Capacity").Cells(5, 78 + rr).Value = "" and Worksheets("Line Capacity").Cells(6, 78 + rr).Value = "" Then
    rr = 16000
    end
    end
=end

  end


  def line_capacity_calc_prelim(mass_velocity, viscosity, kfi_sum, outlet_pressure, exit_pressure, elevation_change, rupture_diameter, count, kr)
    f = [[], []]
    two_phase_nre = []
    nre = [[], []]
    alpha = [[], []]
    pipe_id = []
    kfi = [[], []]
    kfd = [[], []]
    elev = []
    outlet_nre = []
    g = [[], []]
    pipe_count_id = []
    section_exit_pressure = [[], []]
    area = []

    e = @scenario_identification.rc_pipe_roughness
    uom = @project.base_unit_cf(:mtype => 'Length', :msub_type => 'PipeTubeDiameter')
    e = uom[:factor] * e


=begin
'Count number of fittings
Count = 0
For m = 1 To 50
    If Worksheets("Line Capacity").Cells(30 + m, 3).Value <> Empty Then
    Count = Count + 1
    Else
    End If
Next m
=end


=begin

KfiSum = 0
SumElevation = 0
For m = 1 To Count
pipe_id(m) = RuptureDiameter

Length = Worksheets("Line Capacity").Cells(30 + m, 33).Value
UOM = "Length"
UOMUnit = Worksheets("UOM").Cells(8, 17).Value
UOMValue = Length
Call UnitConversionCalculation(UOMValue, UOM, UOMUnit)          'Module 87
Length = UOMValue

Elevation = Worksheets("Line Capacity").Cells(30 + m, 36).Value
UOM = "Length"
UOMUnit = Worksheets("UOM").Cells(8, 17).Value
UOMValue = Elevation
Call UnitConversionCalculation(UOMValue, UOM, UOMUnit)          'Module 87
Elevation = UOMValue

nre(k, m) = (4.96039 * pipe_id(m) * MassVelocity) / Viscosity

'Determine new friction factor using Churchill's equation
A = (2.457 * Log(1 / (((7 / nre(k, m)) ^ 0.9) + (0.27 * (E / pipe_id(m)))))) ^ 16
b = (37530 / nre(k, m)) ^ 16
f(k, m) = 2 * ((8 / nre(k, m)) ^ 12 + (1 / ((A + b) ^ (3 / 2)))) ^ (1 / 12)

Fd = 4 * f(k, m)
Nreynolds = nre(k, m)

d = RuptureDiameter

fittingtype = Worksheets("Line Capacity").Cells(30 + m, 3).Value

    If fittingtype = "Pipe" Then
    Kf = 4 * f(k, m) * (Length / (pipe_id(m) / 12))
    ElseIf fittingtype = "Rupture Disk" Then
    Kf = Kr
    Else
    Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)
    End If

kfi(k, m) = Kf
KfiSum = KfiSum + kfi(k, m)
SumElevation = SumElevation + Elevation

DoverD = ""
Kf = ""
Elevation = ""

Next m

ElevationChange = SumElevation
=end

  end
end
