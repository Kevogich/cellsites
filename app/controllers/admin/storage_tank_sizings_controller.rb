class Admin::StorageTankSizingsController < AdminController

	#TODO Remove redundant code
	before_filter :default_form_values, :only => [:new, :create, :edit, :update]

	def index
		@storage_tank_sizings = @company.storage_tank_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))

		if @user_project_settings.client_id.nil?     
			flash[:error] = "Please Update Project Setting"      
			redirect_to admin_sizings_path
		end
	end

	def new
		@storage_tank_sizing = @company.storage_tank_sizings.new
	end

	def create
		storage_tank_sizing = params[:storage_tank_sizing]
		storage_tank_sizing[:created_by] = storage_tank_sizing[:updated_by] = current_user.id    
		@storage_tank_sizing = @company.storage_tank_sizings.new(storage_tank_sizing)    

		if !@storage_tank_sizing.s_process_basis_id.nil?
			heat_and_meterial_balance = HeatAndMaterialBalance.find(@storage_tank_sizing.s_process_basis_id)
			@streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
		end
		if @storage_tank_sizing.save
      @storage_tank_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
			if request.xhr?
				render :json => {:error => false, :storage_tank_id => @storage_tank_sizing.id}
			else
				flash[:notice] = "New storage tank sizing created successfully."
				redirect_to admin_storage_tank_sizings_path
			end
		else
			render :new
		end
	end

	def edit
		@storage_tank_sizing = @company.storage_tank_sizings.find(params[:id])    

		if !@storage_tank_sizing.s_process_basis_id.nil?
			heat_and_meterial_balance = HeatAndMaterialBalance.find(@storage_tank_sizing.s_process_basis_id)
			@streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
		end
	end

	def update
		storage_tank_sizing = params[:storage_tank_sizing]
		storage_tank_sizing[:updated_by] = current_user.id

		@storage_tank_sizing = @company.storage_tank_sizings.find(params[:id])

		if !@storage_tank_sizing.s_process_basis_id.nil?
			heat_and_material_balance = HeatAndMaterialBalance.find(@storage_tank_sizing.s_process_basis_id)
			@streams = heat_and_material_balance.heat_and_material_properties.first.streams
		end

		if @storage_tank_sizing.update_attributes(storage_tank_sizing)
			if request.xhr?
				render :json => {:error => false, :storage_tank_id => @storage_tank_sizing.id}
			else
				flash[:notice] = "Updated storage tank sizing successfully."
				redirect_to admin_storage_tank_sizings_path       
			end
		else      
			render :edit
		end
	end

	def destroy
		@storage_tank_sizing = @company.storage_tank_sizings.find(params[:id])
		if @storage_tank_sizing.destroy
			flash[:notice] = "Deleted #{@storage_tank_sizing.storage_tank_tag} successfully."
			redirect_to admin_storage_tank_sizings_path
		end
	end

	def clone
		@storage_tank_sizing = @company.storage_tank_sizings.find(params[:id])
		new = @storage_tank_sizing.clone :except => [:created_at, :updated_at]
		new.storage_tank_tag = params[:tag]
		if new.save
			render :json => {:error => false, :url => edit_admin_storage_tank_sizing_path(new) }
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

		flow_rate = property.where(:phase => "Overall", :property => "Mass Flow").first
		flow_rate_stream = flow_rate.streams.where(:stream_no => params[:stream_no]).first
		form_values[:flow_rate] = flow_rate_stream.stream_value.to_f rescue nil    

		density = property.where(:phase => "Overall", :property => "Mass Density").first
		density_stream = density.streams.where(:stream_no => params[:stream_no]).first
		form_values[:density] = density_stream.stream_value.to_f rescue nil

		vapour_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
		vapour_fraction_stream = vapour_fraction.streams.where(:stream_no => params[:stream_no]).first
		form_values[:vapour_fraction] = vapour_fraction_stream.stream_value.to_f rescue nil

		form_values[:volume_flow_rate] = (form_values[:flow_rate] * 7.4805) / (form_values[:density] * 60)

		form_values[:phase] = "Vapor"    if form_values[:vapour_fraction] == 1
		form_values[:phase] = "Liquid"   if form_values[:vapour_fraction] == 0
		form_values[:phase] = "Bi-Phase" if form_values[:vapour_fraction] > 0 and form_values[:vapour_fraction] < 1

		render :json => form_values
	end

	def store_tank_sizing_summary
		@storage_tank_sizings = @company.storage_tank_sizings.all    
	end

	def set_breadcrumbs
		super
		@breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
		@breadcrumbs << { :name => 'Storage Tank Sizing', :url => admin_storage_tank_sizings_path }
	end

	def design_conditions_calculate
		storage_tank = StorageTankSizing.find(params[:storage_tank_id])
		project = storage_tank.project

		barometric_pressure = project.barometric_pressure

		vaccume_set_point = storage_tank.dc_vacuum_vent_set_point
		temp_max = storage_tank.dc_maximum_liquid_surface_temperature
		temp_min = storage_tank.dc_minimum_liquid_surface_temperature
		bmax = storage_tank.dc_tvp_at_maximum_liquid_surface_temperature
		bmin = storage_tank.dc_tvp_at_minimum_liquid_surface_temperature

		#Determine Design Pressure
		if bmin >= vaccume_set_point
			working_pressure = bmax - barometric_pressure
		else
			working_pressure = bmax + ((vaccume_set_point - bmin) * (( temp_max + 459.67) / (temp_min + 459.67))) - barometric_pressure
		end
		design_pressure = working_pressure + (0.1 * working_pressure)
		design_vaccum = (bmin - barometric_pressure) - (0.1 * (bmin - barometric_pressure))

		if design_pressure <= 0.216549755
			tank_type  = "Atmospheric Tank Required"
		elsif design_pressure > 0.216549755 and design_pressure <= 15
			tank_type  =  "Low Pressure Tank Required"
		else
			tank_type  = "High Pressure Storage Required"
		end

		fixed_roof, floating_roof = "", "" if tank_type == "High Pressure Storage Required"

		unit_decimals = project.project_units1

		storage_tank.update_attributes(
			:dc_storage_pressure => working_pressure.round(unit_decimals["pressure_general"][:decimal_places]),
			:dc_design_pressure => design_pressure.round(unit_decimals["pressure_general"][:decimal_places]),
			:dc_design_temperature => temp_max.round(unit_decimals["temperature_general"][:decimal_places]),
			:dc_design_vacuum_pressure => design_vaccum.round(unit_decimals["pressure_absolute"][:decimal_places]),
			:dc_vacuum_temperature => temp_min.round(unit_decimals["temperature_general"][:decimal_places]),
			:dc_tank_type_recommendation => tank_type,
			:dc_fixed_roof_recommendation => fixed_roof,
			:dc_floating_roof_recommendation => floating_roof
		)
	rescue Exception => e
		render :json => {:success => false, :error => "#{e.to_s}\n#{e.backtrace.join("\n")}" }
	else
		render :json => {:success => true}

	end

	def pvapor_calculate
		storage_tank = StorageTankSizing.find(params[:storage_tank_id])
		project = storage_tank.project
		chemical = storage_tank.dc_representative_chemical

		log = CustomLogger.new("pvapor_calculate")

		barometric_pressure = project.barometric_pressure.to_f
		temp_max = storage_tank.dc_maximum_liquid_surface_temperature
		temp_min = storage_tank.dc_minimum_liquid_surface_temperature
		temp_storage = storage_tank.dc_liquid_storage_temperature

		log.info("temp_max = #{temp_max}")
		log.info("temp_min = #{temp_min}")
		log.info("temp_storage = #{temp_storage}")
		log.info("chemical name = #{chemical}")
		log.info("barometric_pressure = #{barometric_pressure}")

		temp_max_c = (temp_max - 32.0) * 0.5555555555
		temp_min_c = (temp_min - 32.0) * 0.5555555555
		temp_storage_c = (temp_storage - 32.0) * 0.5555555555

		log.info("temp_max_c = #{temp_max_c}")
		log.info("temp_min_c = #{temp_min_c}")
		log.info("temp_storage_c = #{temp_storage_c}")

		chm = Chemical.where(:name => chemical).first
		aa = chm.a
		bb = chm.b
		cc = chm.c
		tmax = chm.tmax
		tmin = chm.tmin

		log.info("aa = #{aa}")
		log.info("bb = #{bb}")
		log.info("cc = #{cc}")
		log.info("tmax = #{tmax}")
		log.info("tmix = #{tmin}")

		msg = "The specified temperature is outside the range for this calculation for this chemical.  Do you want to continue with the calculation."
		error = false
		log.info(error)

		if temp_max_c < tmin or temp_max_c > tmax 
			error = true
			vapor_pmax = 10 ** ( aa - ( bb / (temp_max_c + cc)))
			vapor_pmax = ((vapor_pmax * 14.696) / 760) + barometric_pressure
		else
			vapor_pmax = 10 ** ( aa - ( bb / (temp_max_c + cc)))
			vapor_pmax = ((vapor_pmax * 14.696) / 760) + barometric_pressure
		end

		if temp_min_c < tmin or temp_min_c > tmax 
			error = true
			vapor_pmin = 10 ** ( aa - ( bb / (temp_min_c + cc)))
			vapor_pmin = ((vapor_pmin * 14.696) / 760) + barometric_pressure
		else
			vapor_pmin = 10 ** ( aa - ( bb / (temp_min_c + cc)))
			vapor_pmin = ((vapor_pmin * 14.696) / 760) + barometric_pressure
		end

		if temp_storage_c < tmin or temp_storage_c > tmax 
			error = true
			vapor_pstorage = 10 ** ( aa - ( bb / (temp_storage_c + cc)))
			vapor_pstorage = ((vapor_pstorage * 14.696) / 760) + barometric_pressure
		else
			vapor_pstorage = 10 ** ( aa - ( bb / (temp_storage_c + cc)))
			vapor_pstorage = ((vapor_pstorage * 14.696) / 760) + barometric_pressure
		end

		if vapor_pstorage < 1.5
			fixed_roof = "Fixed Roof Permitted."
		else
			fixed_roof = "No Fixed Roof Permitted without VRS."
		end

		if vapor_pstorage < 11.1
			floating_roof = "Floating Roof Permitted."
		else
			floating_roof = "No Floating Roof Permitted without VRS."
		end

		log.info("vapor_pmax = #{vapor_pmax}")
		log.info("vapor_pmin = #{vapor_pmin}")
		log.info("vapor_pstorage = #{vapor_pstorage}")

		units  = project.project_units1

		storage_tank.update_attributes(
			:dc_tvp_at_maximum_liquid_surface_temperature => vapor_pmax.round(units["pressure_absolute"][:decimal_places]),
			:dc_tvp_at_minimum_liquid_surface_temperature => vapor_pmin.round(units["pressure_absolute"][:decimal_places]),
			:dc_tvp_at_storage_temperature => vapor_pstorage.round(units["pressure_absolute"][:decimal_places]),
			:dc_fixed_roof_recommendation => fixed_roof,
			:dc_floating_roof_recommendation => floating_roof
		)
		log.close
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}" }
	else
		if params[:temp_check] == 'true' && error
			render :json => {:success => false, :error => 'confirm', :msg => msg, :storage_tank_id => params[:storage_tank_id]}
		else
			render :json => {:success => true}
		end
	end

	def atm_low_pressure_storage_calculate
		storage_tank = StorageTankSizing.find(params[:storage_tank_id])
		project = storage_tank.project
		pi = 3.14159265358979
		log = CustomLogger.new("atm_pressure_storage")


		filling_rate = storage_tank.s_fs_volume_flow_rate
		emptying_rate = storage_tank.s_es_volume_flow_rate
		capacity_basis = storage_tank.atm_capacity_basis

		if capacity_basis == "max_filling_rate"
			capacity_basis = filling_rate
		elsif capacity_basis == "max_emptying_rate"
			capacity_basis = emptying_rate
		end

		required_inventory  = storage_tank.atm_bottom_to_normal_fill_level * 60 #convert to hours
		normal_inventory = capacity_basis * required_inventory
		normal_inventory_ft3 = normal_inventory / 7.4805

		freeboard = storage_tank.atm_vapor_space_capacity_above_maximum_level / 100

		log.info("required_inventory = #{required_inventory}")
		log.info("capacity_basis = #{capacity_basis}")
		log.info("normal_inventory = #{normal_inventory}")

		sfl_time = storage_tank.atm_nfl_to_safe_fill_level
		sfl_inventory = filling_rate * sfl_time
		sfl_inventory_ft3 = sfl_inventory / 7.4805

		ofl_time = storage_tank.atm_sfl_to_over_fill_level
		ofl_inventory = filling_rate * ofl_time
		ofl_inventory_ft3 = ofl_inventory / 7.4805

		diameter = storage_tank.atm_nominal_diameter

		tank_area = pi * (diameter / 2.0) ** 2.0

		nfl = normal_inventory_ft3 / tank_area
		sfl = sfl_inventory_ft3 / tank_area
		ofl = ofl_inventory_ft3 / tank_area
		void_space_capacity = (ofl_inventory_ft3 + sfl_inventory_ft3 + normal_inventory_ft3) * 0.02

		liquid_capacityft3 = ofl_inventory_ft3 + sfl_inventory_ft3 + normal_inventory_ft3
		total_tank_capacity_ft3 = liquid_capacityft3 / (1 - freeboard)
		void_space_capacity_ft3 = total_tank_capacity_ft3 -  liquid_capacityft3
		void_space_capacity = void_space_capacity_ft3

		height_above_ofl = void_space_capacity / tank_area

		log.info("height_above_ofl = #{height_above_ofl}")


		sfl_total = nfl + sfl
		ofl_total = nfl + sfl + ofl
		total_height = nfl + sfl + ofl + height_above_ofl

		nfl_percent = (nfl / total_height) * 100
		sfl_percent = (sfl_total / total_height) * 100
		ofl_percent = (ofl_total / total_height) * 100
		available_vapor_space_percent = (height_above_ofl / total_height) * 100

		normal_capacity = normal_inventory
		rated_capacity = normal_inventory + sfl_inventory
		maximum_capacity = normal_inventory + sfl_inventory + ofl_inventory
		height = total_height

		unit_decimals = project.project_units1

		storage_tank.update_attributes(
			:atm_normal_capacity => normal_capacity.round(unit_decimals["volume_general"][:decimal_places]),
      :atm_rated_capacity => rated_capacity.round(unit_decimals["volume_general"][:decimal_places]),
			:atm_maximum_capacity => maximum_capacity.round(unit_decimals["volume_general"][:decimal_places]),
			:atm_normal_fill_level => nfl.round(unit_decimals["length_large_dimension_length"][:decimal_places]),
			:atm_safe_fill_level=> sfl_total.round(unit_decimals["length_large_dimension_length"][:decimal_places]),
			:atm_over_fill_level=> ofl_total.round(unit_decimals["length_large_dimension_length"][:decimal_places]),
			:atm_normal_fill_level_percent => nfl_percent.round(2),
			:atm_safe_fill_level_percent => sfl_percent.round(2),
			:atm_over_fill_level_percent=> ofl_percent.round(2),
			:atm_available_vapor_space => available_vapor_space_percent.round(unit_decimals["length_large_dimension_length"][:decimal_places]),
			:atm_calculated_height => height.round(unit_decimals["length_large_dimension_length"][:decimal_places]),
			:atm_nominal_height => height.round(unit_decimals["length_large_dimension_length"][:decimal_places])
		)
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}" }
	else
		render :json => {:success => true}
	end

	def pressure_storage_calculate

		storage_tank = StorageTankSizing.find(params[:storage_tank_id])
		project = storage_tank.project
		pi = 3.14159265358979
		log = CustomLogger.new("pressure_storage_calculate")

		filling_rate = storage_tank.s_fs_volume_flow_rate
		emptying_rate = storage_tank.s_es_volume_flow_rate
		capacity_basis = storage_tank.ps_capacity_basis

		if capacity_basis == "max_filling_rate"
			capacity_basis = filling_rate
		elsif capacity_basis == "max_emptying_rate"
			capacity_basis = emptying_rate
		end

		required_inventory  = storage_tank.ps_bottom_to_normal_fill_level * 60 #convert to hours
		normal_inventory = capacity_basis * required_inventory
		normal_inventory_ft3 = normal_inventory / 7.4805

		ofl_time = storage_tank.ps_nfl_to_maximum_level
		ofl_inventory = filling_rate * ofl_time
		ofl_inventory_ft3 = ofl_inventory / 7.4805

		length = storage_tank.ps_nominal_length
		depth = storage_tank.ps_nominal_depth
		freeboard = storage_tank.ps_vpc_above_maximum_level / 100

		maximum_inventory = ofl_inventory + normal_inventory
		max_level_volume_ft3 = ofl_inventory_ft3 + normal_inventory_ft3

		#requires initialization for these variables due to scoping issues
		partial_cylinder_volume = 0.0
		max_liquid_level = 0.0
		void_space = 0.0
		normal_liquid_level = 0.0
		diameter = 0.0
		vapor_space_capacityft3 = 0.0

		if storage_tank.ps_storage_tank_type == 'horizontal_cylinder'
			est_total_capacity = max_level_volume_ft3 * (1 + freeboard)
			vapor_space_capacityft3 = freeboard * est_total_capacity
			(1..1000).each do |ij|
				diameter = ij.to_f * 0.1
				(1..1000).each do |i|
					max_liquid_level = (i.to_f * (diameter / 1000)) - 0.00001
					alpha = Math.acos(1.0 - (2.0 * (max_liquid_level / diameter))) * (180.0 / pi)
					part1 = Math.sin(alpha * (pi / 180.0))
					part2 = Math.cos(alpha * (pi / 180.0))
					partial_cylinder_volume = length * (diameter / 2.0) ** 2.0 * ((alpha / 57.3) - (part1 * part2))
					break if partial_cylinder_volume >= max_level_volume_ft3
				end
				break if partial_cylinder_volume >= max_level_volume_ft3
			end

			(1..1000).each do |i|
				normal_liquid_level = i.to_f * (diameter / 1000)
				alpha = Math.acos(1.0 - (2.0 * (normal_liquid_level / diameter))) * (180.0 / pi)
				part1 = Math.sin(alpha * (pi / 180.0))
				part2 = Math.cos(alpha * (pi / 180.0))
				partial_cylinder_volume = length * (diameter / 2.0) ** 2.0 * ((alpha / 57.3) - (part1 * part2))
				break if partial_cylinder_volume >= normal_inventory_ft3
				#log.info("log i = #{i}")
				#log.info("diameter = #{diameter}")
				#log.info("normal liquid level = #{partial_cylinder_volume}")
				#log.info("normal inventory ft3 = #{normal_inventory_ft3}")
			end


			(1..1000).each do |i|
			     void_space = i * (diameter / 1000)
			     alpha = Math.acos(1.0 - (2.0 * (void_space / diameter))) * (180.0 / pi)
			     part1 = Math.sin(alpha * (pi / 180.0))
			     part2 = Math.cos(alpha * (pi / 180.0))
			     partial_cylinder_volume = length * (diameter / 2.0) ** 2.0 * ((alpha / 57.3) - (part1 * part2))
			     break if partial_cylinder_volume >= vapor_space_capacityft3
			 end

			condition = 1
			(1..100).each do |dxx|
				diff_d = diameter - (1 * dxx.to_f)
				if diff_d < 1
					condition = 0
					diff_d = diff_d.to_f * 12.0
					if diff_d < 6.0
						diff_d = 6.0
					else
						diff_d = 12.0
						
					end
				diff_d = diff_d / 12.0
				diameter = dxx + diff_d
				end
				break if condition == 0
			end


				available_vapor_space = diameter - max_liquid_level

				if available_vapor_space < void_space
					diameter = diameter + 0.5
				end

				if length < diameter
					#msg1 = MsgBox("The calculated nominal diameter exceeds the nominal tank entered for horizontal tank.
					#Consider entering a larger nominal length for the horizontal storage tank.", vbOKOnly, "Longer Horizontal Tank Needed!")
				end
			elsif storage_tank.ps_storage_tank_type == 'sphere'
				(1..1000).each do |i|
					normal_liquid_level = i.to_f * (length / 1000)
					partial_fill_ratio = normal_liquid_level / length
					fraction_of_volume = -(partial_fill_ratio) ** 2.0 * (-3 + (2.0 * partial_fill_ratio))
					partial_cylinder_volume = (1.0 / 6.0) * pi * length ** 3.0 * fraction_of_volume
					#From GPSA Manual Sectio58.0 ftn 6.  Note that K1 =1 and K2 = 1. 
					#Also matches LMNO Engineering home page with volume of V= (pi/3)* h**2*(1.5*D-h)
					break if partial_cylinder_volume >= normal_inventory_ft3
				end


				if partial_cylinder_volume < normal_inventory_ft3
					#msg1 = MsgBox("The nominal length entered for the spherical storage tank is too small to accomodate the required liquid inventory.
					#Consider entering a larger nominal length for the spherical storage tank.", vbOKOnly, "Bigger Spherical Tanks Needed!")
				end

				(1..1000).each do |j|
					max_liquid_level = j.to_f * (length / 1000)
					partial_fill_ratio = max_liquid_level / length
					fraction_of_volume = -(partial_fill_ratio) ** 2.0 * (-3 + (2.0 * partial_fill_ratio ))
					partial_cylinder_volume = (1.0 / 6.0) * pi * length.to_f ** 3.0 * fraction_of_volume
					#From GPSA Manual Section 6.  Note that K1 =1 and K2 = 1. 
					#Also matches LMNO Engineering home page with volume of V= (pi/3)* h**2*(1.5*D-h)
					break if partial_cylinder_volume >= max_level_volume_ft3
				end


				if partial_cylinder_volume < max_level_volume_ft3
					#msg1 = MsgBox("The nominal length entered for the spherical storage tank is too small to accomodate the required liquid inventory.
					#Consider entering a larger nominal length for the spherical storage tank.", vbOKOnly, "Bigger Spherical Tanks Needed!")
				end

				diameter = length
				vapor_space_capacity = max_level_volume_ft3 * 0.02

				(1..1000).each do |k|
					void_space = k.to_f * (length / 1000)
					partial_fill_ratio = void_space / length
					fraction_of_volume = -(partial_fill_ratio) ** 2.0 * (-3 + (2.0 * partial_fill_ratio))
					partial_cylinder_volume = (1.0 / 6.0) * pi * length ** 3.0 * fraction_of_volume
					#From GPSA Manual Section 6.  Note that K1 =1 and K2 = 1. 
					#Also matches LMNO Engineering home page with volume of V= (pi/3)* h**2*(1.5*D-h)
					break if partial_cylinder_volume >= vapor_space_capacity
				end

				available_vapor_space = diameter - max_liquid_level

				if available_vapor_space < void_space
					length = length + 0.5
				end

			elsif storage_tank.ps_storage_tank_type == 'spheroid'
				partial_cylinder_volume = 0.0
				(1..1000).each do |ij|
					diameter = (length * (ij.to_f / 1000))
					(1..1000).each do |i|
						max_liquid_level = i.to_f * (diameter / 1000)
						partial_fill_ratio = max_liquid_level / diameter
						fraction_of_volume = -(partial_fill_ratio) ** 2.0 * (-3.0 + (2.0 * partial_fill_ratio))
						partial_cylinder_volume = (1.0 / 6.0) * pi * (2.0 * (length / 2.0) / diameter) * (2.0 * (depth / 2.0) / diameter) * diameter ** 3.0 * fraction_of_volume
						#From GPSA Manual Section 6.  Note that K1 =1 and K2 = 1. 
						#Also matches LMNO Engineering home page with volume of V= (pi/3)* h**2*(1.5*D-h)
						break if partial_cylinder_volume >= max_level_volume_ft3
					end
				    break if partial_cylinder_volume >= max_level_volume_ft3
				end

				log.info("diameter = #{diameter}")

				if partial_cylinder_volume < max_level_volume_ft3
					#msg1 = MsgBox("The nominal length and/or the depth entered for the spherical storage tank 
					#is/are too small to accomodate the required liquid inventory. 
					#Consider entering a larger nominal length and or a larger depth for the spherical storage tank.", 
					#vbOKOnly, "Bigger Spherical Tanks Needed!")
				end

				(1..1000).each do |j|
					normal_liquid_level = j.to_f * (diameter / 1000)
					partial_fill_ratio = normal_liquid_level / diameter
					fraction_of_volume = -(partial_fill_ratio) ** 2.0 * (-3 + (2.0 * partial_fill_ratio))
					partial_cylinder_volume = (1.0 / 6.0) * pi * (2.0 * (length / 2.0) / diameter) * (2.0 * (depth / 2.0) / diameter) * diameter ** 3.0 * fraction_of_volume
					#From GPSA Manual Section 6.  Note that K1 =1 and K2 = 1. 
					#Also matches LMNO Engineering home page with volume of V= (pi/3)* h**2*(1.5*D-h)
					break if partial_cylinder_volume >= normal_inventory_ft3
				end


				if partial_cylinder_volume < normal_inventory_ft3
					#msg1 = MsgBox("The nominal length and/or the depth entered for the spherical storage 
					#tank is/are too small to accomodate the required liquid inventory. 
					#Consider entering a larger nominal length and or a larger depth for the spherical storage tank.", 
					#vbOKOnly, "Bigger Spherical Tanks Needed!")
				end

				#determine minimum void space
				vapor_space_capacity = max_level_volume_ft3 * 0.02

				(1..1000).each do |k|
					void_space = k.to_f * (diameter / 1000)
					partial_fill_ratio = void_space / diameter
					fraction_of_volume = -(partial_fill_ratio) ** 2.0 * (-3 + (2.0 * partial_fill_ratio))
					partial_cylinder_volume = (1.0 / 6.0) * pi * (2.0 * (length / 2.0) / diameter) * (2.0 * (depth / 2.0) / diameter) * diameter ** 3.0 * fraction_of_volume
					#From GPSA Manual Section 6.  Note that K1 =1 and K2 = 1. 
					#Also matches LMNO Engineering home page with volume of V= (pi/3)* h**2*(1.5*D-h)
					break if partial_cylinder_volume >= vapor_space_capacity
				end


				condition = 1
				(1..500).each do |dxx|
					diff_d = diameter - (1 * dxx.to_f)
					if diff_d < 1.0
						condition = 0
						diff_d = diff_d * 12.0
						if diff_d < 6.0
							diff_d = 6.0
						else
							diff_d = 12.0
						end
					diff_d = diff_d / 12.0
					diameter = dxx + diff_d
					end
					break if condition == 0
				end

				available_vapor_space = diameter - max_liquid_level

				if available_vapor_space < void_space
					diameter = diameter + 0.5
			    end
			end

		nll_percent = (normal_liquid_level / diameter) * 100
		mll_percent = (max_liquid_level / diameter) * 100

		normal_capacity = normal_inventory
		maximum_capacity = maximum_inventory
		normal_fill_level = normal_liquid_level
		over_fill_level = max_liquid_level
		available_vapor_space = available_vapor_space
		normal_fill_level_percent = nll_percent
		over_fill_level_percent = mll_percent
		nominal_diameter = diameter

		units = project.project_units1

		storage_tank.update_attributes(
			:ps_normal_capacity => normal_capacity.round(units["volume_general"][:decimal_places]),
			:ps_maximum_capacity => maximum_capacity.round(units["volume_general"][:decimal_places]),
			:ps_normal_fill_level => normal_fill_level.round(units["length_large_dimension_length"][:decimal_places]),
			:ps_normal_fill_level_percent => nll_percent,
			:ps_over_fill_level => over_fill_level.round(units["length_large_dimension_length"][:decimal_places]),
			:ps_over_fill_level_percent => mll_percent,
			:ps_available_vapor_space => available_vapor_space.round(units["length_large_dimension_length"][:decimal_places]),
			:ps_nominal_diameter => nominal_diameter.round(units["length_large_dimension_length"][:decimal_places])
		)
	#rescue Exception => e
	#	render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	#else
		render :json => {:success => true }
	end

	def atm_standardize_calculate
		storage_tank = StorageTankSizing.find(params[:storage_tank_id])
		project = storage_tank.project
		pi = 3.14159265358979
		log = CustomLogger.new("atm_standardize_calculate")

		filling_rate = storage_tank.s_fs_volume_flow_rate
		emptying_rate = storage_tank.s_es_volume_flow_rate
		capacity_basis = storage_tank.atm_capacity_basis

		log.info("Filling rate = #{filling_rate}")
		log.info("Emptying rate = #{emptying_rate}")


		if capacity_basis == "max_filling_rate"
			capacity_basis = filling_rate
		elsif capacity_basis == "max_emptying_rate"
			capacity_basis = emptying_rate
		end

		log.info("Capacity Basis = #{capacity_basis}")

		required_inventory  = storage_tank.atm_bottom_to_normal_fill_level * 60 #convert to hours% 
		normal_inventory = capacity_basis * required_inventory
		normal_inventory_ft3 = normal_inventory / 7.4805

		sfl_time = storage_tank.atm_nfl_to_safe_fill_level
		sfl_inventory = filling_rate * sfl_time
		sfl_inventory_ft3 = sfl_inventory / 7.4805

		ofl_time = storage_tank.atm_sfl_to_over_fill_level
		ofl_inventory = filling_rate * ofl_time
		ofl_inventory_ft3 = ofl_inventory / 7.4805

		diameter = storage_tank.atm_nominal_diameter
		selected_height = storage_tank.atm_standard_selected_height

		log.info("Selected height = #{selected_height}")

		tank_area = pi * (diameter / 2.0) ** 2.0

		nfl = normal_inventory_ft3 / tank_area
		sfl = sfl_inventory_ft3 / tank_area
		ofl = ofl_inventory_ft3 / tank_area

		height_above_ofl = selected_height - (nfl+sfl+ofl)

		freeboard = (height_above_ofl / selected_height) * 100

		unit_decimals = project.project_units1

		sfl_total = nfl+sfl
		ofl_total = nfl+sfl+ofl

		storage_tank.update_attributes(
			:atm_standard_normal_fill_level => nfl.round(unit_decimals["length_small_dimension_length"][:decimal_places]),
			:atm_standard_save_fill_level => sfl_total.round(unit_decimals["length_small_dimension_length"][:decimal_places]),
			:atm_standard_overfill_level=> ofl_total.round(unit_decimals["velocity_general"][:decimal_places]),
			:atm_standard_available_vapor_space => height_above_ofl.round(unit_decimals["length_large_dimension_length"][:decimal_places]),
			:atm_standard_freeboard => freeboard,
			:atm_normal_fill_level => nfl.round(unit_decimals["length_small_dimension_length"][:decimal_places]),
			:atm_safe_fill_level => sfl_total.round(unit_decimals["velocity_general"][:decimal_places]),
			:atm_over_fill_level => ofl_total.round(unit_decimals["velocity_general"][:decimal_places]),
			:atm_available_vapor_space => height_above_ofl.round(unit_decimals["length_large_dimension_length"][:decimal_places]),
			:atm_nominal_height => selected_height
		)
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else
		render :json => {:success => true }
	end

	def mechanical_design_calculate

		storage_tank = StorageTankSizing.find(params[:storage_tank_id])
		project = storage_tank.project

		barometric_pressure = project.barometric_pressure.to_f
    design_pressure = storage_tank.md_design_pressure
    p = design_pressure + barometric_pressure
    shell_diameter = storage_tank.md_shell_diameter
    d = shell_diameter * 12.0
    r = (shell_diameter / 2) * 12
    shell_length = storage_tank.md_shell_length
    design_liquid_level = storage_tank.md_liquid_level
		sd = storage_tank.md_allowable_design_stress
    st = storage_tank.md_allowable_test_stress
		e = storage_tank.md_head_joint_efficiency
		shell_c = storage_tank.md_shell_corrosion_allowance
		head_c = storage_tank.md_head_corrosion_allowance.to_i
    bottom_c = storage_tank.md_bottom_corrosion_allowance
		sf = storage_tank.md_straight_flange
		material_density = storage_tank.md_tank_material_density
		wa = storage_tank.md_tank_weight_allowance / 100.0
		content_density = storage_tank.md_tank_content_density

		factor = project.test_pressure_factor.to_i   #from project
		hydrotest_pressure = design_pressure * factor

		head_type = storage_tank.md_head_type

		#head thickness
    head_thickness = 0.0
		if storage_tank.atm_design_codes == "api_650"
			minimum_nominal_thickness = 3.0 / 16.0 + head_c
		elsif storage_tank.atm_design_codes == "api_620"
			minimum_nominal_thickness = 1.0 / 2.0
		elsif storage_tank.ps_design_codes == "asme_viii"
			if head_type == "Ellipsoidal" 
				head_thickness = ((p * d) / ((2.0 * sd * e) - 0.2 * p)) + head_c
			elsif head_type == "Torispherical" 
				#InputBox("Input the crown radius of the torispherical head in the appropriate unit (" & LUnit & ").") + 0
				l = 1.0 #TODO
				head_thickness = ((0.885 * p * l) / ((sd * e) - 0.1 * p)) + head_c
			elsif head_type == "Hemispherical"
				head_thickness = ((p * r) / ((2.0 * sd * e) - 0.2 * p)) + head_c
			end
		end

		#shell thickness
		if storage_tank.atm_design_codes == "api_650"
			if shell_diameter < 50
				minimum_nominal_thickness = 3.0 / 16.0
			elsif shell_diameter >= 50 && shell_diameter < 120
				minimum_nominal_thickness = 1.0 / 4.0
			elsif shell_diameter >= 120 && shell_diameter < 200
				minimum_nominal_thickness = 5.0 / 6.0
			elsif shell_diameter > 200
				minimum_nominal_thickness = 3.0 / 8.0
			end

			#1-foot method thickness
      design_thickness = 0.0
      test_thickness = 0.0
			if shell_diameter < 200
				design_thickness = ((2.6 * shell_diameter * (design_liquid_level - 1.0) * (content_density / 62.4)) / sd) + shell_c
				test_thickness = (2.6 * shell_diameter * (design_liquid_level - 1.0)) / st
			else
				#msg1 = MsgBox("The shell diameter is greater than 200 ft (61 m), therefore the 1 foot method implemented with this application cannot be applied.
				#The alternative Variable-Design-Point method as outlined in API 650 may be applied manually.", vbOKOnly + vbInformation, "Thickness Calculation Method Not Applicable!")
			end

      calculated_shell_thickness = 0.0
			if design_thickness >= test_thickness
				calculated_shell_thickness = design_thickness
			elsif test_thickness > design_thickness
				calculated_shell_thickness = test_thickness
			end

			if minimum_nominal_thickness >= calculated_shell_thickness
				shell_thickness = minimum_nominal_thickness
			else
				shell_thickness = calculated_shell_thickness
			end
		elsif storage_tank.atm_design_codes == "api_620"
			minimum_thickness = (3.0/16.0) + shell_c

			#nominal thickness
			if shell_diameter <= 25
				minimum_nominal_thickness = 3.0 / 16.0
			elsif shell_diameter > 25 && shell_diameter <= 60
				minimum_nominal_thickness = 1.0 / 4.0
			elsif shell_diameter > 60 && shell_diameter <= 100
				minimum_nominal_thickness = 5.0 / 16.0
			elsif shell_diameter > 100
				minimum_nominal_thickness = 3.0 / 8.0
      end

		elsif storage_tank.ps_design_codes == "api_viii"
			shell_thickness = ((p * r) / ((sd * e) - 0.6 * p)) + shell_c 
		end

		#bottom thickness
    bottom_thickness = 0.0
		if storage_tank.atm_design_codes == "api_650"
			minimum_nominal_thickness= 0.236 + bottom_c
      bottom_thickness = minimum_nominal_thickness
		elsif storage_tank.atm_design_codes == "api_620"
			minimum_nominal_thickness= 0.25 + bottom_c
      bottom_thickness = minimum_nominal_thickness
		elsif storage_tank.ps_design_codes == "api_viii"
		end

		#Determine weight
		#head weight
		if head_type == "Hemispherical"
			head_surface_area = 1.5708 * ((d + 2.0 * head_thickness) / 12.0) ** 2.0
		elsif head_type == "Ellipsoidal"
			head_surface_area = 1.082 * ((d + 2.0 * head_thickness) / 12.0) ** 2.0
		elsif head_type == "Torispherical"
			head_surface_area = 0.9286 * ((d + 2.0 * head_thickness) / 12.0) ** 2.0
		elsif head_type == "Flat"
			head_surface_area = 0.7854 * ((d + 2.0 * head_thickness) / 12.0) ** 2.0
		elsif head_type == "Conical"
		elsif head_type == "Umbrella"
		elsif head_type == "Domed"
		end

		#cylinder weight
		cylinder_weight = PI * ((d + shell_thickness) / 12.0) * shell_length * (shell_thickness / 12.0) * material_density

		#head blank diameter
		head_od = (2.0 * head_thickness) + d

		if head_type == "Hemispherical"
			if head_od >= 10 && head_od < 18
				hfac = 1.7
			elsif head_od >= 18 && head_od <= 30
				hfac = 1.65
			elsif head_od > 30
				hfac = 1.6
			end
		elsif head_type == "Ellipsoidal"
			if head_od >= 10 && head_od <= 20
				hfac = 1.3
			elsif head_od > 20
				hfac = 1.24
			end
		elsif head_type == "Torispherical"
			if head_od >= 20 && head_od < 30
				hfac = 1.15
			elsif head_od >= 30 && head_od <= 50
				hfac = 1.11
			elsif head_od > 50
				hfac = 1.09
			end
		end
		bd = (head_od * hfac + 2.0 * sf) / 12.0
		head_weight = 0.25 * bd ** 2.0 * PI * (head_thickness / 12.0) * material_density * 2.0

    #bottom weight
    if storage_tank.atm_design_codes == "api_650"
      bottom_weight = PI * (r / 12.0) ** 2 * (bottom_thickness / 12.0) * material_density
    elsif storage_tank.atm_design_codes == "api_620"
      bottom_weight = Pi * (r / 12.0) ** 2 * (bottom_thickness / 12.0) * material_density
    else
      bottom_weight = 0
    end

		#total weight empty
		total_weight_empty = (cylinder_weight + head_weight + bottom_weight) * (1.0 + wa)

		#Determine Full liquid volume in head. Note that the diameter is meant to be the inner diameter of the vessel but is approximated as the outer diameter
    if head_type == "Hemispherical"
			head_volume = PI * ((d / 12.0) ** 3.0 / 12.0)
		elsif head_type == "ellipsoidal"
			head_volume = PI * ((d / 12.0) ** 3.0 / 24.0)
		elsif head_type == "torispherical"
			#per perry's, alternatively for code construction, per page 88 on process equipment design by lloyde brownell, edwin h young.
			#if designed to 3 x thickness, then perry's 10-140 gives an alternate equation.
			head_volume = 0.0847 * (d / 12.0) ** 3.0
		elsif head_type == "flat"
			head_volume = 0
    end

		content_weight = (shell_length * ((d / 12.0) / 2.0) ** 2.0 * PI) + (head_volume * 2.0) * content_density
		full_weight = total_weight_empty + content_weight

		units = project.project_units1

		storage_tank.update_attributes(
			:md_weight_empty_vessel => total_weight_empty.round(units["weight_general"][:decimal_places]),
			:md_weight_full_vessel => full_weight.round(units["weight_general"][:decimal_places]),
			:md_nominal_shell_thickness => shell_thickness.round(units["length_small_dimension_length"][:decimal_places]),
			:md_nominal_head_thickness => head_thickness.round(units["length_small_dimension_length"][:decimal_places]),
			:md_hydrotest_pressure => hydrotest_pressure.round(units["pressure_general"][:decimal_places]) ,
      :md_nominal_bottom_thickness => bottom_thickness.round(units["length_small_dimension_length"][:decimal_places])
		)

	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else
		render :json => {:success => true }
	end

	def ps_standardize_calculate

		storage_tank = StorageTankSizing.find(params[:storage_tank_id])
		project = storage_tank.project

    log = CustomLogger.new("ps_standardize_calculate")

		filling_rate = storage_tank.s_fs_volume_flow_rate
		emptying_rate = storage_tank.s_es_volume_flow_rate

		if storage_tank.ps_capacity_basis == "max_filling_rate"
			capacity_basis = filling_rate
		elsif storage_tank.ps_capacity_basis == "max_emptying_rate"
			capacity_basis = emptying_rate
    end

    log.info("capacity_basis = #{capacity_basis}")

		required_inventory  = storage_tank.ps_bottom_to_normal_fill_level * 60 #convert to hours
		normal_inventory = capacity_basis * required_inventory
		normal_inventory_ft3 = normal_inventory / 7.4805

    log.info("normal_inventory = #{normal_inventory}")
    log.info("normal_inventory_ft3 = #{normal_inventory_ft3}")

		ofl_time = storage_tank.ps_nfl_to_maximum_level
		ofl_inventory = filling_rate * ofl_time
		ofl_inventory_ft3 = ofl_inventory / 7.4805

    log.info("ofl_inventory = #{ofl_inventory}")
    log.info("ofl_inventory_ft3 = #{ofl_inventory_ft3}")

		length = storage_tank.ps_standard_nominal_length
		select_diameter = storage_tank.ps_standard_selected_diameter
    calculated_diameter = storage_tank.ps_calculated_diameter

		maximum_inventory = ofl_inventory + normal_inventory
		max_level_volume_ft3 = ofl_inventory_ft3 + normal_inventory_ft3

		tank_type  = storage_tank.ps_storage_tank_type
    log.info("tank_type = #{tank_type}")

		partial_cylinder_volume = 0.0
		max_liquid_level = 0.0
		normal_liquid_level = 0.0
    partial_fill_ratio = 0.0
    fraction_of_volume = 0.0
		depth = storage_tank.ps_standard_nominal_depth

		if tank_type == "horizontal_cylinder"
			(1..1000).each do |i|
				max_liquid_level = (i.to_f * (select_diameter / 1000.0)) - 0.00001
				alpha = Math.acos(1.0 - (2.0 * (max_liquid_level / select_diameter))) * (180.0 / PI)
				part1 = Math.sin(alpha * (PI / 180.0))
				part2 = Math.cos(alpha * (PI / 180.0))
				partial_cylinder_volume = length * (select_diameter / 2.0) ** 2 * ((alpha / 57.3) - (part1 * part2))
				break if partial_cylinder_volume >= max_level_volume_ft3
      end

      log.info("max_liquid_level = #{max_liquid_level}")
      log.info("partial_cylinder_volume = #{partial_cylinder_volume}")

			(1..1000).each do |i|
				normal_liquid_level = (i * (select_diameter / 1000.0)) - 0.00001
				alpha = Math.acos(1.0 - (2.0 * (normal_liquid_level / select_diameter))) * (180.0 / PI)
				part1 = Math.sin(alpha * (PI / 180.0))
				part2 = Math.cos(alpha * (PI / 180.0))
				partial_cylinder_volume = length * (select_diameter / 2.0) ** 2 * ((alpha / 57.3) - (part1 * part2))
				break if partial_cylinder_volume >= normal_inventory_ft3
      end

      log.info("normal_liquid_level = #{normal_liquid_level}")
      log.info("partial_cylinder_volume = #{partial_cylinder_volume}")

			available_vapor_space = select_diameter - max_liquid_level

      log.info("available_vapor_space = #{available_vapor_space}")

			if length < select_diameter
				#msg1 = MsgBox("The selected diameter exceeds the nominal tank length entered for horizontal tank.
				#Consider entering a larger nominal length for the horizontal storage tank.", vbOKOnly, "Longer Horizontal Tank Needed!")
			end
    elsif tank_type == "spheroid"
			(1..1000).each do |i|
				max_liquid_level = i * (select_diameter / 1000.0)
				partial_fill_ratio = max_liquid_level / select_diameter
				fraction_of_volume = -(partial_fill_ratio) ** 2 * (-3.0 + (2.0 * partial_fill_ratio))
				partial_cylinder_volume = (1.0 / 6.0) * PI * (2.0 * (length / 2.0) / select_diameter) * (2.0 * (depth / 2.0) / select_diameter) * select_diameter ** 3 * fraction_of_volume
				# from gpsa manual section 6.  note that k1 =1 and k2 = 1.  also matches lmno engineering home page with volume of v= (pi/3)* h**2*(1.5*d-h)

				break  if partial_cylinder_volume >= max_level_volume_ft3
      end

      log.info("max_liquid_level = #{max_liquid_level}")
      log.info("partial_fill_ratio = #{partial_fill_ratio}")
      log.info("fraction_of_volume = #{fraction_of_volume}")
      log.info("partial_cylinder_volume = #{partial_cylinder_volume}")

			if partial_cylinder_volume < max_level_volume_ft3
				#msg1 = MsgBox("The nominal length and/or the depth entered for the spherical storage tank is/are too small to 
				#accomodate the required liquid inventory.
				#Consider entering a larger nominal length and or a larger depth for the spherical storage tank.", vbOKOnly, "Bigger Spherical Tanks Needed!")
			end

			normal_liquid_level = 0
			(1..1000).each do |j|
				normal_liquid_level = j * (select_diameter / 1000.0)
				partial_fill_ratio = normal_liquid_level / select_diameter
				fraction_of_volume = -(partial_fill_ratio) ** 2 * (-3 + (2 * partial_fill_ratio))
				partial_cylinder_volume = (1.0 / 6.0) * PI * (2 * (length / 2.0) / select_diameter) * (2 * (depth / 2.0) / select_diameter) * select_diameter ** 3 * fraction_of_volume
				# from gpsa manual section 6.  note that k1 =1 and k2 = 1.  also matches lmno engineering home page with volume of v= (pi/3)* h**2*(1.5*d-h)

        break if partial_cylinder_volume >= max_level_volume_ft3
      end

      log.info("normal_liquid_level = #{normal_liquid_level}")
      log.info("partial_fill_ratio = #{partial_fill_ratio}")
      log.info("fraction_of_volume = #{fraction_of_volume}")
      log.info("partial_cylinder_volume = #{partial_cylinder_volume}")

			if partial_cylinder_volume < normal_inventory_ft3
				#msg1 = MsgBox("The nominal length entered for the spherical storage tank is too small to accomodate the required liquid inventory.
				#Consider entering a larger nominal length for the spherical storage tank.", vbOKOnly, "Bigger Spherical Tanks Needed!")
			end

			#Determine volume of a spheriod
			spheroid_volume_ft3 = (4.0 / 3.0) * PI * length * select_diameter * depth

			# Determine minimum void space
			vapor_space_capacity = spheroid_volume_ft3 - max_level_volume_ft3

      void_space = 0
			(1..1000).each do |k|
				void_space = k * (select_diameter / 1000.0)
				partial_fill_ratio = void_space / select_diameter
				fraction_of_volume = -(partial_fill_ratio) ** 2 * (-3.0 + (2.0 * partial_fill_ratio))
				partial_cylinder_volume = (1.0 / 6.0) * PI * (2.0 * (length / 2.0) / select_diameter) * (2.0 * (depth / 2.0) / select_diameter) * select_diameter ** 3 * fraction_of_volume
				#from gpsa manual section 6.  note that k1 =1 and k2 = 1.  also matches lmno engineering home page with volume of v= (pi/3)* h**2*(1.5*d-h)
				break if partial_cylinder_volume >= vapor_space_capacity
      end

      log.info("void_space = #{void_space}")
      log.info("partial_fill_ratio = #{partial_fill_ratio}")
      log.info("fraction_of_volume = #{fraction_of_volume}")
      log.info("partial_cylinder_volume = #{partial_cylinder_volume}")

			available_vapor_space = select_diameter - max_liquid_level
      log.info("available_vapor_space = #{available_vapor_space}")

		end

    nll_percent = ((normal_liquid_level / select_diameter) * 100).round(2)
    mll_percent = ((max_liquid_level / select_diameter) * 100).round(2)

		units = project.project_units1

		storage_tank.update_attributes(
			:ps_standard_normal_fill_level => normal_liquid_level.round(units["length_large_dimension_length"][:decimal_places]),
			:ps_standard_overfill_level => max_liquid_level.round(units["length_large_dimension_length"][:decimal_places]),
      :ps_standard_available_vapor_space => available_vapor_space.round(2),
      :ps_normal_capacity =>  normal_inventory.round(0),
      :ps_maximum_capacity => maximum_inventory.round(0),
      :ps_normal_fill_level => normal_liquid_level.round(2),
      :ps_normal_fill_level_percent => nll_percent,
      :ps_over_fill_level => max_liquid_level.round(2),
      :ps_over_fill_level_percent => mll_percent,
      :ps_available_vapor_space => available_vapor_space.round(2),
      :ps_nominal_diameter =>  select_diameter.round(units["length_large_dimension_length"][:decimal_places])
		)

    log.close

	#rescue Exception => e
	#	render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	#else
		render :json => {:success => true }
	end


	private

	def default_form_values

    @storage_tank_sizing = @company.storage_tank_sizings.find(params[:id]) rescue @company.storage_tank_sizings.new
    @comments = @storage_tank_sizing.comments
    @new_comment = @storage_tank_sizing.comments.new

    @attachments = @storage_tank_sizing.attachments
    @new_attachment = @storage_tank_sizing.attachments.new

		@project = @user_project_settings.project
		@streams = []    
	end
end
