class Admin::PumpSizingsController < AdminController

  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]
  
  def index
  	@pump_sizings = @company.pump_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))

  	if @user_project_settings.client_id.nil?     
  		flash[:error] = "Please Update Project Setting"      
  		redirect_to admin_sizings_path
  	end
  end
  
  def new
  	@pump_sizing = @company.pump_sizings.new
  end
  
  def create
  	pump_sizing = params[:pump_sizing]
  	pump_sizing[:created_by] = pump_sizing[:updated_by] = current_user.id
  	@pump_sizing = @company.pump_sizings.new(pump_sizing)

  	if @pump_sizing.save
  		@pump_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
  		if request.xhr?
  			render :json => {:success => true, :pump_sizing_id => @pump_sizing.id}
  		else
  			flash[:notice] = "New pump sizing created successfully."
  			redirect_to admin_pump_sizings_path
  		end
  	else
  		render :new
  	end
  end
  
  def edit
  	@pump_sizing = @company.pump_sizings.find(params[:id])    

  	if !@pump_sizing.process_basis_id.nil?
  		heat_and_meterial_balance = HeatAndMaterialBalance.find(@pump_sizing.process_basis_id)
  		@streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
  	end
  end   
  
  def update
  	pump_sizing = params[:pump_sizing]
  	pump_sizing[:updated_by] = current_user.id

  	@pump_sizing = @company.pump_sizings.find(params[:id])    

  	if !@pump_sizing.process_basis_id.nil?
  		heat_and_meterial_balance = HeatAndMaterialBalance.find(@pump_sizing.process_basis_id)
  		@streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
  	end

  	if @pump_sizing.update_attributes(pump_sizing)
  		if request.xhr?
  			render :json => {:success => true, :pump_sizing_id => @pump_sizing.id}
  		else
  			flash[:notice] = "Updated pump sizing successfully."
  			redirect_to admin_pump_sizings_path       
  		end
  	else      
  		render :edit
  	end
  end
  
  def destroy
  	@pump_sizing = @company.pump_sizings.find(params[:id])
  	if @pump_sizing.destroy
  		flash[:notice] = "Deleted #{@pump_sizing.centrifugal_pump_tag} successfully."
  		redirect_to admin_pump_sizings_path
  	end
  end

  def clone
  	@pump_sizing = @company.pump_sizings.find(params[:id])
  	new = @pump_sizing.deep_clone(
  		[	"suction_pipings",
  			{"pump_sizing_discharges" => "discharge_circuit_piping"},
  			"centrifugal_pumps"
  			])

  	new.centrifugal_pump_tag = params[:tag]
  	if new.save
  		render :json => {:error => false, :url => edit_admin_pump_sizing_path(new) }
  	else
  		render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
  	end
  	return
  end

  def get_stream_values
  	form_values = {}

  	heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
  	property = heat_and_meterial_balance.heat_and_material_properties

  	pressure = property.where(:phase => "Overall", :property => "Pressure").first    
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first if pressure.nil?
  	pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
  	form_values[:pressure_value] = pressure_stream.stream_value.to_f rescue nil

  	temperature = property.where(:phase => "Overall", :property => "Temperature").first
  	temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
  	form_values[:temperature_value] = temperature_stream.stream_value.to_f rescue nil

  	mass_vapor_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
  	mass_vapor_fraction_stream = mass_vapor_fraction.streams.where(:stream_no => params[:stream_no]).first
  	form_values[:mass_vapor_fraction] = mass_vapor_fraction_stream.stream_value.to_f rescue nil

  	mass_flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
  	mass_flow_rate_stream = mass_flow_rate.streams.where(:stream_no => params[:stream_no]).first
  	form_values[:mass_flow_rate_value] = mass_flow_rate_stream.stream_value.to_f rescue nil

  	density = property.where(:phase => "Overall", :property => "Mass Density").first
  	density_stream = density.streams.where(:stream_no => params[:stream_no]).first
  	form_values[:density] = density_stream.stream_value.to_f rescue nil

  	viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
  	viscosity_stream = viscosity.streams.where(:stream_no => params[:stream_no]).first
  	form_values[:viscosity] = viscosity_stream.stream_value.to_f rescue nil

  	mass_heat_capacity = property.where(:phase => "Overall", :property => "Mass Heat Capacity").first
  	mass_heat_capacity_stream = mass_heat_capacity.streams.where(:stream_no => params[:stream_no]).first
  	form_values[:mass_heat_capacity] = mass_heat_capacity_stream.stream_value.to_f rescue nil

  	render :json => form_values    
  end 

  def get_change_properties_stream_values
    form_values = {}

    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    property = heat_and_meterial_balance.heat_and_material_properties

    pressure = property.where(:phase => "Overall", :property => "Pressure").first    
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first if pressure.nil?
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure] = pressure_stream.stream_value.to_f rescue nil

    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature] = temperature_stream.stream_value.to_f rescue nil

    vapor_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
    begin
      vapor_fraction_stream = vapor_fraction.streams.where(:stream_no => params[:stream_no]).first
      form_values[:vapor_fraction] = vapor_fraction_stream.stream_value.to_f rescue nil
    rescue Exception => e
      form_values[:vapor_fraction] = 0.0
    end

    vapor_density = property.where(:phase => "Vapour", :property => "Mass Density").first
    begin
      density_stream = vapor_density.streams.where(:stream_no => params[:stream_no]).first
      form_values[:vapor_density] = density_stream.stream_value.to_f rescue nil
    rescue Exception
      form_values[:vapor_density] = 0.0
    end

    vapor_viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
    begin
      viscosity_stream = vapor_viscosity.streams.where(:stream_no => params[:stream_no]).first
      form_values[:vapor_viscosity] = viscosity_stream.stream_value.to_f rescue nil
    rescue Exception
      form_values[:vapor_viscosity] = 0.0
    end

    vapor_mw = property.where(:phase => "Vapour", :property => "Molecular Weight").first
    begin
      mw_stream = vapor_mw.streams.where(:stream_no => params[:stream_no]).first
      form_values[:vapor_mw] =   mw_stream.stream_value.to_f rescue nil
    rescue Exception
      form_values[:vapor_mw] = 0.0 
    end

    vapor_k = property.where(:phase => "Vapour", :property => "Cp/Cv (Gamma)").first
    begin
      k_stream = vapor_k.streams.where(:stream_no => params[:stream_no]).first
      form_values[:vapor_mw] = k_stream.stream_value.to_f rescue nil
    rescue Exception => e
      form_values[:vapor_mw] = 0.0
    end

    liquid_density = property.where(:phase => "Light Liquid", :property => "Mass Density").first
    density_stream = liquid_density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_density] = density_stream.stream_value.to_f rescue nil

    liquid_viscosity = property.where(:phase => "Light Liquid", :property => "Viscosity").first
    viscosity_stream = liquid_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_viscosity] = viscosity_stream.stream_value.to_f rescue nil

    liquid_surface_tension = property.where(:phase => "Light Liquid", :property => "Surface Tension").first
    surface_tension_stream = liquid_surface_tension.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_surface_tension] = surface_tension_stream.stream_value.to_f rescue nil

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
  
  def clone_circuit_piping
    if (params[:sizing_type] == "pump")
      	src_circuit_pipings = PumpSizingDischarge.find(params[:source_cp]).discharge_circuit_piping
        trg_pump_sizing_discharge = PumpSizingDischarge.find(params[:target_cp])

       	src_circuit_pipings.each do |circuit_piping|
      		DischargeCircuitPiping.create({
      			:discharge_circuit_pipings_id => trg_pump_sizing_discharge.id,
      			:discharge_circuit_pipings_type => "PumpSizingDischarge",
      			:fitting => circuit_piping.fitting,
      			:fitting_tag => circuit_piping.fitting_tag,
      			:pipe_size => circuit_piping.pipe_size,
      			:pipe_schedule => circuit_piping.pipe_schedule,
      			:pipe_id => circuit_piping.pipe_id,
      			:per_flow => circuit_piping.per_flow,
      			:ds_cv => circuit_piping.ds_cv,
      			:length => circuit_piping.length,
      			:elev => circuit_piping.elev,
      			:delta_p => circuit_piping.delta_p
      			})     
  	    end
    elsif (params[:sizing_type] == "line")     
      src_line_sizing = LineSizing.find(params[:source_cp])
      src_line_segments = src_line_sizing.pipe_sizings
        trg_pump_sizing_discharge = PumpSizingDischarge.find(params[:target_cp])

        src_line_segments.each do |circuit_piping|
          DischargeCircuitPiping.create({
            :discharge_circuit_pipings_id => trg_pump_sizing_discharge.id,
            :discharge_circuit_pipings_type => "PumpSizingDischarge",
            :fitting => circuit_piping.fitting_id,
            :fitting_tag => circuit_piping.fitting_tag,
            :pipe_size => circuit_piping.pipe_size,
            :pipe_schedule => circuit_piping.pipe_schedule,
            :pipe_id => circuit_piping.pipe_id,
            :ds_cv => circuit_piping.ds_cv,
            :length => circuit_piping.length,
            :elev => circuit_piping.elev
            })     
        end
  end
              
    render :json => {:success=>true}
  end
  
  def pump_sizing_summary
  	@pump_sizings = @company.pump_sizings.all    
  end
  
  def set_breadcrumbs
  	super
  	@breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
  	@breadcrumbs << { :name => 'Pump sizings', :url => admin_pump_sizings_path }
  end

  def suction_side_hydraulics
  	calculated_values = {}
  	pump_sizing = PumpSizing.find(params[:pump_sizing_id])
  	project = pump_sizing.project
  	log = CustomLogger.new('pump_sizing')

  	pipeID         = (1..100).to_a
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

  	uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
  	barometric_pressure = uom[:factor] * project.barometric_pressure
  	log.info("converted barometric_pressure = #{barometric_pressure}")

  	pipe_roughness = pump_sizing.convert_to_base_unit(:su_pipe_roughness)
  	log.info("converted pipe roughness = #{pipe_roughness}")

  	e = pipe_roughness
  	e = e/12.0

  	log.info("converted pipe roughness from inches to feet = #{e}")

  	relief_rate     = pump_sizing.convert_to_base_unit(:su_mass_flow_rate)
  	log.info("converted relief_rate = #{relief_rate}")

  	relief_pressure = pump_sizing.convert_to_base_unit(:su_pressure)
  	log.info("converted relief_pressure = #{relief_pressure}")

  	density         = pump_sizing.convert_to_base_unit(:su_density)
  	log.info("converted density = #{density}")

  	viscosity       = pump_sizing.convert_to_base_unit(:su_viscosity)
  	log.info("converted viscosity = #{viscosity}")

  	suction_pipings = pump_sizing.suction_pipings
  	count           = suction_pipings.size	

  	suction_sum_fitting_dp = 0.0
  	suction_sum_control_valve_dp = 0.0
  	suction_sum_orifice_dp = 0.0
  	suction_sum_equipment_dp = 0.0

    sum_control_valve_dp = 0.0
    sum_orifice_dp = 0.0
    sum_equipment_dp = 0.0
    sum_fitting_dp = 0.0

  	(0..count-1).each do |p|
  		log.info("-------- fitting iteration nn --------#{p}")
      skip_count_loop = false
  		circuit_piping = suction_pipings[p]

      fitting_type = PipeSizing.get_fitting_tag1(circuit_piping.fitting)[:value]
      log.info("fitting type = ---------- #{fitting_type} ----------")

  		pipe_size = circuit_piping.pipe_size
  		pipe_schedule = circuit_piping.pipe_schedule

  		pipe_diameter = PipeSizing.determine_pipe_diameter(pipe_size,pipe_schedule)

      pipeID[p]  = pump_sizing.convert_to_base_unit(:pipe_id,circuit_piping.pipe_id)

      if suction_pipings[p+1].nil?
        pipeID[p+1] = pump_sizing.convert_to_base_unit(:pipe_id,suction_pipings[p].pipe_id)
      else
        pipeID[p+1] = pump_sizing.convert_to_base_unit(:pipe_id,suction_pipings[p+1].pipe_id)
      end


      d = pipeID[p]

      d1 = pipeID[p]

      d2 = pipeID[p+1]

      pipeID[p] = pipeID[p] / 12.0

      pipeID[p+1] = pipeID[p+1] / 12.0

      if circuit_piping.length.nil?
        length[p]  = 0.0
      else
        length[p]  = pump_sizing.convert_to_base_unit(:length,circuit_piping.length)
      end

      flow_percentage[p] = circuit_piping.per_flow

      cv = circuit_piping.ds_cv

      dorifice = pump_sizing.convert_to_base_unit(:dorifice, circuit_piping.ds_cv) if !circuit_piping.ds_cv.nil?

      doverd = circuit_piping.ds_cv

      if circuit_piping.delta_p.nil?
        delta_p  = 0.0
      else
        delta_p  = pump_sizing.convert_to_base_unit(:delta_p, circuit_piping.delta_p)
      end

      log.info("pipeID[p] = #{pipeID[p]}")
      log.info("length[p] = #{length[p]}")
      log.info("flow_percentage[p] = #{flow_percentage[p]}")
      log.info("cv = #{cv}")
      log.info("dorifice = #{dorifice}")
      log.info("P drop = #{delta_p}")

      relief_rate_1 = relief_rate * (flow_percentage[p]/100)

      log.info("relief rate 1 = #{relief_rate_1}")

      volume_rate = relief_rate_1/density
      log.info("volume_rate = #{volume_rate}")

      log.info("pipeID[p] = #{pipeID[p]}")

      nre[p] = (0.52633 * relief_rate_1) / (pipeID[p] * viscosity)
      log.info("nre[nn] = #{nre[p]}")

      a = (2.457 * Math.log(1.0 / (((7.0 / nre[p]) ** 0.9) + (0.27 * (e / pipeID[p]))))) ** 16.0 
      b = (37530.0 / nre[p]) ** 16.0
      f[p] = 2.0 * ((8.0 / nre[p]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0) 

      log.info("A = #{a}")
      log.info("B = #{b}")
      log.info("f[nn] = #{f[p]}")

      fd = 4.0 * f[p]
      nreynolds = nre[p]

      p_drop = circuit_piping.delta_p

      log.info("d = #{d}")
      log.info("d1 = #{d1}")
      log.info("d2 = #{d2}")

      kf = 0.0


      if fitting_type == 'Pipe'
        kf = 4.0 * f[p] * (length[p]/pipeID[p])
      elsif  fitting_type == 'Equipment' and !p_drop.nil?
       pressure_drop[p] = p_drop
       sum_equipment_dp = suction_sum_equipment_dp + pressure_drop[p]
       skip_count_loop = true
     elsif fitting_type == "Control Valve" and !p_drop.nil?
       pressure_drop[p] = p_drop
       sum_control_valve_dp = suction_sum_control_valve_dp + pressure_drop[p]
       skip_count_loop = true

     elsif fitting_type == "Orifice" and !p_drop.nil?
       pressure_drop[p] = p_drop
       sum_orifice_dp = suction_sum_orifice_dp + pressure_drop[p]
       skip_count_loop = true

     elsif fitting_type[0..4] == "Flow" and !p_drop.nil?
       pressure_drop[p] = p_drop
       sum_orifice_dp = suction_sum_orifice_dp + pressure_drop[p]
       skip_count_loop = true

     elsif  fitting_type == 'Equivalent length' and !p_drop.nil? 
       pressure_drop[p] = p_drop
       skip_count_loop = true
       sum_orifice_dp = suction_sum_orifice_dp + pressure_drop[p]

     elsif fitting_type == 'Line Segment' and !p_drop.nil?
       pressure_drop[p] = p_drop
       skip_count_loop = true
       sum_orifice_dp = suction_sum_orifice_dp + pressure_drop[p]

     elsif fitting_type == 'Change Properties to Stream' and !p_drop.nil?
       spc = circuit_piping.stream_property_changer
       density = pump_sizing.convert_to_base_unit(:su_density,spc.liquid_density)
       log.info("converted density = #{density}")
       viscosity = pump_sizing.convert_to_base_unit(:su_viscosity,spc.liquid_viscosity)
       log.info("converted viscosity = #{viscosity}")

     else 
       rec = PipeSizing.resistance_coefficient(fitting_type,nreynolds,d,d1,d2,cv,doverd)
       kf = rec[:kf]
       doverd = rec[:dover_d]
     end

     log.info("kf = #{kf}")

     kfii[p] = kf
     doverdii[p] = doverd

     #save density, viscosity, and mass flow rate specific to fitting
    circuit_piping.update_attributes(:density => density, :mass_flow_rate => relief_rate_1)

    next if skip_count_loop

       kfd[p] = kfii[p] / ((pipeID[p]) ** 4.0)

    #pipeID[p+1] = pipeID[p] / 12.0 if p == count.size

    log.info("pipeID[nn+1] = #{pipeID[p+1]}")

    nre[p+1] = (0.52633 * relief_rate_1) / (pipeID[p+1] * viscosity)

    log.info("nre[nn+1] = #{nre[p+1]}")

			#select Kinetic Energy Correction Factor
      alpha1 = 0.0
      alpha2 = 0.0
			if nre[p] <= 2000.0
				alpha1 = 2.0
			elsif nre[p] > 2000.0 and nre[p] < 10.0 ** 7.0
				alpha1 = 1.0
			elsif nre[p] > 10.0 ** 7.0
				alpha1 = 0.85
			end

			if nre[p+1] <= 2000.0
				alpha2 = 2.0
			elsif nre[p+1] > 2000.0 and nre[p+1] < 10.0 ** 7.0
				alpha2 = 1.0
			elsif nre[p+1] > 10.0 ** 7.0
				alpha2 = 0.85
			end

      log.info("alpha1 = #{alpha1}")
      log.info("alpha2 = #{alpha2}")

      kinetic_correction1 = alpha1 / pipeID[p] ** 4.0
      kinetic_correction2 = alpha2 / pipeID[p+1] ** 4.0

      if !['Expansion','Contraction','Sudden Expansion','Sudden Contraction'].include?(fitting_type)
        kinetic_correction1 = 0.0
        kinetic_correction2 = 0.0
      end

      log.info("kinetic_correction1 = #{kinetic_correction1}")
      log.info("kinetic_correction2 = #{kinetic_correction2}")
      log.info("volume_rate = #{volume_rate}")
      log.info("kfd[p] = #{kfd[p]}")

		  #Kinetic Energy + Frictional Loss
		  sumof_ke_and_ef = (0.810569 * volume_rate ** 2.0) * (kfd[p] + kinetic_correction2 - kinetic_correction1)

		  log.info("SumofKEandEf = #{sumof_ke_and_ef}")

		  #Potential Energy
      if circuit_piping.elev.nil?
        elevation[p] = 0.0
      else
        elevation[p] = pump_sizing.convert_to_base_unit(:elevation,circuit_piping.elev)
      end

		  pe  = 4.1698 * 10.0 **  8.0 * elevation[p]	

      log.info("elevation[nn] = #{elevation[p]}")
      log.info("PE = #{pe}")

		  pressure_drop[p] = density * ((sumof_ke_and_ef + pe) / (6.00444 * 10.0 ** 10.0)) 

      log.info("pressure_drop[nn] = #{pressure_drop[p]}")
      pd = pump_sizing.convert_to_project_unit(:delta_p,pressure_drop[p])
      log.info("converted pressure drop = #{pd}")
		  circuit_piping.update_attributes(:delta_p => pd)
		end
	#save delta p values
	pump_sizing.calculate_and_save_delta_ps
	render :json => {:success => true}
end

def pump_suction_design
  calculated_values = {}
  error = false
  msg = ""

  pump_sizing = PumpSizing.find(params[:pump_sizing_id])

  pressure = pump_sizing.su_pressure
  max_upstream_pressure = pump_sizing.su_max_upstream_pressure

  if pressure.nil?
    error = true
    msg = "Please enter a value for pressure!"
  end

  if max_upstream_pressure.nil?
    error = true
    msg = "Please enter a value for max upstream pressure!"
  end

  suction_fitting_dp = pump_sizing.su_fitting_dP
  suction_equipment_dp = pump_sizing.su_equipment_dP
  suction_control_valve_dp = pump_sizing.su_control_valve_dP
  suction_orifice_dp = pump_sizing.su_orifice_dP 
  suction_total_dp = pump_sizing.su_total_suction_dP

  if !pressure.nil? and !max_upstream_pressure.nil?
    p = pressure - suction_total_dp
    m = max_upstream_pressure - suction_total_dp
    calculated_values[:pressure_at_suction_nozzle] = p  
    calculated_values[:max_pressure_at_suction_nozzle] =  m

    #save them to database
    pump_sizing.su_pressure_at_suction_nozzle = p
    pump_sizing.su_max_pressure_at_suction_nozzle = m
    pump_sizing.cd_press_at_suction_nozzle = p
    pump_sizing.cd_np_press_at_suction_nozzle = p
    pump_sizing.rd_press_at_suction_nozzle = p
    pump_sizing.save
  end

  render :json => {:error => error, :calculated_values => calculated_values, :msg => msg }
end

def discharge_side_hydraulics
    calculated_values = {}
    pump_sizing = PumpSizing.find(params[:pump_sizing_id])
    project = pump_sizing.project
    log = CustomLogger.new('discharge_calculate')

    pipeID         = (1..100).to_a
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

    uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
    barometric_pressure = uom[:factor] * project.barometric_pressure
    log.info("converted barometric_pressure = #{barometric_pressure}")

    pipe_roughness = pump_sizing.convert_to_base_unit(:su_pipe_roughness)
    log.info("converted pipe roughness = #{pipe_roughness}")

    e = pipe_roughness
    e = e/12.0

    log.info("converted pipe roughness from inches to feet = #{e}")

    relief_rate     = pump_sizing.convert_to_base_unit(:su_mass_flow_rate)
    log.info("converted relief_rate = #{relief_rate}")

    relief_pressure = pump_sizing.convert_to_base_unit(:su_pressure)
    log.info("converted relief_pressure = #{relief_pressure}")

    density         = pump_sizing.convert_to_base_unit(:su_density)
    log.info("converted density = #{density}")

    viscosity       = pump_sizing.convert_to_base_unit(:su_viscosity)
    log.info("converted viscosity = #{viscosity}")

    suction_pipings = pump_sizing.suction_pipings
    count           = suction_pipings.size  

pump_sizing.pump_sizing_discharges.each do |discharge|

		suction_pipings = discharge.discharge_circuit_piping
		count = suction_pipings.size

		(0..count-1).each do |p|
      log.info("-------- fitting iteration nn --------#{p}")
      skip_count_loop = false
      circuit_piping = suction_pipings[p]

      fitting_type = PipeSizing.get_fitting_tag1(circuit_piping.fitting)[:value]
      log.info("fitting type = ---------- #{fitting_type} ----------")

      pipe_size = circuit_piping.pipe_size
      pipe_schedule = circuit_piping.pipe_schedule

      pipe_diameter = PipeSizing.determine_pipe_diameter(pipe_size,pipe_schedule)
      pipeID[p]  = pump_sizing.convert_to_base_unit(:pipe_id,circuit_piping.pipe_id)

      if suction_pipings[p+1].nil?
        pipeID[p+1] = pump_sizing.convert_to_base_unit(:pipe_id,suction_pipings[p].pipe_id)
      else
        pipeID[p+1] = pump_sizing.convert_to_base_unit(:pipe_id,suction_pipings[p+1].pipe_id)
      end


      d = pipeID[p]
      d1 = pipeID[p]
      d2 = pipeID[p+1]

      pipeID[p] = pipeID[p] / 12.0
      pipeID[p+1] = pipeID[p+1] / 12.0

      if circuit_piping.length.nil?
        length[p]  = 0.0
      else
        length[p]  = pump_sizing.convert_to_base_unit(:length,circuit_piping.length)
      end

      flow_percentage[p] = circuit_piping.per_flow

      cv = circuit_piping.ds_cv
      dorifice = pump_sizing.convert_to_base_unit(:dorifice, circuit_piping.ds_cv) if !circuit_piping.ds_cv.nil?
      doverd = circuit_piping.ds_cv

      if circuit_piping.delta_p.nil?
        delta_p  = 0.0
      else
        delta_p  = pump_sizing.convert_to_base_unit(:delta_p,circuit_piping.delta_p)
      end

      log.info("dorifice = #{dorifice}")
      log.info("pipeID[p] = #{pipeID[p]}")
      log.info("length[p] = #{length[p]}")
      log.info("flow_percentage[p] = #{flow_percentage[p]}")
      log.info("cv = #{cv}")
      log.info("dorifice = #{dorifice}")

      relief_rate_1 = relief_rate * (flow_percentage[p]/100)
      log.info("relief rate 1 = #{relief_rate_1}")
      volume_rate = relief_rate_1/density

      log.info("volume_rate = #{volume_rate}")
      log.info("pipeID[p] = #{pipeID[p]}")

      nre[p] = (0.52633 * relief_rate_1) / (pipeID[p] * viscosity)
      log.info("nre[nn] = #{nre[p]}")

      a = (2.457 * Math.log(1.0 / (((7.0 / nre[p]) ** 0.9) + (0.27 * (e / pipeID[p]))))) ** 16.0 
      b = (37530.0 / nre[p]) ** 16.0
      f[p] = 2.0 * ((8.0 / nre[p]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0) 

      log.info("A = #{a}")
      log.info("B = #{b}")
      log.info("f[nn] = #{f[p]}")

      fd = 4.0 * f[p]
      nreynolds = nre[p]

      p_drop = circuit_piping.delta_p

      log.info("PDrop = #{p_drop}")
      log.info("nreynolds = #{nreynolds}")
      log.info("d = #{d}")
      log.info("d1 = #{d1}")
      log.info("d2 = #{d2}")

      kf = 0.0

      if fitting_type == 'Pipe'
        kf = 4.0 * f[p] * (length[p]/pipeID[p])
      elsif  fitting_type == 'Equipment' and !p_drop.nil?
       pressure_drop[p] = p_drop
       skip_count_loop = true

      elsif fitting_type == "Control Valve" and !p_drop.nil?
        #use the default value from project
       pressure_drop[p] = project.minimum_control_value_pressure_drop
       skip_count_loop = true

     elsif fitting_type == "Orifice" and !p_drop.nil?
       #use the default value from project
       pressure_drop[p] = project.minimum_control_value_pressure_drop
       skip_count_loop = true

     elsif fitting_type.include?("Flow") and !p_drop.nil?
       pressure_drop[p] = project.default_flow_element_pressure_drop
       skip_count_loop = true

     elsif  fitting_type == 'Equivalent length' and !p_drop.nil? 
       pressure_drop[p] = p_drop
       skip_count_loop = true

     elsif fitting_type == 'Line Segment' and !p_drop.nil?
       pressure_drop[p] = p_drop
       skip_count_loop = true

     elsif fitting_type == 'Change Properties to Stream' and !p_drop.nil?
       spc = circuit_piping.stream_property_changer

       density = pump_sizing.convert_to_base_unit(:su_density,spc.liquid_density)
       log.info("converted density = #{density}")

       viscosity = pump_sizing.convert_to_base_unit(:su_viscosity,spc.liquid_viscosity)
       log.info("converted viscosity = #{viscosity}")
     else 
       rec = PipeSizing.resistance_coefficient(fitting_type,nreynolds,d,d1,d2,cv,doverd,dorifice,project)
       kf = rec[:kf]
       doverd = rec[:dover_d]
     end

     log.info("kf = #{kf}")
     log.info("doverd = #{doverd}")

     kfii[p] = kf
     doverdii[p] = doverd

    #save density as well as viscosity
    circuit_piping.update_attributes(:density => density, :viscosity => viscosity, :mass_flow_rate => relief_rate_1)

    if skip_count_loop
      log.info("pressure_drop[nn] = #{pressure_drop[p]}") 
      circuit_piping.update_attributes(:delta_p => pressure_drop[p])
    end

    next if skip_count_loop

    kfd[p] = kfii[p] / ((pipeID[p]) ** 4.0)

    #pipeID[p+1] = pipeID[p] / 12.0 if p == count.size

    log.info("pipeID[nn+1] = #{pipeID[p+1]}")

    nre[p+1] = (0.52633 * relief_rate_1) / (pipeID[p+1] * viscosity)

    log.info("nre[nn+1] = #{nre[p+1]}")

      #select Kinetic Energy Correction Factor
      alpha1 = 0.0
      alpha2 = 0.0
      if nre[p] <= 2000.0
        alpha1 = 2.0
      elsif nre[p] > 2000.0 and nre[p] < 10.0 ** 7.0
        alpha1 = 1.0
      elsif nre[p] > 10.0 ** 7.0
        alpha1 = 0.85
      end

      if nre[p+1] <= 2000.0
        alpha2 = 2.0
      elsif nre[p+1] > 2000.0 and nre[p+1] < 10.0 ** 7.0
        alpha2 = 1.0
      elsif nre[p+1] > 10.0 ** 7.0
        alpha2 = 0.85
      end

      log.info("alpha1 = #{alpha1}")
      log.info("alpha2 = #{alpha2}")

      kinetic_correction1 = alpha1 / pipeID[p] ** 4.0
      kinetic_correction2 = alpha2 / pipeID[p+1] ** 4.0

      if !['Expansion','Contraction','Sudden Expansion','Sudden Contraction'].include?(fitting_type)
        kinetic_correction1 = 0.0
        kinetic_correction2 = 0.0
      end

      log.info("kinetic_correction1 = #{kinetic_correction1}")
      log.info("kinetic_correction2 = #{kinetic_correction2}")
      log.info("volume_rate = #{volume_rate}")
      log.info("kfd[p] = #{kfd[p]}")

      #Kinetic Energy + Frictional Loss
      sumof_ke_and_ef = (0.810569 * volume_rate ** 2.0) * (kfd[p] + kinetic_correction2 - kinetic_correction1)

      log.info("SumofKEandEf = #{sumof_ke_and_ef}")

      #Potential Energy
      if circuit_piping.elev.nil?
        elevation[p] = 0.0
      else
        elevation[p] = pump_sizing.convert_to_base_unit(:elevation,circuit_piping.elev)
      end

      pe  = 4.1698 * 10.0 **  8.0 * elevation[p]  

      log.info("elevation[nn] = #{elevation[p]}")
      log.info("PE = #{pe}")

      pressure_drop[p] = density * ((sumof_ke_and_ef + pe) / (6.00444 * 10.0 ** 10.0)) 

      log.info("pressure_drop[nn] = #{pressure_drop[p]}")

      pd = pump_sizing.convert_to_project_unit(:delta_p, pressure_drop[p])

      log.info("converted pressure drop = #{pd}")

      circuit_piping.delta_p = pd

      #need to calculate ds_cv for for fitting types Expansion, Contraction, Sudden Expansion and Sudden Contraction
      if ['Expansion','Contraction','Sudden Expansion','Sudden Contraction'].include?(fitting_type)
        circuit_piping.ds_cv  = doverdii[p]
      end

      circuit_piping.save
    end
		  #save delta ps for each discharge
		  discharge.calculate_and_save_delta_ps
	  end #end discharge
    pump_sizing.determine_design_circuit
    render :json => {:success => true}
  end

  def design_pump_centrifugal
    pump = PumpSizing.find(params[:pump_sizing_id])
    m = pump.design_pump_centrifugal
    render :json => m
  end

  def design_pump_reciprocation
    pump = PumpSizing.find(params[:pump_sizing_id])
    pump.design_pump_reciprocation
    render :json => {:success => true}
  end

  def equalize
    pump = PumpSizing.find(params[:pump_sizing_id])
    w = pump.equalize
    render :json => {:success => true, :warning => w}
  end

  def new_stream_property_changer
    @row_id = params[:row_id]
    @pump_sizing = PumpSizing.find(params[:pump_sizing_id])
    @project = @pump_sizing.project
    @stream_property_changer = StreamPropertyChanger.new

    if !@pump_sizing.process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@pump_sizing.process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    else
      @streams = []
    end

    @tab = params[:tab]
    @sizing_type = 'pump_sizing'

    if @tab == 'suction'
      @piping_type = 'suction_pipings' 
    end

    if @tab == 'discharge'
      @piping_type = 'discharge_circuit_pipings' 
      @discharge_type = 'pump_sizing_discharges'
      @discharge_row = params[:discharge_row]
    end
    
    render :partial => 'new_stream_property_changer'
  end

  def system_loss_calculate
    pump = PumpSizing.find(params[:pump_sizing_id])
    pump.pump_curve
    render :json => {:success => true}
  end


	private

	def default_form_values
		@pump_sizing = @company.pump_sizings.find(params[:id]) rescue @company.pump_sizings.new
		@comments = @pump_sizing.comments
		@new_comment = @pump_sizing.comments.new
		@fittings = PipeSizing.fitting1

		@attachments = @pump_sizing.attachments
		@new_attachment = @pump_sizing.attachments.new

		@project = @user_project_settings.project    

    @fitting_pipe_size_unit = @project.unit('Length','Pipe Tube Diameter')

		@streams = []    

		p = @project.convert_pipe_roughness_values
		@pipes = p[:pipes]
		@project_pipes = p[:project_pipes]

    @line_sizings = @company.line_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))


	end

  def suction_piping_calculation
  end

end
