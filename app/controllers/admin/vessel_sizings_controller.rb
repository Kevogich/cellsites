class Admin::VesselSizingsController < AdminController

  before_filter :default_form_values, :only => [:new, :create, :edit, :update]

  def index
    @vessel_sizings = @company.vessel_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))

    if @user_project_settings.client_id.nil?
      flash[:error] = "Please Update Project Setting"
      redirect_to admin_sizings_path
    end
  end

  def new
    @vessel_sizing = @company.vessel_sizings.new
  end

  def create
    vessel_sizing = params[:vessel_sizing]
    vessel_sizing[:created_by] = vessel_sizing[:updated_by] = current_user.id
    @vessel_sizing = @company.vessel_sizings.new(vessel_sizing)

    if @vessel_sizing.save
      @vessel_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      flash[:notice] = "New vessel sizing created successfully."
      if params[:calculate_btn].blank?
        redirect_to admin_vessel_sizings_path
      else
        redirect_to edit_admin_vessel_sizing_path(@vessel_sizing, :anchor => params[:tab], :calculate_btn => params[:calculate_btn])
      end

    else
      params[:calculate_btn] = ''
      render :new
    end
  end

  def edit
    @vessel_sizing = @company.vessel_sizings.find(params[:id])
    @project = @vessel_sizing.project

    if !@vessel_sizing.process_basis_id.nil?
      heat_and_material_balance = HeatAndMaterialBalance.find(@vessel_sizing.process_basis_id)
      @streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end
  end

  def update
    vessel_sizing = params[:vessel_sizing]
    vessel_sizing[:updated_by] = current_user.id

    @vessel_sizing = @company.vessel_sizings.find(params[:id])

    if @vessel_sizing.update_attributes(vessel_sizing)
      flash[:notice] = "updated vessel sizing successfully."
      if params[:calculate_btn].blank?
        redirect_to admin_vessel_sizings_path
      else
        redirect_to edit_admin_vessel_sizing_path(@vessel_sizing, :anchor => params[:tab], :calculate_btn => params[:calculate_btn])
      end
    else
      params[:calculate_btn] = ''
      render :edit
    end
  end

  def destroy
    @vessel_sizing = @company.vessel_sizings.find(params[:id])
    if @vessel_sizing.destroy
      flash[:notice] = "Deleted #{@vessel_sizing.name} successfully."
      redirect_to admin_vessel_sizings_path
    end
  end

  def clone
	  @vessel_sizing = VesselSizing.find(params[:id])
	  new = @vessel_sizing.clone :except => [:created_at, :updated_at]
	  new.name = params[:tag]
	  if new.save
	  	render :json => {:error => false, :url => edit_admin_vessel_sizing_path(new) }
	  else
	  	render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
	  end
	  return
  end


  def set_breadcrumbs
    super
    @breadcrumbs << {:name => 'Sizing', :url => admin_sizings_path}
    @breadcrumbs << {:name => 'Vessel sizings', :url => admin_vessel_sizings_path}
  end

  def get_feed_stream_nos
    form_values = {}

    heat_and_material_balance = HeatAndMaterialBalance.find(params[:process_basis_id])

    property = heat_and_material_balance.heat_and_material_properties

    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure_value] = pressure_stream.stream_value.to_f rescue nil

    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature_value] = temperature_stream.stream_value.to_f rescue nil

    vapour_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    vapour_fraction_stream = vapour_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapour_fraction_value] = vapour_fraction_stream.stream_value.to_f rescue nil

    flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    flow_rate_stream = flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:flow_rate_value] = flow_rate_stream.stream_value.to_f rescue nil

    density = property.where(:phase => "Light Liquid", :property => "Mass Density").first
    density_stream = density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:density_value] = density_stream.stream_value.to_f rescue nil

    viscosity = property.where(:phase => "Light Liquid", :property => "Viscosity").first
    viscosity_stream = viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:viscosity_value] = viscosity_stream.stream_value.to_f rescue nil

    render :json => form_values
  end

  def get_top_outlet_stream_nos
    form_values = {}

    heat_and_material_balance = HeatAndMaterialBalance.find(params[:process_basis_id])
    property = heat_and_material_balance.heat_and_material_properties

    flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    flow_rate_stream = flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:flow_rate_value] = flow_rate_stream.stream_value.to_f rescue nil

    vapor_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    vapor_fraction_stream = vapor_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_fraction_value] = vapor_fraction_stream.stream_value.to_f rescue nil

    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure_value] = pressure_stream.stream_value.to_f rescue nil

    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature_value] = temperature_stream.stream_value.to_f rescue nil

    density = property.where(:phase => "Vapour", :property => "Mass Density").first
    density_stream = density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:density_value] = density_stream.stream_value.to_f rescue nil

    viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
    viscosity_stream = viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:viscosity_value] = viscosity_stream.stream_value.to_f rescue nil

    render :json => form_values
  end

  def get_bottom_outlet_stream_nos
    form_values = {}

    heat_and_material_balance = HeatAndMaterialBalance.find(params[:process_basis_id])
    property = heat_and_material_balance.heat_and_material_properties

    flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    flow_rate_stream = flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:flow_rate_value] = flow_rate_stream.stream_value.to_f rescue nil

    vapor_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    vapor_fraction_stream = vapor_fraction.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_fraction_value] = vapor_fraction_stream.stream_value.to_f rescue nil

    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure_value] = pressure_stream.stream_value.to_f rescue nil

    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature_value] = temperature_stream.stream_value.to_f rescue nil

    density = property.where(:phase => "Vapour", :property => "Mass Density").first
    density_stream = density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:density_value] = density_stream.stream_value.to_f rescue nil

    viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
    viscosity_stream = viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:viscosity_value] = viscosity_stream.stream_value.to_f rescue nil

    render :json => form_values
  end


  def get_vessel_sizing_hs_water_stream_nos
    form_values = {}

    heat_and_material_balance = HeatAndMaterialBalance.find(params[:process_basis_id])
    property = heat_and_material_balance.heat_and_material_properties

    flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
    flow_rate_stream = flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:flow_rate_value] = flow_rate_stream.stream_value.to_f rescue nil

    density = property.where(:phase => "Vapour", :property => "Mass Density").first
    density_stream = density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:density_value] = density_stream.stream_value.to_f rescue nil

    render :json => form_values
  end

  def vessel_sizing_summary
    @vessel_sizings = @company.vessel_sizings.all
  end

  def filter_transfer_data

    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    pressure_rating = vessel_sizing.ft_pressure_rating
    temperature_rating = vessel_sizing.ft_temperature_rating
    shell_diameter = vessel_sizing.ft_shell_diameter
    shell_length = vessel_sizing.ft_shell_length

    vessel_sizing.dc_max_possible_supply_pressure_to_vessel = pressure_rating
    vessel_sizing.dc_max_design_temperature = temperature_rating
    vessel_sizing.md_shell_diameter = shell_diameter
    vessel_sizing.md_shell_length = shell_length

    vessel_sizing.save

    render :json => {:success => true}
  end

  def reactor_transfer_data

    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    pressure_rating = vessel_sizing.re_pressure_rating
    temperature_rating = vessel_sizing.re_temperature_rating
    shell_diameter = vessel_sizing.re_shell_diameter
    shell_length = vessel_sizing.re_shell_length

    vessel_sizing.dc_max_possible_supply_pressure_to_vessel = pressure_rating
    vessel_sizing.dc_max_design_temperature = temperature_rating
    vessel_sizing.md_shell_diameter = shell_diameter
    vessel_sizing.md_shell_length = shell_length

    vessel_sizing.save

    render :json => {:success => true}
  end

  def design_conditions_calculate

    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    design_pressure_4 = vessel_sizing.dc_normal_operating_pressure
    design_pressure_3 = vessel_sizing.dc_collection_system_back_pressure
    design_pressure_2 = vessel_sizing.dc_min_pressure_vessel_design_press
    maximum_operating_pressure = vessel_sizing.dc_maximum_operating_pressure

    design_pressure_1 = 0
    if vessel_sizing.dc_relief_device_type == "Conventional" || vessel_sizing.dc_relief_device_type == "Balanced Bellows"
      design_pressure_1a = maximum_operating_pressure * (1 + 0.1)
      design_pressure_1b = maximum_operating_pressure + 25
      if design_pressure_1a > design_pressure_1b
        design_pressure_1 = design_pressure_1a
      elsif design_pressure_1b > design_pressure_1a
        design_pressure_1 = design_pressure_1b
      else
        design_pressure_1 = design_pressure_1a
      end
    elsif vessel_sizing.dc_relief_device_type == "Pilot Operated"
      design_pressure_1a = maximum_operating_pressure * (1 + 0.05)
      design_pressure_1b = maximum_operating_pressure + 10
      if design_pressure_1a > design_pressure_1b
        design_pressure_1 = design_pressure_1a
      elsif design_pressure_1b1b > design_pressure_1a
        design_pressure_1 = design_pressure_1b
      else
        design_pressure_1 = design_pressure_1a
      end
    end

    design_pressure = [design_pressure_1.to_f, design_pressure_2.to_f, design_pressure_3.to_f, design_pressure_4.to_f].max
    vessel_sizing.dc_design_pressure = design_pressure

    factor = project.test_pressure_factor.to_f

    hydro_test_pressure = design_pressure * factor

    vessel_sizing.dc_test_pressure = hydro_test_pressure.round(1)

    #Determine Vacuum Design
    if vessel_sizing.dc_max_vacuum_pressure != ''
      max_vacuum_pressure = vessel_sizing.dc_max_vacuum_pressure
      atmospheric_pressure = vessel_sizing.dc_atmospheric_pressure

      differential_pressure = atmospheric_pressure - max_vacuum_pressure
      differential_pressure = differential_pressure * (1 + 0.25)

      if atmospheric_pressure < differential_pressure
        vacuum_design = atmospheric_pressure
      elsif differential_pressure < atmospheric_pressure
        vacuum_design = differential_pressure
      else
        vacuum_design = atmospheric_pressure
      end

      vessel_sizing.dc_design_vacuum = vacuum_design.round(2)
    end

    #Determine Maximum Temperature
    if vessel_sizing.dc_normal_operating_temperature != ''
      operating_temperature = vessel_sizing.dc_normal_operating_temperature

      if operating_temperature.to_f > 32
        maximum_operating_temperature = vessel_sizing.dc_maximum_operating_temperature

        design_temperature_1 = maximum_operating_temperature + 25

        (1..1000).each do |cxx|
          diff_t = design_temperature_1 - (5 * cxx)
          if diff_t < 5 && diff_t > 0
            diff_t = 5
            design_temperature_1 = (5 * cxx) + diff_t
            break
          elsif diff_t <= 0
            break
          end
        end

        max_temp_at_relief_pressure = vessel_sizing.dc_max_design_temperature

        design_temperature_2 = max_temp_at_relief_pressure

        (1..1000).each do |dxx|
          diff_t = design_temperature_2 - (5 * dxx)
          if diff_t < 5 && diff_t > 0
            diff_t = 5
            design_temperature_2 = (5 * dxx) + diff_t
            break
          elsif diff_t <= 0
            break
          end
        end

        if vessel_sizing.dc_equipment_subject_to_steam_out
          design_temperature_3 = 250
        else
          design_temperature_3 = 0
        end

        if vessel_sizing.dc_equipment_subject_to_dry_out
          design_temperature_4 = 150
        else
          design_temperature_4 = 0
        end

        design_temperature = [design_temperature_1, design_temperature_2, design_temperature_3, design_temperature_4].max

        min_temperature_1 = vessel_sizing.dc_minimum_operating_temperature

        (1..1000).each do |fxx|
          diff_t = min_temperature_1 - (5 * fxx)
          if diff_t < 5 && diff_t > 0
            diff_t = 5
            min_temperature_1 = (5 * fxx) + diff_t
            break
          elsif diff_t <= 0
            break
          end
        end

        min_temperature_2 =vessel_sizing.dc_minimum_amb_design_temperature

        minimum_design_temperature = [min_temperature_1.to_f, min_temperature_2.to_f].max

      elsif operating_temperature.to_f < 32
        if vessel_sizing.dc_equipment_subject_to_steam_out
          design_temperature_1 = 250
        else
          design_temperature_1 = 0
        end

        if vessel_sizing.dc_equipment_subject_to_dry_out
          design_temperature_2 = 150
        else
          design_temperature_2 = 0
        end

        design_temperature = [design_temperature_1, design_temperature_2].max

        min_temperature_1 = vessel_sizing.dc_minimum_operating_temperature

        (1..1000).each do |exx|
          diff_t = min_temperature_1 - (5 * exx)
          if diff_t < 5 && diff_t > 0
            diff_t = 5
            min_temperature_1 = (5 * exx) + diff_t
            break
          elsif diff_t <= 0
            break
          end
        end

        min_temperature_2 = vessel_sizing.dc_minimum_amb_design_temperature

        minimum_design_temperature = [min_temperature_1.to_f, min_temperature_2.to_f].max
      end
    end

    vessel_sizing.dc_design_temperature = design_temperature
    vessel_sizing.dc_minimum_design_temperature = minimum_design_temperature

    vessel_sizing.save

    render :json => {:success => true}
  end

  def mechanical_design_calculate

    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    barometric_pressure = project.barometric_pressure

    #TODO
    vessel_sizing.md_design_pressure = 10
    p = vessel_sizing.md_design_pressure + barometric_pressure
    #TODO
    vessel_sizing.md_shell_diameter = 10
    shell_diameter = vessel_sizing.md_shell_diameter
    d = shell_diameter * 12
    r = (shell_diameter / 2) * 12

    #TODO
    vessel_sizing.md_shell_length = 23
    shell_length = vessel_sizing.md_shell_length
    s = vessel_sizing.md_allowable_stress
    e = vessel_sizing.md_shell_head_joint_efficiency
    shell_c = vessel_sizing.md_shell_corrosion_allowance
    head_c = vessel_sizing.md_head_corrosion_allowance
    sf = vessel_sizing.md_straight_flange
    material_density = vessel_sizing.md_vessel_material_density
    content_density = vessel_sizing.md_vessel_content_density

    #Cylindrical shell thickness
    shell_thickness = ((p * r) / ((s * e) - 0.6 * p)) + shell_c

    head_thickness = 0
    if vessel_sizing.md_head_type == "Ellipsoidal"
      head_thickness = ((p * d) / ((2 * s * e) - 0.2 * p)) + head_c
    elsif vessel_sizing.md_head_type == "Torispherical"
      #TODO
      #l = InputBox("Input the crown radius of the torispherical head in the appropriate unit (" & LUnit & ").") + 0
      l = 1
      head_thickness = ((0.885 * p * l) / ((s * e) - 0.1 * p)) + head_c
    elsif vessel_sizing.md_head_type == "Hemispherical"
      head_thickness = ((p * r) / ((2 * s * e) - 0.2 * p)) + head_c
    elsif vessel_sizing.md_head_type == "Conical"
      #TODO
      #alpha = InputBox("Input the factor C which is based on the method of attachment of the head, shell dimensions and other items as per ASME VIII", "C factor") + 0
      alpha = 1
      t =(p * d)/(2 * Math.cos(alpha) * (s * e - 0.6 * p))
    elsif vessel_sizing.md_head_type == "Flat"
      #TODO
      #c = InputBox("Input the factor C which is based on the method of attachment of the head, shell dimensions and other items as per ASME VIII", "C factor") + 0
      c = 0
      head_thickness = (d * ((c * p) / (s * e)) ** 0.5) + head_c
    end

    #Determine capacity
    full_volume = volume_calculation(shell_diameter, shell_length, vessel_sizing.md_head_type)

    #Determine Weight
    #Head weight
    if vessel_sizing.md_head_type == "Hemispherical"
      head_surface_area = 1.5708 * ((d + 2 * head_thickness) / 12) ** 2
    elsif vessel_sizing.md_head_type == "Ellipsoidal"
      head_surface_area = 1.082 * ((d + 2 * head_thickness) / 12) ** 2
    elsif vessel_sizing.md_head_type == "Torispherical"
      head_surface_area = 0.9286 * ((d + 2 *head_thickness) / 12) ** 2
    elsif vessel_sizing.md_head_type == "Flat"
      head_surface_area = 0.7854 * ((d + 2 *head_thickness) / 12) ** 2
    end

    #Cylinder weight
    cylinder_weight = PI * ((d + shell_thickness) / 12) * shell_length * (shell_thickness / 12) * material_density

    #Head blank diameter
    head_od = (2 * head_thickness) + d

    hfac = 0
    if vessel_sizing.md_head_type == "Hemispherical"
      if head_od >= 10 && head_od < 18
        hfac = 1.7
      elsif head_od >= 18 && head_od <= 30
        hfac = 1.65
      elsif head_od > 30
        hfac = 1.6
      end
    elsif vessel_sizing.md_head_type == "Ellipsoidal"
      if head_od >= 10 && head_od <= 20
        hfac = 1.3
      elsif head_od > 20
        hfac = 1.24
      end
    elsif vessel_sizing.md_head_type == "Torispherical"
      if head_od >= 20 && head_od < 30
        hfac = 1.15
      elsif head_od >= 30 && head_odd <= 50
        hfac = 1.11
      elsif head_odd > 50
        hfac = 1.09
      end
    end

    bd = (head_od * hfac + 2 * sf) / 12

    head_weight = 0.25 * bd ** 2 * PI * (head_thickness / 12) * material_density * 2

    wa = vessel_sizing.md_vessel_weight_allowance

    #Total Weight Empty
    total_weight_empty = (cylinder_weight + head_weight) * (1 + wa)

    #Determine Full liquid volume in head.  Note that the diameter is meant to be the inner diameter of the vessel but is approximated as the outer diameter
    head_volume = 0
    if vessel_sizing.md_head_type == "Hemispherical"
      head_volume = PI * ((d / 12) ** 3 / 12)
    elsif vessel_sizing.md_head_type == "Ellipsoidal"
      head_volume = PI * ((d / 12) ** 3 / 24)
    elsif vessel_sizing.md_head_type == "Torispherical" #Per Perry's, alternatively for code construction, per page 88 on Process Equipment Design by Lloyd e Brownell, Edwin H Young.  if designed to 3 x thickness, then Perry's 10-140 gives an alternate equation.
      head_volume = 0.0847 * (d / 12) ** 3
    end

    content_weight = (shell_length * ((d / 12) / 2) ** 2 * PI) + (head_volume * 2) * content_density
    full_weight = total_weight_empty + content_weight

    vessel_sizing.md_weight_empty_vessel = total_weight_empty.round(0)
    vessel_sizing.md_weight_full_vessel = full_weight.round(0)


    vessel_sizing.md_shell_thickness = shell_thickness.round(2)
    vessel_sizing.md_head_thickness = head_thickness.round(2)

    vessel_sizing.save

    render :json => {:success => true}
  end

  def get_nozzle_od

    pipe_sizes = {"0.125" => 0.405,
                  "0.25" => 0.54,
                  "0.375" => 0.675,
                  "0.5" => 0.84,
                  "0.75" => 1.05,
                  "1.0" => 1.315,
                  "1.25" => 1.66,
                  "1.5" => 1.9,
                  "2.0" => 2.375,
                  "2.5" => 2.875,
                  "3.0" => 3.5,
                  "3.5" => 4,
                  "4.0" => 4.5,
                  "5.0" => 5.563,
                  "6.0" => 6.625,
                  "8.0" => 8.625,
                  "10.0" => 10.75,
                  "12.0" => 12.75,
                  "14.0" => 14,
                  "16.0" => 16,
                  "18.0" => 18,
                  "20.0" => 20,
                  "22.0" => 22,
                  "24.0" => 24,
                  "26.0" => 26,
                  "28.0" => 28,
                  "30.0" => 30,
                  "32.0" => 32,
                  "34.0" => 34,
                  "36.0" => 36}

    nozzle_od = pipe_sizes[params[:nozzle_size].to_s]

    render :json => {:nozzle_od => nozzle_od}
  end

  def feed_nozzle_calculation

    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    nozzle_count = vessel_sizing.ns_fn_no_of_nozzle.to_i
    sizing_criteria = vessel_sizing.ns_fn_fluid_momentum_sizing_criteria
    feed_density = vessel_sizing.ns_fn_density = vessel_sizing.feed_stream_density
    flow_rate = vessel_sizing.feed_stream_flow_rate

    #Determine velocity
    velocity = (sizing_criteria / feed_density) ** 0.5

    #Determine Volumetric Flow Rate
    volumetric_flow_rate = flow_rate / feed_density

    #Determine Flow Rate per Nozzle
    volumetric_flow_rate_per_nozzle = volumetric_flow_rate / nozzle_count.to_f

    #Determine Minimum Diameter
    dmin = ((volumetric_flow_rate_per_nozzle / velocity) * (144.0 / 3600.0)) ** 0.5

    vessel_sizing.ns_fn_velocity = velocity.round(3)
    vessel_sizing.ns_fn_volumetric_rate = volumetric_flow_rate.round(2)
    vessel_sizing.ns_fn_dmin = dmin.round(2)

    vessel_sizing.save

    render :json => {:success => true}
  end

  def top_outlet_nozzle_calculation
    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    nozzle_count = vessel_sizing.ns_ton_no_of_nozzle
    sizing_criteria = vessel_sizing.ns_ton_fluid_momentum_sizing_criteria
    vapor_outlet_density = vessel_sizing.ns_ton_density = vessel_sizing.top_outlet_stream_density

    flow_rate = vessel_sizing.top_outlet_stream_flow_rate

    #Determine velocity
    velocity = (sizing_criteria / vapor_outlet_density) ** 0.5

    #Determine Volumetric Flow Rate
    volumetric_flow_rate = flow_rate / vapor_outlet_density

    #Determine Flow Rate per Nozzle
    volumetric_flow_rate_per_nozzle = volumetric_flow_rate / nozzle_count.to_f

    #Determine Minimum Diameter
    dmin = ((volumetric_flow_rate_per_nozzle / velocity) * (144.0 / 3600.0)) ** 0.5

    vessel_sizing.ns_ton_velocity = velocity.round(3)
    vessel_sizing.ns_ton_volumetric_rate = volumetric_flow_rate.round(2)
    vessel_sizing.ns_ton_dmin = dmin.round(2)

    vessel_sizing.save
    render :json => {:success => true}
  end

  def bottom_outlet_nozzle_calculation
    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    nozzle_count = vessel_sizing.ns_bon_no_of_nozzle
    sizing_criteria = vessel_sizing.ns_bon_fluid_momentum_sizing_criteria
    liquid_outlet_density = vessel_sizing.ns_bon_density = vessel_sizing.bottom_outlet_stream_density
    flow_rate = vessel_sizing.bottom_outlet_stream_flow_rate

    #Determine velocity
    velocity = vessel_sizing.ns_bon_velocity
    if velocity == ''
      velocity = vessel_sizing.ns_bon_velocity
    else
      velocity = (sizing_criteria / liquid_outlet_density) ** 0.5
    end

    #Determine Volumetric Flow Rate
    volumetric_flow_rate = flow_rate / liquid_outlet_density

    #Determine Flow Rate per Nozzle
    volumetric_flow_rate_per_nozzle = volumetric_flow_rate / nozzle_count.to_f

    #Determine Minimum Diameter
    dmin = ((volumetric_flow_rate_per_nozzle / velocity) * (144.0 / 3600.0)) ** 0.5

    vessel_sizing.ns_bon_velocity = velocity.round(3)
    vessel_sizing.ns_bon_volumetric_rate = volumetric_flow_rate.round(2)
    vessel_sizing.ns_bon_dmin = dmin.round(2)

    vessel_sizing.save
    render :json => {:success => true}
  end

  def vertical_separator_calculation
    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    liquid_flow_rate = vessel_sizing.bottom_outlet_stream_flow_rate
    vapor_flow_rate = vessel_sizing.top_outlet_stream_flow_rate
    liquid_density = vessel_sizing.bottom_outlet_stream_density
    vapor_density = vessel_sizing.top_outlet_stream_density

    #Calculate the vapor-liquid separator factor
    sfactor = (liquid_flow_rate / vapor_flow_rate) * (vapor_density / liquid_density) ** 0.5

    #Design vapor velocity factor
    x = Math.log(sfactor)

    a = -1.942936
    b = -0.814894
    c = -0.17939
    d = -0.012379
    e = 0.000386235
    f = 0.00025955

    kv = Math.exp(a + b * x + c * x ** 2 + d * x ** 3 + e * x ** 4 + f * x ** 5)
    vmax = kv * ((liquid_density - vapor_density) / vapor_density) ** 0.5
    vmax = 10.0 #TODO
    #Calculate the minimum vessel cross-sectional area
    qv = vapor_flow_rate / (3600.0 * vapor_density)
    av = qv / vmax

    #Set a vessel diameter based on 6-in increments and calculate cross-sectional area
    dmin = ((4 * av) / PI) ** 0.5

    (1..100).each do |bxx|
      diff_d = dmin - (1 * bxx)
      if diff_d < 1
        diff_d = diff_d * 12
        if diff_d < 6
          diff_d = 6
        else
          diff_d = 12
        end
        diff_d = diff_d / 12.0
        vertical_d = bxx + diff_d
        break
      else
      end
    end

    area = PI * (dmin ** 2) / 4.0

    #Estimate the vapor-liquid inlet nozzle
    density_mix = (liquid_flow_rate + vapor_flow_rate) / ((liquid_flow_rate / liquid_density) + (vapor_flow_rate / vapor_density))
    umax_nozzle = 100 / (density_mix ** 0.5)
    umin_nozzle = 60 / (density_mix ** 0.5)

    qtotal = (liquid_flow_rate + vapor_flow_rate) / (3600.0 * density_mix)

    amax_nozzle = qtotal / umax_nozzle
    amin_nozzle = qtotal / umin_nozzle
    dmax_nozzle = (((4 * amax_nozzle) / PI) ** 0.5) * 12
    dmin_nozzle = (((4 * amin_nozzle) / PI) ** 0.5) * 12

    rupture_diameter = dmin_nozzle
    od_values = PipeSizing.determine_nominal_pipe_size(rupture_diameter)
    feed_nozzle_od = od_values[:proposed_diameter]

    #Calculate the required vessel volume
    ql = liquid_flow_rate / (3600.0 * liquid_density)
    fill_time = vessel_sizing.vs_liquid_hold_time

    v = ql * fill_time * 60

    #Calculate liquid height
    hl = v * (4.0 / (PI * dmin ** 2))

    #Upper = txtUpper.Value + 0
    upper = 10 #TODO
    #Lower = txtLower.Value + 0
    lower = 10 #TODO

    upper_limit = upper + (0.5 * feed_nozzle_od)
    lower_limit = lower + (0.5 * feed_nozzle_od)

    if upper_limit < 48
      upper_limit = 48
    end

    if lower_limit < 18
      lower_limit = 18
    end

    max_ll = (lower_limit + upper_limit) / 12.0
    minimum_h = hl + max_ll

    #Determine estimate for length
    vessel_design_ratio = vessel_sizing.vs_ld
    h = dmin * vessel_design_ratio

    (1..100).each do |cxx|
      diff_l = h - (1 * cxx)
      if diff_l < 1
        diff_l = diff_l * 12
        if diff_l <= 3
          diff_l = 3
        elsif diff_l > 3 && diff_l <= 6
          diff_l = 6
        elsif diff_l > 6 && diff_l <= 9
          diff_l = 9
        elsif diff_l > 9 && diff_l < 12
          diff_l = 12
        end
        diff_l = diff_l / 12
        h = cxx + diff_l
        break
      end
    end

    if h >= minimum_h
      vertical_h = h
    else
      high_h = 5 * dmin
      if high_h < minimum_h
        vertical_h = 0
        vessel_sizing.vs_notes = "Vertical design is not appropriate for this separation.  Considered a horizontal design instead."
      else
      end
    end

    lover_dvertical = vessel_design_ratio

    vessel_sizing.vs_dnm_vl_separation_factor = sfactor.round(4)
    vessel_sizing.vs_dnm_vapor_velocity_factor_kv = kv.round(2)
    vessel_sizing.vs_dnm_vl_separation_factor = vmax.round(2)
    vessel_sizing.vs_dnm_dmin = dmin.round(2)
    #UserFormVesselDesign.lblNozzleVelocityMin = umin_nozzle.round(2)
    #UserFormVesselDesign.lblNozzleVelocityMax = umax_nozzle.round(2)
    #UserFormVesselDesign.lblLiquidVolume = v.round(2)
    #UserFormVesselDesign.lblLiquidHeight = hl.round(2)
    #UserFormVesselDesign.lblVerticalSeparatorDiameter = vertical_d.round(2)
    #UserFormVesselDesign.lblVerticalSeparatorLength = vertical_h.round(2)

    #Determine Wire Mesh Design
    if vessel_sizing.vs_include_wire_mesh == true
      k_factor = vessel_sizing.vs_dmd_k_factor
      va = k_factor * ((liquid_density - vapor_density) / vapor_density) ** 0.5
      vd = 0.75 * va
      vapor_volume = vapor_flow_rate / (vapor_density * 60.0)
      vessel_area = vapor_volume / (60.0 * vd)
      mesh_diameter = ((4 * vessel_area) / PI) ** 0.5
      dmin = mesh_diameter
      (1..100).each do |gxx|
        diff_d = mesh_diameter - (1 * gxx)
        if diff_d < 1
          diff_d = diff_d * 12
          if diff_d < 6
            diff_d = 6
          else
            diff_d = 12
          end
          diff_d = diff_d / 12.0
          mesh_diameter = gxx + diff_d
          break
        end
      end

      #Line1:
      actual_area = (PI * ((mesh_diameter * 12) - 4 - 0.75) ** 2) / (4.0 * 144.0) #Accounts for 2" support ring and 3/8" thickness
      actual_velocity = vd * (vessel_area / actual_area)

      #Velocity Limitation Check
      if actual_velocity > vd
        mesh_diameter = mesh_diameter + 0.5
        #GoTo Line1:
      elsif actual_velocity < 0.3 * vd
        mesh_diameter = mesh_diameter - 0.5
        #GoTo Line1:
      end

      #Pressure Drop Estimation in "H20
      pressure_drop1 = 0.2 * vd ** 2 * vapor_density
      pressure_drop2 = 0.12 * vd ** 2 * vapor_density

      hl = v * (4 / (PI * dmin ** 2))

      minimum_h = hl + max_ll

      #Determine estimate for length
      vessel_design_ratio = vessel_sizing.vs_ld
      h = dmin * vessel_design_ratio

      (1..100).each do |hxx|
        diff_l = h - (1 * hxx)
        if diff_l < 1
          diff_l = diff_l * 12
          if diff_l <= 3
            diff_l = 3
          elsif diff_l > 3 && diff_l <= 6
            diff_l = 6
          elsif diff_l > 6 && diff_l <= 9
            diff_l = 9
          elsif diff_l > 9 && diff_l < 12
            diff_l = 12
          end
          diff_l = diff_l / 12
          h = hxx + diff_l
          break
        end
      end

      if h >= minimum_h
        vertical_h = h
      else
        high_h = 5 * dmin
        if high_h < minimum_h
          vertical_h = 0
          vessel_sizing.vs_notes = "Vertical design is not appropriate for this separation.  Considered a horizontal design instead."
        else
        end
      end

      vessel_sizing.vs_dmd_allow_vapor_velocity = va.round(2)
      vessel_sizing.vs_dmd_design_velocity = vd.round(2)
      vessel_sizing.vs_dmd_mesh_diameter = dmin.round(2)
      vessel_sizing.vs_dmd_est_press_drop = pressure_drop2.round(2)
      #UserFormVesselDesign.lblEstPressureDropLowDensity = pressure_drop1.round(2)
      vessel_sizing.vs_dmd_diameter = mesh_diameter.round(2)
      #UserFormVesselDesign.lblWireMeshVesselLength = vertical_h.round(2)
    else
      vessel_sizing.vs_dmd_allow_vapor_velocity = ""
      vessel_sizing.vs_dmd_design_velocity = ""
      vessel_sizing.vs_dmd_mesh_diameter = ""
      vessel_sizing.vs_dmd_est_press_drop = ""
      #UserFormVesselDesign.lblEstPressureDropLowDensity = ""
      vessel_sizing.vs_dmd_diameter = ""
      #UserFormVesselDesign.lblWireMeshVesselLength = ""
    end

    vessel_sizing.save
    render :json => {:success => true}
  end

  def horizontal_separator_calculation
    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    liquid_flow_rate = vessel_sizing.bottom_outlet_stream_flow_rate
    oil_flow_rate = liquid_flow_rate
    vapor_flow_rate = vessel_sizing.top_outlet_stream_flow_rate
    liquid_density = vessel_sizing.bottom_outlet_stream_density
    oil_density = liquid_density
    vapor_density = vessel_sizing.top_outlet_stream_density

    if vessel_sizing.hs_consider_water_settling == true
      if vessel_sizing.hs_water_flowRate != ""
        water_flow_rate = vessel_sizing.hs_water_flowRate
        water_density = vessel_sizing.hs_water_density

        oil_viscosity = vessel_sizing.bottom_outlet_stream_viscosity

        total_liquid_flow_rate = water_flow_rate + liquid_flow_rate
        total_liquid_density = ((water_flow_rate / total_liquid_flow_rate) * water_density) + ((oil_flow_rate / total_liquid_flow_rate) * oil_density)

        liquid_flow_rate = total_liquid_flow_rate
        liquid_density = total_liquid_density
      end
    end

    #Calculate the vapor-liquid separator factor
    sfactor = (liquid_flow_rate / vapor_flow_rate) * (vapor_density / liquid_density) ** 0.5

    #Design vapor velocity factor
    x = Math.log(sfactor)

    a = -1.942936
    b = -0.814894
    c = -0.17939
    d = -0.012379
    e = 0.000386235
    f = 0.00025955

    kv = Math.exp(a + b * x + c * x ** 2 + d * x ** 3 + e * x ** 4 + f * x ** 5)

    kh = 1.25 * kv

    #Calculate the maximum design vapor velocity
    uv_max = kh * ((liquid_density - vapor_density) / vapor_density) ** 0.5

    #Calculate the minimum vessel cross-sectional area
    qv = vapor_flow_rate / (3600.0 * vapor_density)

    #Calculate the required vapor flow area
    av_min = qv / uv_max

    #Assuming vapor occupies 20% of the total cross sectional area
    v_vol = 0.2

    a_total_min = av_min / v_vol

    dmin_h = ((4 * a_total_min) / PI) ** 0.5

    horizontal_d = 0
    (1..100).each do |dxx|
      diff_d = dmin_h - (1 * dxx)
      if diff_d < 1
        diff_d = diff_d * 12
        if diff_d < 6
          diff_dd = 6
        else
          diff_d = 12
        end
        diff_d = diff_d / 12
        horizontal_d = dxx + diff_d
        break
      end
    end

    #Determine Liquid area
    #vessel_design_ratio = UserFormVesselDesign.txtLoverDHS.Value + 0
    vessel_design_ratio = 10 #TODO

    l = vessel_design_ratio * dmin_h

    al = (1 - v_vol) * a_total_min

    #Line1:
    v_ves = a_total_min * l

    t = (60 * al * l * liquid_density) / liquid_flow_rate

    fill_time = vessel_sizing.hs_liquid_surge_time

    if t >= fill_time
      r = 0
    else
      length = (fill_time * liquid_flow_rate) / (60.0 * al * liquid_density)
      lover_dof5 = 5 * dmin_h
      if length < lover_dof5
        l = length
      else
        v_vol = v_vol - 0.001
        if v_vol <= 0.15
        else
          #GoTo Line3:
        end
        #l = InputBox("The calculated liquid surge time (" & t, 1) & " mins) at the preliminary horizontal vessel design is less than the required liquid surge time of " & fill_time & " mins.  Consider increasing the vessel length to a value preferably less than or equal to the " & lover_dof5 & " " & LoverDof5Unit & ".  Please input length to consider in " & LoverDof5Unit & ".", "Increasing Vessel length!") + 0
        #GoTo Line1:
      end
    end

    (1..100).each do |cxx|
      diff_l = l - (1 * cxx)
      if diff_l < 1
        diff_l = diff_l * 12
        if diff_l <= 3
          diff_l = 3
        elsif diff_l > 3 && diff_l <= 6
          diff_l = 6
        elsif diff_l > 6 && diff_l <= 9
          diff_l = 9
        elsif diff_l > 9 && diff_l < 12
          diff_l = 12
        end
        diff_l = diff_l / 12.0
        l = cxx + diff_l
        break
      end
    end

    horizontal_l = l
    lover_dhorizontal = vessel_design_ratio

    #Determine Water Settling
    if vessel_sizing.hs_consider_water_settling == true
      x = (oil_flow_rate / oil_density) / ((oil_flow_rate / oil_density) + (water_flow_rate / water_density))
      fs = (x ** 2) / (10 ** (1.82 * (1 - x)))
      oil_viscosity = oil_viscosity * (6.72 * 10 ** -4)
      vt = (44.7 * 10 ** -8) * (((water_density - oil_density) * fs) / oil_viscosity)

      re = (5 * 10 ** -4) * ((oil_density * vt) / oil_viscosity)

      aa = 0.919832
      bb = -0.091353
      cc = -0.017157
      dd = 0.0029258
      ee = -0.00011591

      re = 10 #TODO
      vsover_vt = aa + (bb * Math.log(re)) + (cc * Math.log(re ** 2)) + (dd * Math.log(re ** 3)) + (ee * Math.log(re ** 4))
      vs = vsover_vt * vt
      ql = liquid_flow_rate / (3600.0 * liquid_density)
      liquid_volume = al * horizontal_l
      liquid_volume1 = ql * (t * 60)

      liquid_level = 0
      (1..1000).each do |i|
        liquid_level = i * (horizontal_d / 1000)
        alpha = Math.acos(1 - (2.0 * (liquid_level / horizontal_d))) * (180.0 / PI)
        part1 = Math.sin(alpha * (PI / 180.0))
        part2 = Math.cos(alpha * (PI / 180.0))
        partial_cylinder_volume = horizontal_l * (horizontal_d / 2) ** 2 * ((alpha / 57.3) - (part1 * part2))
        if partial_cylinder_volume >= liquid_volume
          break
        end
      end

      settling_zone_l = (liquid_level * ql) / (al * vs)

      if settling_zone_l > horizontal_l
        #msg1 = MsgBox("The length of the settling zone is greater than the horizontal length of the separator.  Therefore, the water might not have enough resident time to drop out of the oil phase.  Please consider updating the liquid surge capacity.", vbOKOnly, "Inadequate Design For Water Settling!")
        vessel_sizing.hs_notes = "The length of the settling zone is greater than the horizontal length of the separator.  Therefore, the water might not have enough resident time to drop out of the oil phase."
      else
        vessel_sizing.hs_notes = ""
      end
      vessel_sizing.settling_zone_length = settling_zone_l.round(2)
    end

    vessel_sizing.hs_vl_separation_factor = sfactor.round(4)
    vessel_sizing.hs_vapor_velocity_factor_kv = kv.round(2)
    vessel_sizing.hs_max_design_vapor_velocity_vmax = uv_max.round(2)
    vessel_sizing.hs_vapor_flow_area = av_min.round(2)
    vessel_sizing.hs_liquid_flow_area = al.round(2)
    vessel_sizing.hs_dmin = dmin_h.round(2)
    vessel_sizing.hs_vessel_volume = v_ves.round(2)
    vessel_sizing.hs_calculated_liquid_surge_time = t.round(2)
    vessel_sizing.hs_horizontal_separator_diameter = horizontal_d.round(2)
    vessel_sizing.hs_horizontal_separator_length = horizontal_l.round(2)

    #Determine Wire Mesh Design
    if vessel_sizing.hs_wire_mesh_design_include == true
      kfactor = vessel_sizing.hs_k_factor

      va = kfactor * ((liquid_density - vapor_density) / vapor_density) ** 0.5
      vd = 0.75 * va

      vapor_volume = vapor_flow_rate / (vapor_density * 60.0)
      vessel_area = vapor_volume / (60.0 * vd)
      mesh_diameter = ((4 * vessel_area) / PI) ** 0.5
      dmin = mesh_diameter

      (1..100).each do |gxx|
        diff_d = mesh_diameter - (1 * gxx)
        if diff_d < 1
          diff_d = diff_d * 12
          if diff_d < 6
            diff_d = 6
          else
            diff_d = 12
          end
          diff_d = diff_d / 12
          mesh_diameter = gxx + diff_d
          break
        end
      end

      #Line2:
      actual_area = (PI * ((mesh_diameter * 12) - 4 - 0.75) ** 2) / (4.0 * 144.0) #Accounts for 2" support ring and 3/8" thickness
      actual_velocity = vd * (vessel_area / actual_area)

      #Velocity Limitation Check
      if actual_velocity > vd
        mesh_diameter = mesh_diameter + 0.5
        #GoTo Line2:
      elsif actual_velocity < 0.3 * vd
        mesh_diameter = mesh_diameter - 0.5
        #GoTo Line2:
      end

      #Pressure Drop Estimation in "H20
      pressure_drop1 = 0.2 * vd ** 2 * vapor_density
      pressure_drop2 = 0.12 * vd ** 2 * vapor_density

      vessel_sizing.hs_allow_vapor_velocity = va.round(2)
      vessel_sizing.hs_design_velocity = vd.round(2)
      vessel_sizing.hs_mesh_diameter = dmin.round(2)
      vessel_sizing.hs_est_press_drop = pressure_drop2.round(2)
      #UserFormVesselDesign.lblEstPressDropStandard = pressure_drop1, 2)
    else
      vessel_sizing.hs_allow_vapor_velocity = ""
      vessel_sizing.hs_design_velocity = ""
      vessel_sizing.hs_mesh_diameter = ""
      vessel_sizing.hs_est_press_drop = ""
      #UserFormVesselDesign.lblEstPressDropStandard = ""
    end

    vessel_sizing.save
    render :json => {:success => true}
  end

  def decanter_calculation
    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    liquid_flow_rate_h = vessel_sizing.bottom_outlet_stream_flow_rate
    liquid_flow_rate_l = vessel_sizing.top_outlet_stream_flow_rate
    liquid_density_h = vessel_sizing.bottom_outlet_stream_density
    liquid_density_l = vessel_sizing.top_outlet_stream_density
    liquid_viscosity_h = vessel_sizing.bottom_outlet_stream_viscosity
    liquid_viscosity_l = vessel_sizing.top_outlet_stream_viscosity
    #particle_diameter = UserFormVesselDesign.txtparticle_diameter.Value + 0 #TODO
    particle_diameter = 10 #TODO

    #Unit Conversion
    ql = liquid_flow_rate_l / (3600.0 * liquid_density_l)
    qh = liquid_flow_rate_h / (3600.0 * liquid_density_h)

    ul = liquid_viscosity_l * (6.72 * 10 ** -4)
    uh = liquid_viscosity_h * (6.72 * 10 ** -4)

    #Check Dispersion Phase
    theta = (ql / qh) * ((liquid_density_l * uh) / (liquid_density_h * ul)) ** 0.3

    if theta < 0.3
      dispersal = "Light Phase Always"
    elsif theta > 0.3 && theta < 0.5
      dispersal = "Light Phase Propably"
    elsif theta > 0.5 && theta < 2
      dispersal = "Phase Inversion"
    elsif theta > 2 && theta < 3.3
      dispersal = "Heavy Phase Probably"
    elsif theta > 3.3
      dispersal = "Heavy Phase Always"
    end

    liquid_liquid_vessel_design_ratio = vessel_sizing.dc_ld

    vl = 0, vh = 0
    if dispersal = "Light Phase Always" || dispersal = "Light Phase Probably"
      vl = ((32.2 * particle_diameter ** 2 * (liquid_density_l - liquid_density_h)).abs / (18.0 * uh))
      qc = qh
      decanter_d = ((qc / vl) / (0.8 * liquid_liquid_vessel_design_ratio)) ** 0.5 #Assume I is 80% of Diameter
      decanter_l = liquid_liquid_vessel_design_ratio * decanter_d
    elsif dispersal = "Heavy Phase Probably" || dispersal = "Heavy Phase Always"
      vh = ((32.2 * particle_diameter ** 2 * (liquid_density_h - liquid_density_l)).abs / (18.0 * ul))
      qc = ql
      decanter_d = ((qc / vh) / (0.8 * liquid_liquid_vessel_design_ratio)) ** 0.5 #Assume I is 80% of Diameter
      decanter_l = liquid_liquid_vessel_design_ratio * decanter_dd
    end

    actual_decanter_l = 0
    (1..100).each do |cxx|
      diff_l = decanter_l - (1 * cxx)
      if diff_l < 1
        diff_l = diff_l * 12
        if diff_l <= 3
          diff_l = 3
        elsif diff_l > 3 && diff_l <= 6
          diff_l = 6
        elsif diff_l > 6 && diff_l <= 9
          diff_l = 9
        elsif diff_l > 9 && diff_l < 12
          diff_l = 12
        end
        diff_l = diff_l / 12
        actual_decanter_l = cxx + diff_l
        break
      end
    end

    decanter_d = 10 #TODO inf
    actual_decanter_d = 0
    (1..100).each do |dxx|
      diff_d = decanter_d - (1 * dxx)
      if diff_d < 1
        diff_d = diff_d * 12
        if diff_d < 6
          diff_d = 6
        else
          diff_d = 12
        end
        diff_d = diff_d / 12
        actual_decanter_d = dxx + diff_d
        break
      end
    end

    #interface Level (assuming that the interface is being held one foot below the top of the vessel)
    h = 0.5
    r = actual_decanter_d / 2.0

    interface = 2 * (r ** 2 - h ** 2) ** 0.5

    ai = interface * actual_decanter_l

    #Check the Nre for each phase to determine probability of proper separation
    part1 = (1.0 / 2.0) * PI * (r ** 2)
    part2 = h * (r ** 2 - h ** 2) ** 0.5
    part3 = r ** 2 * Math.asin(h / r)

    al = part1 - part2 - part3
    ah = PI * r ** 2 - al

    p = 2 * r * Math.acos(h / r)

    dl = (4 * al) / (interface + p)
    dh = (4 * ah) / (interface + (2 * PI * r) - p)

    velocity_l = ql / al
    velocity_h = qh / ah

    nre_l = (dl * velocity_l * liquid_density_l) / ul
    nre_h = (dh * velocity_h * liquid_density_h) / uh

    if nre_h < 5000
      notes1 = "Little problem in separation in heavy phase."
    elsif nre_h > 5000 && nre_h < 20000
      notes1 = "Some hinderance in separation in heavy phase."
    elsif nre_h > 20000 && nre_h < 50000
      notes1 = "Major problems may exist in separation in heavy phase."
    elsif nre_h > 50000
      notes1 = "Poor separation in separation in heavy phase."
    end

    if nre_l < 5000
      notes2 = "Little problem in separation in light phase."
    elsif nre_l > 5000 && nre_l < 20000
      notes2 = "Some hinderance in separation in light phase."
    elsif nre_l > 20000 && nre_l < 50000
      notes2 = "Major problems may exist in separation in light phase."
    elsif nre_l > 50000
      notes2 = "Poor separation in separation in light phase."
    end

    #checking for coalescence time (assuming dispersion band is 10% of vessel diameter)
    if dispersal = "Light Phase Always" || dispersal = "Light Phase Probably"
      coalescence_time = ((1 / 2) * (0.1 * decanter_d) * (ai / ql)) / 60.0

      if coalescence_time < 2
        note3 = "Time available to cross the dispersed band may be too low."
      elsif coalescence_time > 5
        note3 = "Time available to cross the dispersed band may be too high."
      else
        note3 = "Time available to cross the dispersed band is acceptable."
      end

    elsif dispersal = "Heavy Phase Probably" || dispersal = "Heavy Phase Always"
      coalescence_time = ((1 / 2) * (0.1 * decanter_d) * (ai / qh)) / 60

      if coalescence_time < 2
        note3 = "Time available to cross the dispersed band may be too low."
      elsif coalescence_time > 5
        note3 = "Time available to cross the dispersed band may be too high."
      else
        note3 = "Time available to cross the dispersed band is acceptable."
      end

    end

    vessel_sizing.dc_dispersed_phase = theta.round(2)
    vessel_sizing.dc_settling_rate_of_light_phase = vl.round(2)
    vessel_sizing.dc_settling_rate_of_heavy_phase = vh.round(2)
    vessel_sizing.dc_area_interface = ai.round(2)
    vessel_sizing.dc_cross_sectional_area_light = al.round(2)
    vessel_sizing.dc_cross_sectional_area_heavy = ah.round(2)
    vessel_sizing.dc_coalescence_time = coalescence_time.round(2)
    vessel_sizing.dc_reynolds_number_light = nre_l.round(0)
    vessel_sizing.dc_reynolds_number_heavy = nre_h.round(0)
    vessel_sizing.dc_diameter = actual_decanter_d.round(2)
    vessel_sizing.dc_length = actual_decanter_l.round(2)
    vessel_sizing.dc_notes = notes1 + "\n" + notes2 + "\n" + note3

    vessel_sizing.save
    render :json => {:success => true}
  end

  def settler_calculation
    vessel_sizing = VesselSizing.find(params[:vessel_sizing_id])
    project = vessel_sizing.project

    liquid_flow_rate_h = vessel_sizing.bottom_outlet_stream_flow_rate
    liquid_flow_rate_l = vessel_sizing.top_outlet_stream_flow_rate
    liquid_density_h = vessel_sizing.bottom_outlet_stream_density
    liquid_density_l = vessel_sizing.top_outlet_stream_density
    liquid_viscosity_h = vessel_sizing.bottom_outlet_stream_viscosity
    liquid_viscosity_l = vessel_sizing.top_outlet_stream_viscosity

    fl = (liquid_flow_rate_l * 7.4805) / (liquid_density_l * 60.0)
    fh = (liquid_flow_rate_h * 7.4805) / (liquid_density_h * 60.0)

    vtl = ((12.86 * ((liquid_density_h - liquid_density_l) / 62.4)) / liquid_viscosity_l).abs #Terminal velocity of heavy droplet in light fluid
    vth = ((12.86 * ((liquid_density_l - liquid_density_h) / 62.4)) / liquid_viscosity_h).abs #Terminal velocity of light droplet in heavy fluid

    #Determine highest calculated terminal velocity of the aqueous droplets
    vtl = 1.2 * vth * (fl / fh)

    if vtl > 10
      vtl = 10
    end

    liquid_liquid_vessel_design_ratio = vessel_sizing.st_ld

    #Assuming fl and fh = 2
    flight = 2
    fheavy = 2
    aa = 1.889 * (((vtl * fheavy * fh) + (vth * flight * fl)) / (liquid_liquid_vessel_design_ratio * vtl * vth))
    bb = 3.505 * ((flight * fl * fheavy * fh) / (liquid_liquid_vessel_design_ratio ** 2 * vtl * vth))

    settler_d1 = ((aa / 2.0) + ((aa ** 2 - 4 * bb) ** 0.5) / 2.0) ** 0.5
    settler_d2 = ((aa / 2.0) - ((aa ** 2 - 4 * bb) ** 0.5) / 2.0) ** 0.5

    part1 = (1.2 * settler_d1)
    part2 = (7.48 * liquid_liquid_vessel_design_ratio * settler_d1 * vtl) / (flight * fl)
    part3 = 38.4 / (PI * settler_d1)
    at = part1 / (part2 - part3)

    part4 = (1.2 * settler_d1)
    part5 = (7.48 * liquid_liquid_vessel_design_ratio * settler_d1 * vth) / (fheavy * fh)
    part6 = 38.4 / (PI * settler_d1)
    ab = part4 / (part5 - part6)

    ht = 7.48 * ((at * liquid_liquid_vessel_design_ratio * settler_d1 * vtl) / (flight * fl))
    hb = 7.48 * ((ab * liquid_liquid_vessel_design_ratio * settler_d1 * vth) / (fheavy * fh))

    top_level = (ht / (12 * settler_d1)) * 100.0
    bottom_level = (hb / (12 * settler_d1)) * 100.0

    if top_level >= 30 && top_level <= 70
      note1 = "The height of the continuous top phase in the top of the vessel is within acceptable range."
    else
      note1 = "The height of the continuous top phase in the top of the vessel is outside of the acceptable range."
    end

    if bottom_level >= 30 && bottom_level <= 70
      note2 = "The height of the continuous bottom phase in the bottom of the vessel is within acceptable range."
    else
      note2 = "The height of the continuous bottom phase in the bottom of the vessel is outside of the acceptable range."
    end

    setter_length = liquid_liquid_vessel_design_ratio * settler_d1

    actual_settler_l = 0
    (1..100).each do |cxx|
      diff_l = setter_length - (1 * cxx)
      if diff_l < 1
        diff_l = diff_l * 12
        if diff_l <= 3
          diff_l = 3
        elsif diff_l > 3 && diff_l <= 6
          diff_l = 6
        elsif diff_l > 6 && diff_l <= 9
          diff_l = 9
        elsif diff_l > 9 && diff_l < 12
          diff_l = 12
        end
        diff_l = diff_l / 12.0
        actual_settler_l = cxx + diff_l
        break
      end
    end

    actual_settler_d = 0
    (1..100).each do |dxx|
      diff_d = settler_d1 - (1 * dxx)
      if diff_d < 1
        diff_d = diff_d * 12
        if diff_d < 6
          diff_dd = 6
        else
          diff_d = 12
        end
        diff_d = diff_d / 12
        actual_settler_d = dxx + diff_d
        break
      end
    end

    settler_interface = (settler_d1 * 12.0) - (ht + hb)
    hc_residence_time = ht / vth

    vth = vth / (12.0 * 60.0)
    vtl = vtl / (12.0 * 60.0)

    vessel_sizing.st_light_phase_flowrate = fl.round(1)
    vessel_sizing.st_heavy_phase_flowrate = fh.round(1)
    vessel_sizing.st_light_phase_terminal_velocity = vtl.round(3)
    vessel_sizing.st_heavy_phase_terminal_velocity = vth.round(3)
    vessel_sizing.st_light_phase_height = ht.round(1)
    vessel_sizing.st_heavy_phase_height = hb.round(1)
    vessel_sizing.st_interface_height = settler_interface.round(1)
    vessel_sizing.st_light_phase_residence_time = hc_residence_time.round(1)
    vessel_sizing.st_diameter = actual_settler_d.round(2)
    vessel_sizing.st_length = actual_settler_l.round(2)
    vessel_sizing.st_notes = note1 + "\n" + note2

    vessel_sizing.save
    render :json => {:success => true}
  end

  private

  def default_form_values
    @streams = []

    @vessel_sizing = @company.vessel_sizings.find(params[:id]) rescue @company.vessel_sizings.new
    @comments = @vessel_sizing.comments
    @new_comment = @vessel_sizing.comments.new

    @attachments = @vessel_sizing.attachments
    @new_attachment = @vessel_sizing.attachments.new
  end

  def volume_calculation(shell_diameter, shell_length, head_type)
    #Determine Full liquid volume in head.  Note that the diameter is meant to be the inner diameter of the vessel but is approximated as the outer diameter
    head_volume = 0
    if head_type == "Hemispherical"
      head_volume = PI * (shell_diameter ** 3 / 12)
    elsif head_type == "Ellipsoidal"
      head_volume = PI * (shell_diameter ** 3 / 24)
    elsif head_type == "Torispherical" #Alternatively for code construction, per page 88 on Process Equipment Design by Lloyd e Brownell, Edwin H Young.  if designed to 3 x thickness, then Perry's 10-140 gives an alternate equation.
      head_volume = 0.0847 * shell_diameter ** 3
    end

    #Determine total liquid volume
    full_volume = (shell_length * (shell_diameter / 2) ** 2 * PI) + (head_volume * 2)
  end
end
