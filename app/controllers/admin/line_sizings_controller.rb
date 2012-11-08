require "pdfkit"

class Admin::LineSizingsController < AdminController

	before_filter :default_form_values, :only => [:new, :create, :show, :edit, :update]

	def index
		@line_sizings = @company.line_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))

		if @user_project_settings.client_id.nil?     
			flash[:error] = "Please Update Project Setting"      
			redirect_to admin_sizings_path
		end
	end

	def show
		@line_sizing = @company.line_sizings.find(params[:id])
	end

	def new
		@line_sizing = @company.line_sizings.new    
		@streams = @sizing_criteria_category_types = @sizing_criterias = []
	end

	def create    
		line_sizing = params[:line_sizing]
		line_sizing[:created_by] = line_sizing[:updated_by] = current_user.id
		@line_sizing = @company.line_sizings.new(line_sizing)

		@process_units = @streams = @sizing_criteria_category_types = @sizing_criterias = []

		if !@line_sizing.process_basis_id.nil?
			heat_and_material_balance = HeatAndMaterialBalance.find(@line_sizing.process_basis_id)
			@streams = heat_and_material_balance.heat_and_material_properties.first.streams
		end

		if !@line_sizing.sizing_criteria_category_id.nil?
			@sizing_criteria_category_types = SizingCriteriaCategoryType.where("sizing_criteria_category_id = ?", @line_sizing.sizing_criteria_category_id)       
		end

		if @line_sizing.save
			@line_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
			flash[:notice] = "New line sizing created successfully."
			redirect_to admin_line_sizings_path
		else
			render :new
		end
	end

	def edit
		@line_sizing = @company.line_sizings.find(params[:id])
		@project = @line_sizing.project

		if @line_sizing.process_basis_id.nil?
			heat_and_meterial_balance = []
			@streams = []
		else
			heat_and_meterial_balance = HeatAndMaterialBalance.find(@line_sizing.process_basis_id)
			@streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
		end

		@sizing_criteria_category_types = SizingCriteriaCategoryType.where("sizing_criteria_category_id = ?", @line_sizing.sizing_criteria_category_id)
		@sizing_criterias = SizingCriteria.where("sizing_criteria_category_id = ? AND sizing_criteria_category_type_id = ?", @line_sizing.sizing_criteria_category_id, @line_sizing.sizing_criteria_category_type_id)    

		@calculated_results = @line_sizing.calculated_results

		ps = @project.project_sizing_criterias
		@sizing_criterias.each do |sc|
			ps.each do |p|
				if sc.id == p.sizing_criteria_id
					sc.velocity_max = p.velocity_max
					sc.velocity_min = p.velocity_min
					sc.velocity_sel = p.velocity_sel
					sc.delta_per_100ft_max = p.delta_per_100ft_max
					sc.delta_per_100ft_min = p.delta_per_100ft_min
					sc.delta_per_100ft_sel = p.delta_per_100ft_sel
				end
			end
		end
	end

	def update    
		line_sizing = params[:line_sizing]
		line_sizing[:updated_by] = current_user.id

		@line_sizing = @company.line_sizings.find(params[:id])  

		if !@line_sizing.process_basis_id.nil?
			if heat_and_material_balance = HeatAndMaterialBalance.find(@line_sizing.process_basis_id)
				@streams = heat_and_material_balance.heat_and_material_properties.first.streams
			else
				@streams = [] 
			end
		end

		@sizing_criteria_category_types = SizingCriteriaCategoryType.where("sizing_criteria_category_id = ?", @line_sizing.sizing_criteria_category_id)    
		@sizing_criterias = SizingCriteria.where("sizing_criteria_category_id = ? AND sizing_criteria_category_type_id = ?", line_sizing[:sizing_criteria_category_id], line_sizing[:sizing_criteria_category_type_id])

		if @line_sizing.update_attributes(line_sizing)
			flash[:notice] = "updated line sizing successfully."
			redirect_to admin_line_sizings_path       
		else      
			render :edit
		end        
	end

	def destroy
		@line_sizing = @company.line_sizings.find(params[:id])
		if @line_sizing.destroy
			flash[:notice] = "Deleted #{@line_sizing.line_number} successfully."
			redirect_to admin_line_sizings_path
		end    
	end

	def clone
		@line_sizing = LineSizing.find(params[:id])
		new = @line_sizing.deep_clone(["pipe_sizings"])
		new.line_number = params[:tag]
		if new.save
			render :json => {:error => false, :url => edit_admin_line_sizing_path(new) }
		else
			render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
		end
		return
	end

	#TODO Code modification geting stream values
	def get_stream_values
		form_values = {}
		heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])
		property = heat_and_meterial_balance.heat_and_material_properties

		temperature = property.where(:phase => "Overall", :property => "Temperature").first
		temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first    
		form_values[:temperature_value] = temperature_stream.stream_value.to_f rescue nil
		form_values[:temperature_unit] = temperature.unit

		pressure = property.where(:phase => "Overall", :property => "Pressure").first
		pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first if pressure.nil?
		pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first    
		form_values[:pressure_value] = pressure_stream.stream_value.to_f rescue nil
		form_values[:pressure_unit] = pressure.unit

		vapour_fraction = property.where(:phase => "Overall", :property => "Vapour Fraction").first
		vapour_fraction_stream = vapour_fraction.streams.where(:stream_no => params[:stream_no]).first    
		form_values[:vapour_fraction_value] = vapour_fraction_stream.stream_value.to_f rescue nil
		form_values[:vapour_fraction_unit] = vapour_fraction.unit

		flowrate = property.where(:phase => "Overall", :property => "Mass Flow").first
		flowrate_stream = flowrate.streams.where(:stream_no => params[:stream_no]).first    
		form_values[:flowrate_value] = flowrate_stream.stream_value.to_f rescue nil
		form_values[:flowrate_unit] = flowrate.unit

		density = property.where(:phase => "Vapour", :property => "Mass Density").first
		density_stream = density.streams.where(:stream_no => params[:stream_no]).first
		form_values[:density_value] = density_stream.stream_value.to_f rescue nil
		form_values[:density_unit] = density.unit

		viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
		viscosity_stream = viscosity.streams.where(:stream_no => params[:stream_no]).first
		form_values[:viscosity_value] = viscosity_stream.stream_value.to_f rescue nil
		form_values[:viscosity_unit] = viscosity.unit

		molecular_weight = property.where(:phase => "Vapour", :property => "Molecular Weight").first
		molecular_weight_stream = molecular_weight.streams.where(:stream_no => params[:stream_no]).first
		form_values[:mw_value] = molecular_weight_stream.stream_value.to_f rescue nil
		form_values[:mw_unit] = molecular_weight.unit rescue nil

		molecular_weight = property.where(:phase => "Light Liquid", :property => "Molecular Weight").first    
		molecular_weight_stream = molecular_weight.streams.where(:stream_no => params[:stream_no]).first
		form_values[:liquid_mw_value] = molecular_weight_stream.stream_value.to_f rescue nil

		cp_cv = property.where(:phase => "Vapour", :property => "Cp/Cv (Gamma)").first    
		cp_cv_stream = viscosity.streams.where(:stream_no => params[:stream_no]).first
		form_values[:cp_cv_value] = cp_cv_stream.stream_value.to_f rescue nil
		form_values[:cp_cv_unit] = cp_cv.unit

		z = property.where(:phase => "Vapour", :property => "Compressibility").first    
		z_stream = z.streams.where(:stream_no => params[:stream_no]).first
		form_values[:z_value] = z_stream.stream_value.to_f rescue nil
		form_values[:z_unit] = z.unit

		liquid_density = property.where(:phase => "Light Liquid", :property => "Mass Density").first    
		liquid_density_stream = liquid_density.streams.where(:stream_no => params[:stream_no]).first
		form_values[:liquid_density_value] = liquid_density_stream.stream_value.to_f rescue nil
		form_values[:liquid_density_unit] = liquid_density.unit

		liquid_viscosity = property.where(:phase => "Light Liquid", :property => "Viscosity").first
		liquid_viscosity_stream = liquid_viscosity.streams.where(:stream_no => params[:stream_no]).first
		form_values[:liquid_viscosity_value] = liquid_viscosity_stream.stream_value.to_f rescue nil
		form_values[:liquid_viscosity_unit] = liquid_viscosity.unit

		liquid_surface_tension = property.where(:phase => "Light Liquid", :property => "Surface Tension").first
		liquid_surface_tension_stream = liquid_surface_tension.streams.where(:stream_no => params[:stream_no]).first
		form_values[:liquid_surface_tension_value] = liquid_surface_tension_stream.stream_value.to_f rescue nil
		form_values[:liquid_surface_tension_unit] = liquid_surface_tension.unit

		render :json => form_values
	end

	#loading sizing criteria types
	def get_sizing_criteria_types    

		sizing_criteria_category_types_obj = SizingCriteriaCategoryType.where("sizing_criteria_category_id = ?", params[:sizing_criteria_category_id])

		render :json => sizing_criteria_category_types_obj
	end

	#loading sizing criterias
	def get_sizing_criterias
		sizing_criterias = SizingCriteria.where("sizing_criteria_category_id = ? AND sizing_criteria_category_type_id = ?", params[:sizing_criteria_category_id], params[:sizing_criteria_category_type_id])
		#convention factor
		project = Project.find(params[:project_id])
		project_unit = project.unit_of_measurements.
			joins(:measure_unit, :measurement_sub_type, :measurement).
			where("measurements.name = ? AND measurement_sub_types.name = ? AND measure_units.unit_type_id = ?", 'Length', 'Large Dimension Length', project.units_of_measurement_id.to_i).
			select("measure_units.*").
			first 

		project_conversion_factor = project_unit.conversion_factor rescue 0
		conversion_factor = 0

		#getting ft convretion
		ft_conversion_factor = 0
		if project_conversion_factor != 0
			feet_unit = MeasureUnit.
				joins(:measurement_sub_type, :measurement).
				where("measurements.name = ? AND measurement_sub_types.name = ? AND measure_units.unit = ?", "Length", "Large Dimension Length", "ft").
				select("measure_units.*").
				first

			ft_conversion_factor = feet_unit.conversion_factor rescue 0        
		end

		if ft_conversion_factor != 0
			conversion_factor = (ft_conversion_factor.to_f/project_conversion_factor.to_f)
		end

		render :json => {:sizing_criterias => sizing_criterias, :conversion_factor => conversion_factor}
	end

	def line_sizing_summary
		@line_sizings = @company.line_sizings.all
	end

	def sizing_criteria_calculation   
		calculated_values = {}
		line_sizing = LineSizing.find(params[:line_sizing_id])
		project = line_sizing.project
		process_basis = line_sizing.process_basis_id
		stream_no = line_sizing.stream_no
		stream_description = line_sizing.description
		stream_pressure = line_sizing.pressure
		stream_temperature = line_sizing.temperature
		stream_vapor_fraction = line_sizing.vapour_fraction
		stream_phase = line_sizing.get_stream_phase
		stream_flow_rate = line_sizing.flowrate
		stream_liquid_flow_rate = stream_flow_rate * (1 - stream_vapor_fraction);
		stream_vapor_flow_rate = stream_flow_rate * stream_vapor_fraction;
		vapor_density = line_sizing.vapor_density
		vapor_viscosity = line_sizing.vapor_viscosity
		vapor_k = line_sizing.vapor_cp_cv
		vapor_z = line_sizing.vapor_z    
		liquid_density = line_sizing.liquid_density
		liquid_viscosity = line_sizing.liquid_viscosity
		vapor_mw = line_sizing.vapor_mw
		liquid_surface_tension = line_sizing.liquid_surface_tension
		system_equivalent_length = line_sizing.system_equivalent_length
		system_maximum_deltaP = line_sizing.system_maximum_deltaP
		pipe_roughness = line_sizing.pipe_roughness
		pipe_material= line_sizing.pipe_id
		pi = 3.14159265358979

		uncertainty_f = 0
		if line_sizing.include_design_factor == true
			uncertainty_f = project.hydraulic_sizing_overdesign_factor / 100;
		end
		stream_flow_rate = stream_flow_rate * (1.0 + uncertainty_f);

		if (line_sizing.dc_calculate_type == "stream_sizing")

			if stream_phase == "liquid"
				#Determine required diameter      
				diameter = liquid_diameter_calc(liquid_viscosity, liquid_density, stream_pressure,  system_maximum_deltaP, system_equivalent_length, stream_flow_rate, pi, pipe_roughness)
			elsif stream_phase == "vapor"      
				diameter = vapor_diameter_calc(vapor_k, vapor_mw, stream_temperature, stream_flow_rate, vapor_viscosity, vapor_density, pipe_roughness, stream_pressure, system_maximum_deltaP, system_equivalent_length, project, pi)
			elsif stream_phase == "two-phase"      
				diameter = two_phase_diameter_calc(stream_liquid_flow_rate, stream_vapor_flow_rate, liquid_density, vapor_density, liquid_viscosity, vapor_viscosity, liquid_surface_tension, system_maximum_deltaP, system_equivalent_length, stream_pressure, process_basis, stream_no, pi, pipe_roughness, project)
			end

			determine_nominal_pipe_size_values = determine_nominal_pipe_size(diameter[:proposed_diameter])  

			if stream_phase != "two-phase"
				#determine_pipe_diameter_values = determine_pipe_diameter(determine_nominal_pipe_size_values[:pipe_size], determine_nominal_pipe_size_values[:pipe_schedule])

				actual_area = pi * (determine_nominal_pipe_size_values[:proposed_diameter].to_f / 2.0) ** 2.0      
				# proposed_area = pi * (determine_pipe_diameter_values[:selected_diameter] / 2) ^ 2
				proposed_area = 10.0
				calculated_velocity = ((diameter[:volume_rate] * 144.0) / (proposed_area * 3600)).round(2)
				relief_rate = "vapor";

				if stream_phase == "liquid"
					fluid_momentum = liquid_density * calculated_velocity ** 2
					#lblMomentum = Round(FluidMomentum, 0)
					#lblErrosionIndex = Round(FluidMomentum, 0)
				elsif relief_rate == "Vapor" #ReliefRate TODO find the value
					fluid_momentum = liquid_density * calculated_velocity ** 2
					#lblMomentum = Round(FluidMomentum, 0)
					#lblErrosionIndex = Round(FluidMomentum, 0)
				end

				#Compare against criteria and add comments
				#Print calculated velocity
				#UOM = "Velocity"
				#UOMUnit = lblCalcVelocityUnit
				#UOMValue = CalculatedVelocity
				#Call ResultsUnitConversion(UOMUnit, UOMValue, UOM)                  'Module 88
				#CalculatedVelocity = UOMValue

				#lblCalculatedVelocity = CalculatedVelocity

				#Print calculated pressure drop
				p_drop_calc_values = {}      
				if stream_phase == "two-phase"
					#TODO need work
					p_drop_calc_values = p_drop_calc_two_phase(determine_nominal_pipe_size_values[:proposed_diameter], stream_liquid_flow_rate, stream_vapor_flow_rate, liquid_density, vapor_density, liquid_viscosity, vapor_viscosity, liquid_surface_tension, process_basis, stream_no, pi, calculated_velocity, pipe_roughness, system_equivalent_length)
					p_drop_calc_values = {:actual_dp => 1}
				elsif stream_phase == "vapor"        
					p_drop_calc_values = p_drop_calc_vapor(pi, project, vapor_viscosity, vapor_density, stream_pressure, stream_temperature, vapor_k, vapor_mw, stream_flow_rate, determine_nominal_pipe_size_values[:proposed_diameter], pipe_roughness, system_equivalent_length)
				elsif stream_phase == "liquid"         
					p_drop_calc_values = p_drop_calc_liquid(liquid_viscosity, liquid_density, stream_flow_rate, determine_nominal_pipe_size_values[:proposed_diameter], pipe_roughness, system_equivalent_length, pi) 
				end

				upstream_pressure = stream_pressure + barometric_pressure
				#pressure_loss_percentage = ((p_drop_calc_values[:actual_dp].to_f / upstream_pressure) * 100).round(1)
				pressure_loss_percentage = ((100 / upstream_pressure) * 100).round(1)     
				#lblPressureLossPercentage = PressureLossPercentage
				#lblCalculatedDP = Round(ActualDP, 3)
				#lblSystemEquivalentLength = txtSystemLength.Value
				#Print flow regime
				p_drop_calc_values[:d_reynolds] = 5000 #TODO
				flow_regime = "Turbulent"
				if stream_phase != "two-phase"
					if p_drop_calc_values[:d_reynolds] > 4000
						flow_regime = "Turbulent"
					elsif p_drop_calc_values[:d_reynolds] > 2000 && p_drop_calc_values[:d_reynolds] < 4000
						flow_regime = "Transition"
					elsif p_drop_calc_values[:d_reynolds] <= 2000
						flow_regime = "Laminar"
					end
				end
				#lblFlowRegime = flow_regime
			else #for If stream_phase != "two-phase"
				calculated_velocity = diameter[:vm]
				#UOM = "Velocity"
				#UOMUnit = lblCalcVelocityUnit
				#UOMValue = CalculatedVelocity
				#Call ResultsUnitConversion(UOMUnit, UOMValue, UOM)                  'Module 88
				#CalculatedVelocity = UOMValue

				#lblCalculatedVelocity = Round(CalculatedVelocity, 2)

				#UOM = "DifferentialPressure"
				#UOMUnit = lblCalcDPUnit
				#UOMValue = ActualDP
				#Call ResultsUnitConversion(UOMUnit, UOMValue, UOM)                  'Module 88
				#ActualDP = UOMValue

				upstream_pressure = stream_pressure + barometric_pressure
				p_drop_calc_values = {}
				p_drop_calc_values[:actual_dp] =  100 #TODO
				pressure_loss_percentage = ((p_drop_calc_values[:actual_dp].to_f / upstream_pressure) * 100).round(1)
				#lblPressureLossPercentage = pressure_loss_percentage
				#lblCalculatedDP = Round(ActualDP, 3)
				#lblSystemEquivalentLength = txtSystemLength.Value
				#lblFlowRegime = FlowRegime
				#lblMomentum = Round(FluidMomentum, 0)
			end

			calculated_values[:diameter] = diameter

		end #end if dc_calculate_type condition
		render :json => calculated_values     
	end

	def segment_sizing_criteria_calculation
		log = CustomLogger.new('line_sizing')
		calculated_values = {}
		#raise params[:desired_flow_regime][22].to_yaml
		line_sizing = LineSizing.find(params[:line_sizing_id])
		project = line_sizing.project

		uom = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
		barometric_pressure = project.barometric_pressure * uom[:factor] 

		log.info("converted barometric_pressure = #{barometric_pressure}")

		process_basis = line_sizing.process_basis_id
		stream_no = line_sizing.stream_no
		stream_description = line_sizing.description

		log.info("pressure input = #{line_sizing.pressure}")
		stream_pressure = line_sizing.convert_to_base_unit(:pressure)
		log.info("pressure converted = #{stream_pressure}")

		log.info("temperature input= #{line_sizing.temperature}")
		stream_temperature = line_sizing.convert_to_base_unit(:temperature)
		log.info("temperature input= #{stream_temperature}")

		stream_vapor_fraction = line_sizing.vapour_fraction

		stream_phase = line_sizing.get_stream_phase

		log.info("flowrate input= #{line_sizing.flowrate}")
		stream_flow_rate = line_sizing.convert_to_base_unit(:flowrate)
		log.info("flow converted = #{stream_flow_rate}")

		stream_liquid_flow_rate = stream_flow_rate * (1.0 - stream_vapor_fraction);
		stream_vapor_flow_rate = stream_flow_rate * stream_vapor_fraction;

		log.info("vapor_density input = #{line_sizing.vapor_density}")
		vapor_density = line_sizing.convert_to_base_unit(:vapor_density)
		log.info("vapor_density converted = #{vapor_density}")

		log.info("vapor_viscosity input = #{line_sizing.vapor_viscosity}")
		vapor_viscosity = line_sizing.convert_to_base_unit(:vapor_viscosity)
		log.info("vapor_viscosity converted = #{vapor_viscosity}")

		vapor_k = line_sizing.vapor_cp_cv
		vapor_z = line_sizing.vapor_z    
		vapor_mw = line_sizing.vapor_mw

		log.info("vapor cp cv = #{vapor_k}")
		log.info("vapor z = #{vapor_z}")
		log.info("vapor mw = #{vapor_mw}")

		log.info("liquid_density input = #{line_sizing.liquid_density}")
		liquid_density = line_sizing.convert_to_base_unit(:liquid_density)
		log.info("liquid_density converted = #{liquid_density}")

		log.info("liquid_viscosity input = #{line_sizing.liquid_viscosity}")
		liquid_viscosity = line_sizing.convert_to_base_unit(:liquid_viscosity)
		log.info("liquid_viscosity converted = #{liquid_viscosity}")

		vapor_mw = line_sizing.vapor_mw
		liquid_surface_tension = line_sizing.liquid_surface_tension

		log.info("system_equivalent_length input = #{line_sizing.system_equivalent_length}")
		system_equivalent_length = line_sizing.convert_to_base_unit(:system_equivalent_length)
		log.info("system_equivalent_length converted = #{system_equivalent_length}")

		log.info("delta p input = #{line_sizing.system_maximum_deltaP}")
		deltaP = line_sizing.convert_to_base_unit(:system_maximum_deltaP)
		log.info("delta p converted = #{deltaP}")



		log.info("pipe roughness input = #{line_sizing.pipe_roughness}")
		pipe_roughness = line_sizing.convert_to_base_unit(:pipe_roughness)
		log.info("pipe roughness converted = #{pipe_roughness}")

		pipe_material = line_sizing.pipe_id
		pi = 3.14159265358979
		flow_regime = ""

		uncertainty_f = 0
		if line_sizing.include_design_factor == true
			uncertainty_f = project.hydraulic_sizing_overdesign_factor / 100;
		end
		stream_flow_rate = stream_flow_rate * (1.0 + uncertainty_f);


		#logging ===
		log.info("stream flow reate #{stream_flow_rate}")

			if stream_phase == "liquid"
				log.info("#### stream phase = liquid ####")
				#declarations
				pipe_id = []
				f = []
				flow_c = []
				total_system_pressure_drop = []
				fitting_pressure_drop1 = []
				fitting_pressure_drop = 0
				pressure_drop_percentage = 0

				pipe_sizings = line_sizing.pipe_sizings 
				count = pipe_sizings.size 
				volume_rate = stream_flow_rate / liquid_density
				nre = PipeSizing.reynold_number(params[:line_sizing_id])
				nreynolds = 0.0
				proposed_iteration = 0

				(1..33).each do |k|        
					log.info("iteration k ====================================== #{k}")
					#declarations
					fitting_pressure_drop1[k] = []
					kfi =[]
					kfd =[]
					length = []
					equivalent_length = []
					elevation = []
					pipe_id[k] = PipeSizing.pipe_size_cycle[k-1][:diameter].to_f
					nre[k] = (6.316 * stream_flow_rate) / (pipe_id[k] * liquid_viscosity)
					nreynolds = nre[k]

					#logs
					log.info("pipe_id[k] = #{pipe_id[k]}")
					log.info("nreynolds = #{nreynolds}")

					kfi_sum = 0.0
					kfd_sum = 0.0
					sum_elevation = 0.0
					total_equivalent_length = 0
					system_maximum_deltaP = 0.0
					(0..count-1).each do |m|              
						log.info("-----fitting iteration ---- #{m}")
						cv = pipe_sizings[m].ds_cv 
						dover_d = pipe_sizings[m].ds_cv
						dorifice = pipe_sizings[m].ds_cv 

						length[m] = line_sizing.convert_to_base_unit(:pipe_sizing_length,pipe_sizings[m].length) 
						elevation[m] = line_sizing.convert_to_base_unit(:pipe_sizing_elevation,pipe_sizings[m].elev)

						log.info("------length[m] = #{length[m]}")
						log.info("------elevation[m] = #{elevation[m]}")

						#churchill equation
						a = (2.457 * Math.log(1.0 / (((7.0 / nre[k]) ** 0.9) + (0.27 * (pipe_roughness / pipe_id[k]))))) ** 16.0 
						b = (37530.0 / nre[k]) ** 16.0

						f[k] = 2.0 * ((8.0 / nre[k]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0)
						fd = 4.0 * f[k]
						nreynolds = nre[k]
						d = pipe_id[k]

						fitting_type = PipeSizing.get_fitting_tag(pipe_sizings[m].fitting_id)[:value]
						log.info("------------nreynolds   #{nreynolds}")

						if fitting_type == "Pipe"
							kf = 4.0 * f[k] * (length[m] / (pipe_id[k] / 12.0))
							equivalent_length[m] = length[m]
						else
							d1 = 0.0
							d2 = 0.0
							rec =  PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, cv)
							kf= rec[:kf]
							equivalent_length[m] = (kf / fd) * (pipe_id[k] / 12.0)
						end #end fitting type If Cases

						log.info("------------kf = #{kf}")
						log.info("------------equivalent length = #{equivalent_length[m]}")

						kfi[m] = kf
						kfd[m] = kfi[m] / ((pipe_id[k] / 12.0) ** 4.0)
						kfi_sum = kfi_sum + kfi[m]
						kfd_sum = kfd_sum + kfd[m]
						total_equivalent_length = total_equivalent_length + equivalent_length[m]
						sum_elevation = sum_elevation + elevation[m]

						#logs
						log.info("----------kfd[m] = #{kfd[m]}")
						log.info("----------kfi[m] = #{kfi[m]}")
						log.info("----------kfi_sum = #{kfi_sum}")
						log.info("----------kfd_sum = #{kfd_sum}")


						#Determine friction energy loss
						sumef = (1.94393 * (10.0 ** -9.0)) * (volume_rate ** 2.0) * kfd_sum #'Unit is lbf-ft/lbm


						#'Determine Potential Energy, HE
						he = sum_elevation                                       #'Unit is lbf-ft/lbm
						#'Determine Work Done, W"
						w = 0                                                    #'Unit is lbf-ft/lbm
						#'Determine Heat Input, Q
						q = 0                                                    #'Unit is lbf-ft/lbm
						#'Determine Pressure Drop
						fitting_pressure_drop = (liquid_density / 144.0) * (he + sumef)        #'psi
						fitting_pressure_drop1[k][m] = fitting_pressure_drop

						#logs
						log.info("------------sum elevation #{sum_elevation}")
						log.info("------------sum ef #{sumef}")
						log.info("------------fiting pressure drop #{fitting_pressure_drop}")

					end #end for loop 1..count
					log.info("system_equivalent_length = #{system_equivalent_length}")

					total_system_pressure_drop[k] = fitting_pressure_drop
					pressure_drop_percentage = ((fitting_pressure_drop / (stream_pressure + barometric_pressure) ) * 100.0).round(1)
					system_maximum_deltaP = (total_equivalent_length / system_equivalent_length) * deltaP
					#TODO check if variable is being affected for other cases as its taken from form.


					if(total_system_pressure_drop[k] <= system_maximum_deltaP and (total_system_pressure_drop[k-1] >= system_maximum_deltaP unless total_system_pressure_drop[k-1].nil? ))
						(0..count-1).each do |m|
							fitting_pressure_drop1[k][m] = (stream_pressure - fitting_pressure_drop1[k][m]).round(1)
						end
						proposed_iteration = k if proposed_iteration == 0
					elsif total_system_pressure_drop[k] <= system_maximum_deltaP
						(0..count-1).each do |m|
							fitting_pressure_drop1[k][m] = (stream_pressure - fitting_pressure_drop1[k][m]).round(1)
						end
						proposed_iteration = k if proposed_iteration == 0
					end        

					if nreynolds < 2000
						flow_regime = "Laminar"
					elsif nreynolds >= 4000
						flow_regime = "Turbulent"
					else
						flow_regime = "Transitional Zone"
					end

					log.info("-----------------------------------------------------")
					log.info("nreynolds = #{nreynolds}")
					log.info("flow regime = #{flow_regime}")
					log.info("pressure drop percentage = #{pressure_drop_percentage}")
					log.info("total equivalent length = #{total_equivalent_length}")
					log.info("system equivalent length = #{system_equivalent_length}")
					log.info("system_maximum_deltaP = #{system_maximum_deltaP}")
					log.info("total system pressure drop[k] = #{total_system_pressure_drop[k]}")
					log.info("-----------------------------------------------------")

				rupture_diameter = pipe_id[k]
				determine_nominal_pipe_size_values = determine_nominal_pipe_size(rupture_diameter)
				proposed_diameter = determine_nominal_pipe_size_values[:proposed_diameter]
				proposed_area= pi* ((proposed_diameter/2.0)**2.0)
				pipe_size = determine_nominal_pipe_size_values[:pipe_size]
				pipe_schedule = determine_nominal_pipe_size_values[:pipe_schedule]
				pipe_d = determine_pipe_diameter(pipe_size, pipe_schedule )  
				um =  (volume_rate * 144.0) / (proposed_area * 3600.0)
				fluid_momentum =  liquid_density *( um ** 2.0)
				fitting_pressure_drop.round(3)
				um.round(2)
				total_equivalent_length.round(1)
				fluid_momentum.round(1)

				iteration = {}
				iteration[:rupture_diameter] = line_sizing.convert_to_project_unit(:sc_required_id,rupture_diameter)
				iteration[:proposed_diameter] = line_sizing.convert_to_project_unit(:sc_proposed_id, proposed_diameter)
				iteration[:pipe_size] = pipe_size
				iteration[:nominal_pipe_size] = PipeSizing.nominal_pipe_diameter[pipe_size.to_f]
				iteration[:pipe_schedule] = pipe_schedule
				iteration[:fitting_pressure_drop] = line_sizing.convert_to_project_unit(:sc_calculated_system_dp,fitting_pressure_drop)
				iteration[:um] = line_sizing.convert_to_project_unit(:sc_calculated_velocity,um)
				iteration[:total_equivalent_length] = line_sizing.convert_to_project_unit(:sc_system_equivalent_length,total_equivalent_length)
				iteration[:pressure_drop_percentage] = pressure_drop_percentage
				iteration[:flow_regime] = flow_regime
				iteration[:erosion_corrosion_index] = line_sizing.convert_to_project_unit(:sc_fluid_momentum,fluid_momentum)
				iteration[:fluid_momentum] = line_sizing.convert_to_project_unit(:sc_fluid_momentum,fluid_momentum)
				iteration[:pipe_d] = pipe_d
				calculated_values[k] = iteration
				end # end for loop 1..30 

				calculated_values[:proposed_iteration] = proposed_iteration
				line_sizing.calculated_results = calculated_values
				proposed = calculated_values[proposed_iteration]

				#Assigning Values to db elements for pipe sizings.
				ps_ids = line_sizing.pipe_sizing_ids


				ps_ids.each_with_index do |ps_id,i|
					ps = PipeSizing.find(ps_id)
					ps.p_outlet = line_sizing.convert_to_project_unit(:pipe_sizing_p_outlet,fitting_pressure_drop1[proposed_iteration][i])
					ps.pipe_schedule = proposed[:pipe_schedule]
					ps.pipe_size = proposed[:pipe_size]
					ps.pipe_id = proposed[:pipe_d]
					ps.save
				end

				#Assignign values to form elements in line sizing.          
				line_sizing.sc_required_id = proposed[:rupture_diameter]
				line_sizing.sc_proposed_id = proposed[:proposed_diameter]
				line_sizing.sc_pipe_size = proposed[:nominal_pipe_size]
				line_sizing.sc_pipe_schedule = proposed[:pipe_schedule]
				line_sizing.sc_calculated_system_dp = proposed[:fitting_pressure_drop]
				line_sizing.sc_calculated_velocity = proposed[:um]
				line_sizing.sc_system_equivalent_length = proposed[:total_equivalent_length]
				line_sizing.sc_pressure_loss_percentage = proposed[:pressure_drop_percentage]
				line_sizing.sc_flow_regime = proposed[:flow_regime]
				line_sizing.sc_erosion_corrosion_index = proposed[:erosion_corrosion_index]
				line_sizing.sc_fluid_momentum = proposed[:fluid_momentum]
				line_sizing.save         

			elsif stream_phase == "vapor"

				#declarations
				pipe_id = []
				f = []
				area = []
				g = []
				flow_c = []
				fitting_outlet_pressure = []
				total_system_pressure_drop = []
				fitting_pressure_drop = 0
				pressure_drop_percentage = 0
				proposed_iteration = 0

				pipe_sizings = line_sizing.pipe_sizings 
				count = pipe_sizings.size 
				nre = PipeSizing.reynold_number(params[:line_sizing_id])
				sonic_velocity = 68.1 * (vapor_k * (stream_pressure + barometric_pressure) * (1 / vapor_density)) ** 0.5

				log.info("sonic velocity = #{sonic_velocity}")
				log.info("vapor flow model = #{project.vapor_flow_model}")

				inlet_presure = (1..100).to_a
				inlet_temperature = (1..100).to_a
				section_outlet_pressure = (1..100).to_a
				section_outlet_temperature = (1..100).to_a
				fitting_outlet_pressure = {}

				(1..33).each do |k|
					log.info("iteration k ====================================== #{k}")
					#declarations
					fitting_outlet_pressure[k] = []
					length = []
					equivalent_length = []
					elevation = []
					kfi =[]
					kfd =[]
					p1=0
					p2=0
					p2critical = 0
					nreynolds = nre[k-1]

					pipe_id[k] = PipeSizing.pipe_size_cycle[k-1.0][:diameter].to_f
					area[k] = pi * (pipe_id[k] / 2.0) ** 2.0 #in^2
					g[k] = stream_flow_rate / area[k]
					volume_rate = stream_flow_rate / vapor_density
					proposed_area = area[k]
					um = (volume_rate * 144.0) / (proposed_area * 3600.0)

					log.info(" pipe_id[k] = #{pipe_id[k]}")
					log.info(" area[k] = #{area[k]}")
					log.info(" g[k] = #{g[k]}")
					log.info(" volume rate = #{volume_rate}")
					log.info(" um = #{um}")
					log.info(" steram flow rate = #{stream_flow_rate}")

					loop_next = false

					next if um > sonic_velocity

					skip_loop_k = false

					choke_counter = 0 

					nre[k] = (6.316 * stream_flow_rate) / (pipe_id[k] * vapor_viscosity)
					log.info("nre[k] = #{nre[k]}")

					total_equivalent_length = 0.0
					system_maximum_deltaP = 0.0

					(0..count-1).each do |m|
						log.info("fitting iteration ============= #{m}")
						cv =  pipe_sizings[m].ds_cv
						dover_d = pipe_sizings[m].ds_cv
						dorifice = pipe_sizings[m].ds_cv
						length[m] = line_sizing.convert_to_base_unit(:pipe_sizing_length,pipe_sizings[m].length)
						kfi_sum = 0.0

						#Determine new friction factor using Churchill's equation
						a = (2.457 * Math.log(1.0 / (((7.0 / nre[k]) ** 0.9) + (0.27 * (pipe_roughness / pipe_id[k]))))) ** 16.0 
						b = (37530.0 / nre[k]) ** 16.0
						f[k] = 2.0 * ((8.0 / nre[k]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0)
						fd = 4.0 * f[k]
						nreynolds = nre[k]
						d = pipe_id[k]
						fitting_type = PipeSizing.get_fitting_tag(pipe_sizings[m].fitting_id)[:value]

						log.info("---------A = #{a}")
						log.info("---------B = #{b}")

						if fitting_type == "Pipe"
							kf = 4.0 * f[k] * (length[m]  / (pipe_id[k] / 12.0))
							equivalent_length[m] = length[m]
						else
							d1 = 0.0
							d2 = 0.0
							rec =  PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, cv)
							kf = rec[:kf]
							equivalent_length[m] = (kf / fd) * (pipe_id[k] / 12.0)
						end 

						log.info("----------f[k] == #{f[k]}")
						log.info("----------kf == #{kf}")
						log.info("----------fd == #{fd}")
						log.info("----------equivalent_length ==== #{equivalent_length[m]}")

						kfi[m] = kf
						kfi_sum = kfi_sum + kfi[m]

						log.info("----------kfi_sum = #{kfi_sum}")

						total_equivalent_length = total_equivalent_length + equivalent_length[m]

						inlet_presure[0] = stream_pressure #TODO adjusted to make the code work.
						inlet_temperature[0] = stream_temperature

						if project.vapor_flow_model == "Isothermal"
							part1 = (inlet_presure[m] + barometric_pressure ) ** 2.0
							part2 = (7.41109 * 10.0 ** -6.0 * (inlet_temperature[0] + 459.67) * g[k] ** 2.0) / vapor_mw 
							part3 = kfi_sum / 2.0

							log.info("part1 = #{part1}")
							log.info("part2 = #{part2}")
							log.info("part3 = #{part3}")

							skip_loop_k = true if (part1 - (part2 * part3)) < 0
							break if skip_loop_k
							initial_outlet_pressure = (part1 - (part2 * part3)) ** 0.5

							loop_break = false
							gg_value = 0
							(1..100).each do |gg|
								part4 = Math.log((inlet_presure[m] + barometric_pressure) / initial_outlet_pressure)

								log.info("-----------------iteration gg = #{gg}")
								#log.info("------------------part4 = #{part4}")

								skip_loop_k = true if (part1 - part2 * (part3 + part4)) < 0.0
								#break the main loop
								break if skip_loop_k
								section_outlet_pressure[gg] = (part1 - part2 * (part3 + part4)) ** 0.5
								initial_outlet_pressure = section_outlet_pressure[gg]
								if section_outlet_pressure[gg] == (section_outlet_pressure[gg-1] unless section_outlet_pressure[gg-1].nil?)
									inlet_presure[m + 1] = section_outlet_pressure[gg] - barometric_pressure
									loop_break = true
									gg_value = gg
								end
								break if loop_break
								log.info("-------------section_outlet_pressure[gg] = #{section_outlet_pressure[gg]}")
								log.info("-------------section_outlet_pressure[gg-1] = #{section_outlet_pressure[gg-1]}")
							end

							log.info("gg value = #{gg_value}")

							#Determine sonic downstream pressure at each fitting along the system
							#Check for choked flow
							p1 = inlet_presure[m]
							p2 = inlet_presure[m+1]# unless inlet_presure[m+1].nil?
							fitting_outlet_pressure[k][m] = p2

							log.info("p1 = #{p1}")
							log.info("p2 = #{p2}")
							log.info("---------outlet pressure = #{fitting_outlet_pressure[k][m]}")

							r_value = 0
							(1..1000).each do |r|
								p2critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
								part1 = ((p1 + barometric_pressure) / p2critical) ** 2.0
								part2 = 2.0 * Math.log((p1 + barometric_pressure) / p2critical)
								isothermal_choke_kf = part1 - part2 - 1
								#log.info("-------------------------------------iteration  r-----#{r}")
								#log.info("-------------------------------------p2critical = #{p2critical}")
								#log.info("-------------------------------------part1 = #{part1}")
								#log.info("-------------------------------------part2 = #{part2}")
								#log.info("-------------------------------------isothermal_choke_kf = #{i#log.info("-------------------------------------kfi_sum = #{kfi_sum}")
								break if kfi_sum <= isothermal_choke_kf
								r_value = r
							end

							log.info("r value = #{r_value}")
							log.info("-----------p2critical = #{p2critical}")

							if (p2critical - barometric_pressure) >= p2 
								skip_loop_k = true
								#msg1 = MsgBox("The system is expected to experience choke flow on fitting #" & m & " (" & fitting_type & ").  Do you want to avoid or include this choke condition in this piping design.  Click YES to avoid or click NO to include", vbYesNoCancel, "Choke Flow Detected!")
								#If msg1 = vbYes Then
								#k = k + 1
								#GoTo Line4:
								#elsif msg1 = vbNo Then
								#Notes = "Choke flow experienced in piping design."
								#Else
								#End If
							end
						elsif project.vapor_flow_model == "Adiabatic"
							part1 = vapor_k / (vapor_k + 1.0)
							part2 = 269866.0 * (vapor_k / (vapor_k + 1.0))
							part3 = ((inlet_presure[m] + barometric_pressure) ** 2.0 * vapor_mw) / (inlet_temperature[m] + 459.67)
							part4 = g[k] ** 2.0 * (kfi_sum / 2.0)

							skip_loop_k = true if (1 - (part4 / (part2 * part3))) < 0

							next if skip_loop_k

							initial_outlet_pressure = (inlet_presure[m] + barometric_pressure) * (1 - (part4 / (part2 * part3))) ** part1

							log.info("-----part1 = #{part1}")
							log.info("-----part2 = #{part2}")
							log.info("-----part3 = #{part3}")
							log.info("-----part4 = #{part4}")
							log.info("-----initial_outlet_pressure = #{initial_outlet_pressure}")
							log.info("-----inlet_presure[m] = #{inlet_presure[m]}")
							log.info("-----inlet_temperature[m] = #{inlet_temperature[m]}")
							log.info("-----barometric_pressure = #{barometric_pressure}")
							log.info("-----vapor_k = #{vapor_k}")

							loop_break = false
							(1..100).each do |gg|
								part5 = (Math.log((inlet_presure[m] + barometric_pressure) / initial_outlet_pressure)) / vapor_k
								part6 = g[k] ** 2.0 * ((kfi_sum / 2.0) + part5)

								log.info("-------------iteration --- gg = #{gg}")
								log.info("---------------part5 = #{part5}")
								log.info("---------------part6 = #{part6}")

								skip_loop_k = true if (1.0 - (part6 / (part2 * part3))) < 0
								break if skip_loop_k

								section_outlet_pressure[gg] = (inlet_presure[m] + barometric_pressure) * (1 - (part6 / (part2 * part3))) ** part1
								part7 = inlet_temperature[m] + 459.69
								part8 = section_outlet_pressure[gg] / (inlet_presure[m] + barometric_pressure)
								part9 = (vapor_k - 1.0) / vapor_k

								log.info("---------------part7 = #{part7}")
								log.info("---------------part8 = #{part8}")
								log.info("---------------part9 = #{part9}")

								section_outlet_temperature[gg] = part7 * (part8 ** part9)
								initial_outlet_pressure = section_outlet_pressure[gg]
								if section_outlet_pressure[gg] == (section_outlet_pressure[gg-1] unless section_outlet_pressure[gg-1].nil?)
									inlet_presure[m+1] = section_outlet_pressure[gg] - barometric_pressure
									inlet_temperature[m + 1] = section_outlet_temperature[gg] - 459.69
									loop_break = true
								end

								log.info("-------------section_outlet_pressure[gg] = #{section_outlet_pressure[gg]}")
								log.info("-------------section_outlet_pressure[gg-1] = #{section_outlet_pressure[gg-1]}")
								log.info("-------------section_outlet_temperature[gg] = #{section_outlet_temperature[gg]}")
								
								break if loop_break
							end

							#Determine sonic downstream pressure at each fitting along the system
							#Check for choked flow

							p1 = inlet_presure[m]
							p2 = inlet_presure[m+1] unless inlet_presure[m+1].nil?
							fitting_outlet_pressure[k][m] = p2

							(1..1000).each do |r|
								p2critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
								part1 = 2.0 / (vapor_k + 1.0)
								part2 = (((p1 + barometric_pressure) / p2critical) ** ((vapor_k + 1.0) / vapor_k)) - 1.0
								part3 = (2.0 / vapor_k) * Math.log((p1 + barometric_pressure) / p2critical)
								adiabatic_choke_kf = (part1 * part2) - part3
								break if kfi_sum <= adiabatic_choke_kf
							end 

							if (p2critical - barometric_pressure) >= p2 #TODO
								#msg1 = MsgBox("The system is expected to experience choke flow on fitting #" & m & "
								#(" & fitting_type & ").  Do you want to avoid or include this choke condition in this piping design. 
								#Click YES to avoid or click NO to include", vbYesNoCancel, "Choke Flow Detected!")
								#If msg1 = vbYes Then
								#k = k + 1
								#GoTo Line4:
								#elsif msg1 = vbNo Then
								#Notes = "Choke flow experienced in piping design."
								#Else
								#End If           
							end 
						end #end project vapor flow model if
					end #end count loop.

					next if skip_loop_k

					#raise fitting_outlet_pressure.to_yaml

					total_system_pressure_drop[k] = stream_pressure - p2
					fitting_pressure_drop = stream_pressure - p2
					pressure_drop_percentage = ((fitting_pressure_drop / (stream_pressure + barometric_pressure)) * 100.0).round(1)

					log.info("vapor sizing p1 = #{stream_pressure}")
					log.info("pressure pressure_drop_percentage = #{pressure_drop_percentage}")

					system_maximum_deltaP = (total_equivalent_length / system_equivalent_length) * deltaP

					if (total_system_pressure_drop[k] <= system_maximum_deltaP and (total_system_pressure_drop[k-1] >= system_maximum_deltaP unless total_system_pressure_drop[k-1].nil? ))
						proposed_iteration = k if proposed_iteration == 0
					elsif total_system_pressure_drop[k] <= system_maximum_deltaP
						proposed_iteration = k if proposed_iteration == 0
					end

					if nreynolds <= 2000
						flow_regime = "Laminar"
					elsif nreynolds >= 4000
						flow_regime = "Turbulent"
					else
						flow_regime = "Transitional Zone"
					end

					log.info("------------------------------------")
					log.info("flow regime = #{flow_regime}")
					log.info("total system pressure drop[k] = #{total_system_pressure_drop[k]}")
					log.info("total equivalent length = #{total_equivalent_length}")
					log.info("fitting pressure drop = #{fitting_pressure_drop}")
					log.info("prssure drop percentrage = #{pressure_drop_percentage}")
					log.info("system_maximum_deltaP = #{system_maximum_deltaP}")
					log.info("proposed iteration = #{proposed_iteration}")
					log.info("------------------------------------")

				rupture_diameter = pipe_id[k]
				determine_nominal_pipe_size_values = determine_nominal_pipe_size(rupture_diameter)
				proposed_diameter = determine_nominal_pipe_size_values[:proposed_diameter]
				proposed_area= pi* ((proposed_diameter/2.0)**2.0)
				pipe_size = determine_nominal_pipe_size_values[:pipe_size]
				pipe_schedule = determine_nominal_pipe_size_values[:pipe_schedule]
				pipe_d = determine_pipe_diameter(pipe_size, pipe_schedule )  
				um =  (volume_rate * 144.0) / (proposed_area * 3600.0)
				fluid_momentum =  vapor_density *( um ** 2.0)
				fitting_pressure_drop.round(3)
				um.round(2)
				total_equivalent_length.round(1)
				fluid_momentum.round(1)

				iteration = {}
				iteration[:rupture_diameter] = line_sizing.convert_to_project_unit(:sc_required_id,rupture_diameter)
				iteration[:proposed_diameter] = line_sizing.convert_to_project_unit(:sc_proposed_id, proposed_diameter)
				iteration[:pipe_size] = pipe_size
				iteration[:nominal_pipe_size] = PipeSizing.nominal_pipe_diameter[pipe_size.to_f]
				iteration[:pipe_schedule] = pipe_schedule
				iteration[:fitting_pressure_drop] = line_sizing.convert_to_project_unit(:sc_calculated_system_dp,fitting_pressure_drop)
				iteration[:um] = line_sizing.convert_to_project_unit(:sc_calculated_velocity,um)
				iteration[:total_equivalent_length] = line_sizing.convert_to_project_unit(:sc_system_equivalent_length,total_equivalent_length)
				iteration[:pressure_drop_percentage] = pressure_drop_percentage
				iteration[:flow_regime] = flow_regime
				iteration[:erosion_corrosion_index] = line_sizing.convert_to_project_unit(:sc_fluid_momentum,fluid_momentum)
				iteration[:fluid_momentum] = line_sizing.convert_to_project_unit(:sc_fluid_momentum,fluid_momentum)
				iteration[:pipe_d] = pipe_d
				calculated_values[k] = iteration
				end # end for loop 1..334 

				calculated_values[:proposed_iteration] = proposed_iteration

				line_sizing.calculated_results = calculated_values
				proposed = calculated_values[proposed_iteration]

				#Assigning Values to db elements for pipe sizings.
				ps_ids = line_sizing.pipe_sizing_ids

				ps_ids.each_with_index do |ps_id,i|
					ps = PipeSizing.find(ps_id)
					ps.p_outlet = line_sizing.convert_to_project_unit(:pipe_sizing_p_outlet,fitting_outlet_pressure[proposed_iteration][i])
					ps.pipe_schedule = proposed[:pipe_schedule]
					ps.pipe_size = proposed[:pipe_size]
					ps.pipe_id = proposed[:pipe_d]
					ps.save
				end

				#Assignign values to form elements in line sizing.          
				line_sizing.sc_required_id = proposed[:rupture_diameter]
				line_sizing.sc_proposed_id = proposed[:proposed_diameter]
				line_sizing.sc_pipe_size = proposed[:nominal_pipe_size]
				line_sizing.sc_pipe_schedule = proposed[:pipe_schedule]
				line_sizing.sc_calculated_system_dp = proposed[:fitting_pressure_drop]
				line_sizing.sc_calculated_velocity = proposed[:um]
				line_sizing.sc_system_equivalent_length = proposed[:total_equivalent_length]
				line_sizing.sc_pressure_loss_percentage = proposed[:pressure_drop_percentage]
				line_sizing.sc_flow_regime = proposed[:flow_regime]
				line_sizing.sc_erosion_corrosion_index = proposed[:erosion_corrosion_index]
				line_sizing.sc_fluid_momentum = proposed[:fluid_momentum]
				line_sizing.save         

							#end streamphase vapor 
			elsif stream_phase == "two-phase"

				#TODO  If UserFormLineSegmentDesign.optExclude.Value = True Then

				#UserFormBaker.txtTargetBy.Value = Empty
				retry_loop = false

				ql = stream_liquid_flow_rate / liquid_density
				qg = stream_vapor_flow_rate / vapor_density
				qm = ql + qg
				volume_rate = qm

				liquid_resistance = ql / qm
				m_density = (liquid_density * liquid_resistance) + vapor_density * (1.0 - liquid_resistance)
				m_viscosity = (liquid_viscosity * liquid_resistance) + vapor_viscosity * (1.0 - liquid_resistance)

				pipe_sizings = line_sizing.pipe_sizings 
				count = pipe_sizings.size 

				est_area = []
				est_pipe = []
				fitting_pressure_drop = 0
				fitting_pressure_drop1 = []
				current_flow_regime = []
				desired_flow_regime = []
				flow_c = []
				um = []
				total_length = 0
				fluid_momentum = []
				loop_break = 1
				if project.two_phase_flow_model == "Dukler"    
					total_dp = []
					r1 = []

					33.downto(1) do |ppk|

						est_pipe[ppk] = PipeSizing.pipe_size_cycle[ppk-1][:diameter].to_f
						est_area[ppk] = pi * (est_pipe[ppk] / 2.0) ** 2.0
						fitting_pressure_drop1[ppk] = []

						#Determine Vapor and Liquid Superficial Velocity
						vsg = 0.04 * (qg / est_pipe[ppk])
						vsl = 0.04 * (ql / est_area[ppk])
						vm = vsg + vsl

						#Errosion-Corrosion index test
						wl = stream_liquid_flow_rate
						wg = stream_vapor_flow_rate
						pm = (wl + wg) / (ql + qg)
						aec = est_area[ppk] / 144.0

						um[ppk] = (wg / (3600.0 * vapor_density * aec)) + (wl / (3600.0 * liquid_density * aec))
						fluid_momentum[ppk] = pm * um[ppk] ** 2.0

						target_by = params[:target_by]
						if target_by != ""
							target_by = target_by.to_f + 0
						end                 

						desired_flow_regime[ppk] = params[:desired_flow_regime][ppk-1] unless params[:desired_flow_regime][ppk-1].nil?
						desired_flow_regime[ppk] = "" if params[:desired_flow_regime][ppk-1].nil?
						current_flow_regime[ppk] = params[:current_flow_regime][ppk-1] unless params[:current_flow_regime][ppk-1].nil?
						current_flow_regime[ppk] = "" if params[:current_flow_regime][ppk-1].nil?
						flow_c[ppk] = params[:flow_c][ppk-1] unless params[:flow_c][ppk-1].nil?
						flow_c[ppk] = 1 if params[:flow_c][ppk-1].nil? #TODO temp should put validations for not being empty...

						#Determine average local liquid resistance , Rl, liquid hold up or actual resistance of liquid in piping
						#Declarations
						r1[1] = liquid_resistance
						dukler_density = []
						dukler_reynold = []
						dreynolds = 0
						ddensity = 0


						(1..1000).each do |i|
							part1 = (liquid_density * liquid_resistance ** 2.0) / r1[i]
							part2 = (vapor_density * (1 - liquid_resistance) ** 2.0) / (1.0 - r1[i])
							dukler_density[i] = part1 + part2
							dukler_reynold[i] = (dukler_density[i] * vm * (est_pipe[ppk] / 12.0)) / (0.000671969 * m_viscosity)

							if dukler_reynold[i] > 0.2 * 10.0 ** 6.0 #  'to maintain a bubble/froth flow regime and give economical pipe sizes
								r1[i + 1.0] = liquid_resistance
							else
								reynold = dukler_reynold[i]
								liquid_fraction = liquid_resistance
								#TODO #call liquidresist(reynold, liquidfraction, liquidholdup)                  'module 3
								r1[i + 1.0] = 1.0#TODO #liquidholdup
							end

							if r1[i + 1.0] == r1[i]
								dreynolds = dukler_reynold[i]
								ddensity = dukler_density[i]                      
								break
							elsif ((r1[i + 1.0] - r1[i]).abs / r1[i]) * 100.0 < 0.00001
								dreynolds = dukler_reynold[i]
								ddensity = dukler_density[i]
								break
							end

						end #end for loop 1..1000
						#Determine Baker Parameters Bx, By
						wl = stream_liquid_flow_rate
						wg = stream_vapor_flow_rate
						pl = liquid_density
						pg = vapor_density
						ul = liquid_viscosity
						ug = vapor_viscosity
						ol = liquid_surface_tension
						area = pi * ((est_pipe[ppk] / 12.0) / 2.0) ** 2.0  #ft**2

						bx = 531 * (wl / wg) * (((pl * pg) ** 0.5) / (pl ** (2.0 / 3.0))) * (ul ** (1.0 / 3.0) / ol)
						by = 2.16 * (wg / area) * (1.0 / (pl * pg) ** 0.5)


						#TODO server side validations
						if desired_flow_regime == "Slug"
							#msg1 = MsgBox("Slug flow regime should be avoided in the two phase pipe design due to potential liquid hammer issues.", vbInformation, "Slug Flow Regime Identified!")
						elsif desired_flow_regime == "Dispersed/Spray/Mist"
							#msg1 = MsgBox("Mist flow regime should be avoided in the two phase pipe design due to potential phase disengagement issues'", vbInformation, "Mist Flow Regime Identified!")
						end

						#'Determine single phase friction factor
						s = 1.281 + 0.478 * Math.log(liquid_resistance) + 0.444 * (Math.log(liquid_resistance)) ** 2.0 + 0.09399999 * (Math.log(liquid_resistance)) ** 3 + 0.0084330001 * (Math.log(liquid_resistance)) ** 4.0

						#determine two phase friction factor
						ftpr = 1.0 - (Math.log(liquid_resistance) / s)
						fo = 0.0014 + (0.125 / dreynolds ** 0.32)
						ftp = ftpr * fo


						sum_elevation = 0
						length = []
						equivalent_length = []
						elevation = []
						nreynolds = dreynolds
						d = est_pipe[ppk]

						(0..count-1).each do |m|
							cv =  pipe_sizings[m].ds_cv
							dover_d = pipe_sizings[m].ds_cv
							dorifice = pipe_sizings[m].ds_cv
							length[m] = pipe_sizings[m].length
							elevation[m]=pipe_sizings[m].elev
							fd = 4.0 * ftp
							fitting_type = PipeSizing.get_fitting_tag(pipe_sizings[m].fitting_id)[:value]

							if fitting_type == "Pipe"
								kf = 4.0 * ftp * (length[m] / (d / 12.0))
								equivalent_length[m] = length[m]
							elsif fittingtype == "Control Valve"
								kf = ((29.9 * d ** 2.0) / cv) ** 2.0
								equivalent_length[m] = (kf / ftp) * (d / 12.0)
							elsif fittingtype == "Orifice"
								beta = dorifice / d
								kf = (1.0 - beta ** 2.0) / (flow_c[ppk] ** 2.0 * beta ** 4.0)
								equivalent_length[m] = (kf / ftp) * (d / 12.0)
							else
								#Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)                         'module 7
								kf=1
								equivalent_length[m] = (kf / ftp) * (d / 12.0)
							end

							total_length = total_length + equivalent_length[m]


							if elevation[m] > 0
								ht = elevation[m] * -1
							elsif elevation[m] < 0
								ht = elevation[m] * -1
							else
								ht = 0
							end

							sum_elevation += ht  


							omega = 0.76844 - 0.085389 * vsg + 0.0041264 * vsg ** 2 - 0.000087165 * vsg ** 3 + 0.00000066422 * vsg ** 4
							if vsg > 50
								omega = 0.04
							elsif vsg < 0.5
								omega = 0.85
							end
							dpf = 4.0 * (ftp / (144.0 * 32.2)) * (total_length / (est_pipe[ppk] / 12.0)) * m_density * (vm ** 2.0 / 2.0)
							dpe = (omega * pl * sum_elevation) / 144.0                    
							dpa = 0

							#Determine Acceleration Pressure Drop, Initially assume no contribution
							#if dpa = ""
							#dpa = 0
							#end

							#Total Pressure Drop
							total_dp[ppk] = dpf + dpe + dpa
							fitting_pressure_drop1[ppk][m] = total_dp[ppk]
							fitting_pressure_drop = total_dp[ppk]
							fitting_pressure_drop_accelcheck = total_dp[ppk]

						end #end of count loop
						#raise fitting_pressure_drop1[32].to_yaml



						#TODO pressure_loss_percentage not defined
						if(1)# PressureLossPercentage > 10 And Um >= 100 #TODO not defined 
							#TODO check for the units here.
							#UOM = "DifferentialPressure"
							#UOMUnit = UserFormAccelerationPD.lblAccelerationPDUnit
							#UOMValue = FittingPressureDropAccelCheck
							#Call ResultsUnitConversion(UOMUnit, UOMValue, UOM)                  'Module 88
							#FittingPressureDropAccelCheck = UOMValue

							#inlet_pressure = stream_pressure
							#outlet_pressure = inlet_presure - fitting_pressure_drop_accelcheck
							#one more form... check this one too
							#                UserFormAccelerationPD.lblPipeID = EstPipe(ppk)
							#                UserFormAccelerationPD.lblLineNumber = UserFormLineSegmentDesign.txtCalcName
							#                UserFormAccelerationPD.txtPressure = OutletPressure
							#                UserFormAccelerationPD.Show
							#                msg1 = MsgBox("Enter the fluid properties at the estimated outlet pressure.", vbONOnly, "Enter Properties For Acceleration Loss Calculation!")
							#                TPAccelerationDeltaP = UserFormAccelerationPD.lblAccelerationPD
							#                UOM = "DifferentialPressure"
							#                UOMUnit = UserFormLineSegmentDesign.lblCalcDPUnit
							#                UOMValue = TPAccelerationDeltaP
							#                Call UnitConversionCalculation(UOMValue, UOM, UOMUnit)                  'Module 87
							#                TPAccelerationDeltaP = UOMValue

							#               TotalDP(ppk) = TotalDP(ppk) + TPAccelerationDeltaP
						end

						if (current_flow_regime[ppk] != desired_flow_regime[ppk]) || (desired_flow_regime[ppk] == "" && current_flow_regime[ppk] == "")
							next
						else
							#raise ppk.to_yaml
							system_maximum_deltaP = (total_length / system_equivalent_length) * system_maximum_deltaP
							#raise system_maximum_deltaP.to_yaml
							if total_dp[ppk] >= system_maximum_deltaP && (total_dp[ppk+1] <= system_maximum_deltaP unless total_dp[ppk+1].nil?)
								(0..count-1).each do |m|
									fitting_pressure_drop1[ppk][m] = (stream_pressure - fitting_pressure_drop1[ppk][m])
								end
								loop_break = ppk
								break
							elsif total_dp[ppk] >= system_maximum_deltaP
								retry_loop = true
								calculated_values[:retry] = retry_loop
								calculated_values[:ppk] = est_pipe[ppk]
								(0..count-1).each do |m|
									fitting_pressure_drop1[ppk][m] = (stream_pressure - fitting_pressure_drop1[ppk][m])
								end
								loop_break = ppk
								break

							end #end total_dp condition


						end #end flow_regime condition 

					end #end for loop 33..1
					#raise total_dp.to_yaml

				elsif project.two_phase_flow_model == "Lockhart-Martinelli"

					total_system_pressuredrop = []

					33.downto(1) do |ppk|

						est_pipe[ppk] = PipeSizing.pipe_size_cycle[ppk-1][:diameter].to_f
						est_area[ppk] = pi * (est_pipe[ppk] / 2.0) ** 2.0
						fitting_pressure_drop1[ppk] = []

						#Determine Vapor and Liquid Superficial Velocity
						vsg = 0.04 * (qg / est_pipe[ppk])
						vsl = 0.04 * (ql / est_area[ppk])
						vm = vsg + vsl

						#Errosion-Corrosion index test
						wl = stream_liquid_flow_rate
						wg = stream_vapor_flow_rate
						pm = (wl + wg) / (ql + qg)
						aec = est_area[ppk] / 144.0

						um[ppk] = (wg / (3600.0 * vapor_density * aec)) + (wl / (3600.0 * liquid_density * aec))
						fluid_momentum[ppk] = pm * um[ppk] ** 2.0

						target_by = params[:target_by]
						if target_by != ""
							target_by = target_by.to_f + 0
						end                 

						desired_flow_regime[ppk] = params[:desired_flow_regime][ppk-1] unless params[:desired_flow_regime][ppk-1].nil?
						desired_flow_regime[ppk] = "" if params[:desired_flow_regime][ppk-1].nil?
						current_flow_regime[ppk] = params[:current_flow_regime][ppk-1] unless params[:current_flow_regime][ppk-1].nil?
						current_flow_regime[ppk] = "" if params[:current_flow_regime][ppk-1].nil?
						flow_c[ppk] = params[:flow_c][ppk-1] unless params[:flow_c][ppk-1].nil?
						flow_c[ppk] = 1 if params[:flow_c][ppk-1].nil? #TODO temp should put validations for not being empty...


						#Determine Baker Parameters Bx, By
						pl = liquid_density
						pg = vapor_density
						ul = liquid_viscosity
						ug = vapor_viscosity
						ol = liquid_surface_tension
						area_ft2 = pi * ((est_pipe[ppk] / 12.0) / 2.0) ** 2.0  #ft**2

						bx = 531.0 * (wl / wg) * (((pl * pg) ** 0.5) / (pl ** (2.0 / 3.0))) * (ul ** (1.0 / 3.0) / ol)
						by = 2.16 * (wg / area) * (1.0 / (pl * pg) ** 0.5)


						nrel = (pl * vsl * (est_pipe[ppk] / 12.0)) / (0.000671969 * ul)
						nreg = (pg * vsg * (est_pipe[ppk] / 12.0)) / (0.000671969 * ug)

						#determine liquid pressure drop
						#determine new friction factor using churchill's equation
						a = (2.457 * Math.log(1.0 / (((7.0 / nrel) ** 0.9) + (0.27 * (e / est_pipe[ppk]))))) ** 16.0
						b = (37530 / nrel) ** 16.0
						fl = 2.0 * ((8.0 / nrel) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0)

						#determine vapor pressure drop
						#determine new friction factor using churchill's equation
						b = (37530 / nreg) ** 16.0
						fg = 2.0 * ((8.0 / nreg) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0)

						delta_pl_per_length = ((3.36 * 10.0 ** -6.0) * fl * wl ** 2.0) / ((est_pipe[ppk]) ** 5.0 * pl)
						delta_pg_per_length = ((3.36 * 10.0 ** -6.0) * fg * wg ** 2.0) / ((est_pipe[ppk]) ** 5.0 * pg)

						x = (delta_pl_per_length / delta_pg_per_length) ** 0.5

						#determine omega for all flow regime
						stratified_omega = (15400.0 * x) / (wl / area_ft2) ** 0.8
						bubble_froth_omega = (14.2 * x ** 0.75) / (wl / area_ft2) ** 0.1
						slug_omega = (1190.0 * x ** 0.815) / (wl / area_ft2) ** 0.5

						hx = (wl / wg) * (ul / ug)
						fh = exp((0.211 * Math.log(hx)) - 3.993)
						delta_ptp_per_length = ((3.36 * 10.0 ** -6.0) * fh * wg ** 2.0) / ((est_pipe[ppk]) ** 5.0 * pg)

						if est_pipe[ppk] >= 12.0 
							est_pipe[ppk] = 10.0
						end

						aa = 4.8 - 0.3125 * est_pipe[ppk]
						bb = 0.343 - 0.021 * est_pipe[ppk]
						annular_omega = aa * x ** bb

						c0 = 1.4659
						c1 = 0.49138
						c2 = 0.04887
						c3 = -0.000349
						dispersed_spray_mist_omega = Math.exp((c0 + c1 * Math.log(x) + c2 * (Math.log(x)) ** 2.0 + c3 * (Math.log(x)) ** 3.0))
						plug_omega = (27.315 * x ** 0.855) / (wl / area_ft2) ** 0.17

						if flow_regime == "Stratified"
							omega = stratified_omega
						elsif flow_regime == "Bubble/Froth"
							omega = bubble_froth_omega
						elsif flow_regime == "Slug"
							omega = slug_omega
						elsif flow_regime == "Wave"
						elsif flow_regime == "Annular"
							omega = annular_omega
						elsif flow_regime == "Dispersed/Spray/Mist"
							omega = dispersed_spray_mist_omega
						elsif flow_regime == "Plug"
							omega = plug_omega
						end

						if flow_regime != "Wave"
							delta_ptp_per_length = delta_pg_per_length * omega ** 2.0
						end


						est_pipe[ppk] = PipeSizing.pipe_size_cycle[ppk-1][:diameter].to_f


						sum_elevation = 0
						length = []
						equivalent_length = []
						elevation = []

						(0..count-1).each do |m|
							cv =  pipe_sizings[m].ds_cv
							dover_d = pipe_sizings[m].ds_cv
							dorifice = pipe_sizings[m].ds_cv
							length[m] = pipe_sizings[m].length
							elevation[m]=pipe_sizings[m].elev

							fd = 4.0 * fg
							fitting_type = PipeSizing.get_fitting_tag(pipe_sizings[m].fitting_id)[:value]
							nreynolds = nreg
							d = est_pipe[ppk]                

							#check for pipe fittings
							if fitting_type == "Pipe"
								kf = 4.0 * fg * (length[m] / (d / 12.0))
								equivalent_length[m] = length[m]
							elsif fittingtype == "Control Valve"
								kf = ((29.9 * d ** 2.0) / cv) ** 2.0
								equivalent_length[m] = (kf / fg) * (d / 12.0)
							elsif fittingtype == "Orifice"
								beta = dorifice / d
								kf = (1.0 - beta ** 2.0) / (flow_c[ppk] ** 2.0 * beta ** 4.0)
								equivalent_length[m] = (kf / fg) * (d / 12.0)
							else
								#Call ResistanceCoefficient(fittingtype, Nreynolds, d, d1, d2, Kf, Fd, DoverD)                         
								kf=1
								equivalent_length[m] = (kf / ftp) * (d / 12.0)
							end

							total_length += equivalent_length[m]
							tp_horizontal_deltaP = delta_ptp_per_length * total_length

							#'vertical rise component in pressure drop
							fe = (0.00967 * (wl / area_ft2) ** 0.5) / (vsg) ** 0.7

							if elevation(j) > 0 then
								sum_elevation += elevation[m]
							end

							tp_elevation_deltaP = (sum_elevation * fe * pl) / 144.0

							#determine acceleration pressure drop, initially assume no contribution
							tp_acceleration_deltap = 0

							total_system_pressuredrop[ppk] = tp_horizontal_deltaP +tp_elevation_deltaP + tp_acceleration_deltaP
							fitting_pressure_drop1[ppk][m] = total_system_pressuredrop[ppk]
							fitting_pressure_drop = total_system_pressuredrop[ppk]
							fitting_pressure_drop_accelcheck = total_system_pressuredrop[ppk]

						end # count loop 

						#'Determine if pressure drop due to acceleration is required
						inlet_presure = stream_pressure + barometric_pressure
						pressure_loss_percentage = ((fitting_pressure_drop / inlet_presure) * 100).round(1)

						#                        if pressure_loss_percentage > 10 && um[ppk] >= 100

						#                          inlet_presure = stream_pressure
						#                          outlet_pressure = inlet_presure - fitting_pressure_drop_accelcheck

						##1513                    UserFormAccelerationPD.lblPipeID = EstPipe(ppk)
						##1514                    UserFormAccelerationPD.lblLineNumber = UserFormLineSegmentDesign.txtCalcName
						##1515                    UserFormAccelerationPD.txtPressure = OutletPressure
						##1516                    msg1 = MsgBox("Enter the fluid properties at the estimated outlet pressure.", vbONOnly, "Enter Properties For Acceleration Loss Calculation!")
						##1517                    UserFormAccelerationPD.Show
						##1518                    TPAccelerationDeltaP = UserFormAccelerationPD.lblAccelerationPD
						##1519                    UOM = "DifferentialPressure"
						##1520                    UOMUnit = UserFormLineSegmentDesign.lblCalcDPUnit
						##1521                    UOMValue = TPAccelerationDeltaP
						##1522                    Call UnitConversionCalculation(UOMValue, UOM, UOMUnit)                  'Module 87
						# #                        TPAccelerationDeltaP = UOMValue

						# Rough idea on how to approach. 

						#                           #tp_accelerationdeltap = params[:tp_acceleration_deltaP][ppk] unless params[:tp_acceleration_deltaP][ppk].nil?
						#                           #tp_accelerationdeltap = 0 if params[:tp_accelerationdeltap][ppk]
						#                           total_system_pressuredrop[ppk] += tp_acceleration_deltaP
						#                          
						#                        end


						if (current_flow_regime[ppk] != desired_flow_regime[ppk]) || (desired_flow_regime[ppk] == "" && current_flow_regime[ppk] == "")
							next
						else
							system_maximum_deltaP = (total_length / system_equivalent_length) * system_maximum_deltaP
							if total_dp[ppk] >= system_maximum_deltaP && (total_dp[ppk+1] <= system_maximum_deltaP unless total_dp[ppk+1].nil?)
								(0..count-1).each do |m|
									fitting_pressure_drop1[ppk][m] = (stream_pressure - fitting_pressure_drop1[ppk][m])
								end
								loop_break = ppk
								break

							elsif total_dp[ppk] >= system_maximum_deltaP
								retry_loop = true # manipulated a little.
								calculated_values[:retry] = retry_loop
								calculated_values[:ppk] = est_pipe[ppk]
								(0..count-1).each do |m|
									fitting_pressure_drop1[ppk][m] = (stream_pressure - fitting_pressure_drop1[ppk][m])
								end
								loop_break = ppk
								break

							end #end total_dp condition                      

						end #end flow_regime condition 

					end #end for loop 33..1

				end #end IF condition for project.two_phase_flow_model

				#raise loop_break.to_yaml
				rupture_diameter = est_pipe[loop_break]
				determine_nominal_pipe_size_values = determine_nominal_pipe_size(rupture_diameter)
				proposed_diameter = determine_nominal_pipe_size_values[:proposed_diameter]
				pipe_size = determine_nominal_pipe_size_values[:pipe_size]
				pipe_schedule = determine_nominal_pipe_size_values[:pipe_schedule]
				pipe_d = determine_pipe_diameter(pipe_size, pipe_schedule )  



				#Assigning Values to db elements for pipe sizings.
				ps_ids = line_sizing.pipe_sizing_ids
				ps_ids.each_with_index do |ps_id,i|
					ps = PipeSizing.find(ps_id)
					ps.p_outlet = fitting_pressure_drop1[loop_break][i]
					ps.pipe_schedule = pipe_schedule
					ps.pipe_size = pipe_size
					ps.pipe_id = pipe_d
					ps.save
				end

				#Assignign values to form elements in line sizing.          
				line_sizing.sc_required_id = rupture_diameter
				line_sizing.sc_proposed_id = proposed_diameter
				line_sizing.sc_pipe_size = pipe_size
				line_sizing.sc_pipe_schedule = pipe_schedule
				line_sizing.sc_calculated_system_dp = fitting_pressure_drop
				line_sizing.sc_calculated_velocity = um[loop_break]
				line_sizing.sc_system_equivalent_length = total_length
				#todo press loss % not defined
				#line_sizing.sc_pressure_loss_percentage = pressure_drop_percentage
				line_sizing.sc_flow_regime = current_flow_regime[loop_break]
				line_sizing.sc_fluid_momentum = fluid_momentum[loop_break]
				line_sizing.save  

				#1626        If Worksheets("Set Up").chkLockMartinelli.Value = True Then
				#1627            If PressureLossPercentage > 10 Then
				#1628            message1 = "The Lockhart-Martinelli method for bi-phase line sizing is limited to 10% pressure loss per pipe segment.  It may be necessary to segment the pipe run as entered such that the pressure loss in each segment is less than 10% of its respective absolute inlet pressure."
				#1629            msg1 = MsgBox(message1, vbOKOnly, "Pressure Loss Exceed Valid Range For Method!")
				#1630            Notes1 = "Pressure loss for pipe configuration exceeds validity limits of 10% of absolute inlet pressure for Lockhart-Martinelli method."
				#1631            UserFormLineSegmentDesign.lblPressureLossPercentage.BackColor = &H8080FF
				#1632            Else
				#1633            UserFormLineSegmentDesign.lblPressureLossPercentage.BackColor = &H8000000F
				#1634            End If
				#1635        ElseIf Worksheets("Set Up").chkDukler.Value = True Then
				#1636            If PressureLossPercentage > 15 Then
				#1637            message1 = "The homogeneous flow liquid ratio for which the validity of the Dukler bi-phase line sizing method is predicated is valid for up to 15% pressure loss per pipe segment.  It may be necessary to segment the pipe run according such that the pressure loss in each segment is less than 15% of its respective absolute inlet pressure."
				#1638            msg1 = MsgBox(message1, vbOKOnly, "Pressure Loss Exceed Valid Range For Method!")
				#1639            Notes1 = "Pressure loss for pipe configuration exceeds validity limits of 15% of absolute inlet pressure for Dukler method."
				#1640            UserFormLineSegmentDesign.lblPressureLossPercentage.BackColor = &H8080FF
				#1641            Else
				#1642            UserFormLineSegmentDesign.lblPressureLossPercentage.BackColor = &H8000000F
				#1643            End If
				#1644        Else
				#1645        End If

			end # end if stream phase vapor liquid biphase conditions

		render :json => calculated_values     
	end #end get send_calc_request1

	# Get_flow_regime 
	def get_flow_regime
		flow_regime_values = {}
		line_sizing = LineSizing.find(params[:line_sizing_id])


		#pipe_no = params[:pipe_no]
		#pipe_no = 1 if params[:pipe_no].nil?

		stream_vapor_fraction = line_sizing.vapour_fraction
		stream_flow_rate = line_sizing.flowrate
		liquid_density = line_sizing.liquid_density
		vapor_density = line_sizing.vapor_density
		liquid_viscosity = line_sizing.liquid_viscosity
		liquid_surface_tension = line_sizing.liquid_surface_tension

		stream_liquid_flow_rate = stream_flow_rate * (1 - stream_vapor_fraction);
		stream_vapor_flow_rate = stream_flow_rate * stream_vapor_fraction;

		result_flow_regime = calc_flow_regime_values(stream_liquid_flow_rate,stream_vapor_flow_rate,liquid_density,vapor_density,liquid_viscosity,liquid_surface_tension)

		flow_regime_values[:process_basis]= line_sizing.process_basis_id
		flow_regime_values[:stream_no]=line_sizing.stream_no
		flow_regime_values[:vapor_superficial_density]=result_flow_regime[:vapor_superficial_density]
		flow_regime_values[:liquid_superficial_density]=result_flow_regime[:liquid_superficial_density]
		flow_regime_values[:errosion_index]=result_flow_regime[:errosion_index]
		flow_regime_values[:bx]=result_flow_regime[:bx]
		flow_regime_values[:by]=result_flow_regime[:by]
		flow_regime_values[:pipe_id]=result_flow_regime[:pipe_id]

		#raise flow_regime_values.to_yaml


		respond_to do |format|
			format.json {render :json => flow_regime_values}     
		end
	end

	def set_breadcrumbs
		super
		@breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
		@breadcrumbs << { :name => 'Line sizings', :url => admin_line_sizings_path }
	end

	def liquid_diameter_calc(liquid_viscosity, liquid_density, stream_pressure,  system_maximum_deltaP, system_equivalent_length, stream_flow_rate, pi, pipe_roughness)
		f = (0..10000).to_a
		nre = (0..10000).to_a
		alpha = (0..10000).to_a
		pipe_id = (-1..10000).to_a
		kfi = (0..10000).to_a
		elev = (0..10000).to_a
		flow_rate = (0..10000).to_a

		pressure_energy = (- system_maximum_deltaP / liquid_density) * 144

		potential_energy = 0

		work_done_w = 0

		heat_input_q = 0

		driving_force = -(pressure_energy + potential_energy + work_done_w + heat_input_q)

		volume_rate = stream_flow_rate / liquid_density
		proposed_diameter = 0

		nre[0] = ((1.03892 * (10.0 ** 9.0) * driving_force * (liquid_density ** 5.0) * (volume_rate ** 3.0)) / ((system_equivalent_length * (liquid_viscosity ** 5.0))) ** (1.0 / 5.0))    
		pipe_id[0] = (6.316 * volume_rate * liquid_density) / (liquid_viscosity * nre[0]) 

		(1..100).each do |k|
			kfisum = 0
			sum_elevation = 0

			length = system_equivalent_length
			nre[k - 1] = (6.316 * stream_flow_rate) / (pipe_id[k - 1] * liquid_viscosity)

			#Determine new friction factor using Churchill's equation
			a = (2.457 * Math.log(1.0 / (((7.0 / nre[k - 1.0]) ** 0.9) + (0.27 * (pipe_roughness / pipe_id[k - 1.0]))))) ** 16.0
			b = (37530.0 / nre[k - 1.0]) ** 16.0
			f[k] = 2.0 * ((8.0 / nre[k - 1.0]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0)

			nreynolds = nre[k - 1]
			d = pipe_id[k - 1]
			kf = 4.0 * f[k] * (length / (pipe_id[k - 1.0] / 12.0))  #fitting is straight pipe
			kfisum = kfisum + kf

			#Determine new diameter
			pipe_id[k] = 12.0 * (((1.94393 * 10.0 ** -9) * volume_rate ** 2.0 * kfisum) / driving_force) ** (1.0 / 4.0)
			proposed_diameter = pipe_id[k]

			if pipe_id[k - 1] = pipe_id[k]
				proposed_diameter = pipe_id[k - 1]
				k = 100
			else

			end        
		end

		{:proposed_diameter => proposed_diameter, :volume_rate => volume_rate}

	end 

	def vapor_diameter_calc(vapor_k, vapor_mw, stream_temperature, stream_flow_rate, vapor_viscosity, vapor_density, pipe_roughness, stream_pressure, system_maximum_deltaP, system_equivalent_length, project, pi)

		f = (0..10000).to_a
		nre = (0..10000).to_a
		alpha = (0..10000).to_a
		pipe_id = (-1..10000).to_a
		kfi = (0..10000).to_a
		elev = (0..10000).to_a
		relief_flow_rate = (0..10000).to_a
		g = (0..10000).to_a
		area = (0..10000).to_a
		nma1 = (0..10000).to_a

		proposed_diameter = 0
		volume_rate = 0

		#Assume Sonic Flow
		nma1[0] = 1
		g[0] = 519.5 * nma1[0] * pi * ((vapor_k * vapor_mw) / (stream_temperature + 459.57)) ** 0.5

		(1..100).each do |k|
			pipe_id[k] = 1.12838 * (stream_flow_rate / g[k - 1]) ** 0.5
			area[k] = pi * (pipe_id[k] / 2.0) ** 2.0
			relief_flow_rate[0] = g[k - 1.0] * area[k]
			nre[k] = (4.96055 * pipe_id[k] * g[k - 1]) / vapor_viscosity

			kfisum = 0
			#Determine new friction factor using Churchill's equation       
			begin
				i = Math.log(1.0 / (((7.0 / nre[k]) ** 0.9) + (0.27 * (pipe_roughness / pipe_id[k]))))
			rescue RangeError
				i = 1.0
			end
			a = (2.457 * i) ** 16.0
			b = (37530 / nre[k]) ** 16.0
			f[k] = 2.0 * ((8.0 / nre[k]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0)
			fd = 4.0 * f[k]
			nreynolds = nre[k]
			d = pipe_id[k]

			length = system_equivalent_length
			kf = 4.0 * f[k] * (length / ( pipe_id[k] / 12.0)) #Fitting is straight pipe
			kfisum = kfisum + kf

			#Check for choked flow
			p2 = stream_pressure - system_maximum_deltaP
			p2critircal = 0.0

			if project.vapor_flow_model == "Isothermic" #As defined in project set up page
				(1..1000).each do |r|
					p2critircal = stream_pressure - ((0.001 * r) * stream_pressure)
					part1 = (stream_pressure / p2critircal) ** 2.0
					part2 = 2 *  Math.log(stream_pressure / p2critircal) #Log is a natural log function (aka LN())
					isothermal_choke_kf = part1 - part2 - 1.0
					break if kfisum == isothermal_choke_kf
				end
			elsif project.vapor_flow_model == "Adiabatic"
				(1..1000).each do |r|
					p2critircal = stream_pressure - ((0.001 * r) * stream_pressure)
					part1 = 2.0 / (vapor_k + 1.0)
					part2 = ((stream_pressure / p2critircal) ** ((vapor_k + 1.0) / vapor_k)) - 1.0
					part3 = (2.0 / vapor_k) * Math.log(stream_pressure / p2critircal)
					adiabatic_choke_kf = (part1 * part2) - part3
					break if kfisum == adiabatic_choke_kf
				end
			end

			if project.vapor_flow_model == "Isothermic"  #As defined in project set up page
				if p2critircal > p2 
					part1 = stream_pressure * (p2critircal / stream_pressure)
					part2 = (vapor_mw / (stream_temperature + 459.69)) ** 0.5
					gcritical = 519.5 * part1 * part2
					g[k] = gcritical
				else
					part1 = (134933 * vapor_mw * (stream_pressure ** 2 - p2 ** 2)) / (stream_temperature + 459.67)
					part2 = kfisum / 2
					part3 = Math.log(stream_pressure / p2)
					g[k] = (part1 / (part2 + part3)) ** 0.5
				end
			elsif project.vapor_flow_model == "Adiabatic"
				if p2critircal > p2
					part1 = ((1 / (6.443 * 10 ** 11)) * vapor_k * vapor_mw) / (stream_temperature + 459.69)
					part2 = (p2critircal / stream_pressure) ** ((vapor_k + 1) / vapor_k)
					gcritical = (4.16975 * 10 ** 8) * stream_pressure * (part1 * part2) ** 0.5
					g[k] = gcritical
				else
					part1 = vapor_k / (vapor_k + 1)
					part2 = (269866 * (stream_pressure ** 2 * vapor_mw) / (stream_temperature + 459.67))
					part3 = 1 - ((p2 / stream_pressure) ** ((vapor_k + 1) / vapor_k))
					part4 = kfisum / 2
					part5 = (Math.log(stream_pressure / p2)) / vapor_k
					g[k] = ((part1 * part2 * part3) / (part4 + part5)) ** (0.5)
				end         
			end  

			pipe_id[k] = 1.12838 * (stream_flow_rate / g[k]) ** 0.5

			if pipe_id[k] = pipe_id[k - 1]
				proposed_diameter = pipe_id[k]
				k = 100
			elsif pipe_id[k] = pipe_id[k - 2]
				proposed_diameter = pipe_id[k]
				k = 100
			end

			volume_rate = stream_flow_rate / vapor_density 
		end

		{:proposed_diameter => proposed_diameter, :volume_rate => volume_rate}   
	end

	def two_phase_diameter_calc(stream_liquid_flow_rate, stream_vapor_flow_rate, liquid_density, vapor_density, liquid_viscosity, vapor_viscosity, liquid_surface_tension, system_maximum_deltaP, system_equivalent_length, stream_pressure, process_basis, stream_no, pi, pipe_roughness, project)

		est_pipe = (1..100).to_a
		est_area = (1..100).to_a
		r1 = (1..100).to_a
		dukler_density = (1..100).to_a
		dukler_reynold = (1..100).to_a

		#Determine volumetric flow rate
		ql = stream_liquid_flow_rate / liquid_density
		qg = stream_vapor_flow_rate / vapor_density
		qm = ql + qg
		volume_rate = qm

		#Determine liquid inlet resistance and physical properties
		liquid_resistance = ql / qm
		m_density = (liquid_density * liquid_resistance) + vapor_density * (1 - liquid_resistance)
		m_viscosity = (liquid_viscosity * liquid_resistance) + vapor_viscosity * (1 - liquid_resistance)

		proposed_diameter = 0 #TODO defined variable
		vm = 0

		#Determine initial pipe diameter guess
		(1..30).each do |ppk|
			#est_pipe[ppk] = Worksheets("Preliminary Size - Entry").Cells(34 - ppk, 46).Value   #replace with code to select pipe sizes starting with biggest to smallest.  Pipe sizes needs to be in inches.
			#raise PipeSizing.pipe_size_cycle[ppk-1].to_yaml
			est_pipe[ppk] = PipeSizing.pipe_size_cycle[ppk-1][:diameter].to_f
			#Line1:
			est_area[ppk] = pi * (est_pipe[ppk] / 2) ** 2

			#Determine Vapor and Liquid Superficial Velocity
			vsg = 0.04 * (qg / est_area[ppk])
			vsl = 0.04 * (ql / est_area[ppk])
			vm = vsg + vsl

			#Errosion-Corrosion index test
			wl = stream_liquid_flow_rate
			wg = stream_vapor_flow_rate
			pm = (wl + wg) / (ql + qg)
			aec = est_area[ppk] / 144

			um = (wg / (3600 * vapor_density * aec)) + (wl / (3600 * liquid_density * aec))
			fluid_momentum = pm * um ** 2
			if (pm * um ** 2) <= 10000
				#UserFormBaker.lblErrosionIndex.BackColor = &H8000000F     'Color is no color
				#UserFormFlowRegime.lblECIndex.BackColor = &H8000000F      'Color is no color
				#UserFormLineSegmentDesign.lblErrosionIndex.BackColor = &H8000000F   'Color is no color
				notes = "Errosion-corrosion is unlikely."
			else
				#msg2 = MsgBox("The errosion index exceeds the recommended level.  Errosion-corrosion may be significant at this velocity and pipe size.", vbInformation, "Errosion-corrosion warning!")
				#notes = "At an index of " + (pm * um ** 2).to_i + ", errosion-corrosion is likely at the proposed pipe size."
				#UserFormBaker.lblErrosionIndex.BackColor = &H8080FF       'Color is red
				#UserFormFlowRegime.lblECIndex.BackColor = &H8080FF        'Color is red
				#UserFormLineSegmentDesign.lblErrosionIndex.BackColor = &H8080FF   'Color is red
			end

			#UserFormBaker.lblErrosionIndex = Round(Pm * Um ** 2, 0)
			#UserFormFlowRegime.lblECIndex = Round(Pm * Um ** 2, 0)
			#UserFormLineSegmentDesign.lblErrosionIndex = Round(Pm * Um ** 2, 0)

			#Determine average local liquid resistance , Rl, liquid hold up or actual resistance of liquid in piping
			r1[1] = liquid_resistance

			(1..100).each do |i|
				part1 = (liquid_density * liquid_resistance ** 2) / r1[i]
				part2 = (vapor_density * (1 - liquid_resistance) ** 2) / (1 - r1[i])
				dukler_density[i] = part1 + part2
				dukler_reynold[i] = (dukler_density[i] * vm * (est_pipe[ppk] / 12)) / (0.000671969 * m_viscosity)

				if dukler_reynold[i] > 0.2 * 10 ** 6 #To maintain a bubble/froth flow regime and give economical pipe sizes
					r1[i + 1] = liquid_resistance
				else
					reynold = dukler_reynold[i]
					liquid_fraction = liquid_resistance
					liquid_hold_up = liquid_resist(reynold, liquid_fraction)           
					r1[i + 1] = liquid_hold_up
				end

				if r1[i + 1] = r1[i]
					dreynolds = dukler_reynold[i]
					ddensity = dukler_reynold[i]
					i = 100         
				end
			end

			#Flow regime test
			#Determine Baker Parameters Bx, By
			wl = stream_liquid_flow_rate
			wg = stream_vapor_flow_rate
			pl = liquid_density
			pg = vapor_density
			ul = liquid_viscosity
			ug = vapor_viscosity
			ol = liquid_surface_tension
			area = pi * ((est_pipe[ppk] / 12) / 2) ** 2  #ft**2

			bx = 531 * (wl / wg) * (((pl * pg) ** 0.5) / (pl ** (2 / 3))) * (ul ** (1 / 3) / ol)
			by = 2.16 * (wg / area) * (1 / (pl * pg) ** 0.5)

			target_by = params[:target_by]
			if target_by != ""
				target_by = target_by.to_f + 0
			end

			if target_by = "" || target_by = 0 || target_by <= by
				#UserFormFlowRegime.lblBx = Round(bx, 0)
				#UserFormFlowRegime.lblBy = Round(by, 0)
				#UserFormFlowRegime.lblLiquidVelocity = Round(VsL, 2)
				#UserFormFlowRegime.lblVaporVelocity = Round(Vsg, 2)
				#UserFormFlowRegime.lblProcessBasis = ProcessBasis
				#UserFormFlowRegime.lblStreamNo = StreamNo
				#UserFormFlowRegime.lblPipeID = EstPipe(ppk)
				#UserFormFlowRegime.cmbFlowRegime = Empty

				if est_pipe[ppk] <= 2.469 && bx < 125
					#UserFormFlowRegime.cmbDesiredlFlowRegime = "Dispersed/Spray/Mist"
				elsif est_pipe[ppk] > 2.469 && bx < 125
					#UserFormFlowRegime.cmbDesiredlFlowRegime = "Annular"
				elsif est_pipe[ppk] > 2.469 && bx >= 125
					#UserFormFlowRegime.cmbDesiredlFlowRegime = "Bubble/Froth"
				else
					#UserFormFlowRegime.cmbDesiredlFlowRegime = ""
				end

				#UserFormFlowRegime.lblCalcType = "Proposed"
				#UserFormFlowRegime.Show  #TODO RETURN AJAX REQUESET AND SHOW POPUP
				flow_regime = params[:current_flow_regime]
				desired_flow_regime = params[:desired_flow_regime]
			else
				flow_regime = ""
			end

			if flow_regime == "Slug"
				#msg1 = MsgBox("Slug flow regime should be avoided in the two phase pipe design due to potential liquid hammer issues.", vbInformation, "Slug Flow Regime Identified!")
			elsif flow_regime == "Dispersed/Spray/Mist"
				#msg1 = MsgBox("Mist flow regime should be avoided in the two phase pipe design due to potential phase disengagement issues'", vbInformation, "Mist Flow Regime Identified!")
			else
			end

			if project.two_phase_flow_model == "Dukler"
				#Determine single phase friction factor
				s = 1.281 + 0.478 * Math.log(liquid_resistance) + 0.444 * (Math.log(liquid_resistance)) ** 2 + 0.09399999 * (Math.log(liquid_resistance)) ** 3 + 0.0084330001 * (Math.log(liquid_resistance)) ** 4
				#Determine two phase friction factor
				ftpr = 1 - (Math.log(liquid_resistance) / s)
				fo = 0.0014 + (0.125 / dreynolds ** 0.32)
				ftp = ftpr * fo

				#Determine Frictional pressure drop using a 100 ft horizontal pipe basis
				length = system_equivalent_length
				dpf = 4 * (ftp / (144 * 32.2)) * (length / ( est_pipe[ppk] / 12)) * m_density * (vm ** 2 / 2)

				#Determine Elevation Pressure Drop, Assumed no elevation for preliminary sizing
				dpe = 0

				#Determine Acceleration Pressure Drop, Assumed no contribution
				dpa = 0

				#Total Pressure Drop
				total_dp = dpf + dpe + dpa
			elsif project.two_phase_flow_model == "Lockhart-Martinelli" #From project
				areaft2 = pi * ((est_pipe[ppk] / 12) / 2) ** 2 #ft**2
				nrel = (pl * vsl * (est_pipe[ppk] / 12)) / (0.000671969 * ul)
				nreg = (pg * vsl * (est_pipe[ppk] / 12)) / (0.000671969 * ug)
				#Determine Liquid Pressure Drop
				#'Determine new friction factor using Churchill's equation
				a = (2.457 * Math.log(1 / (((7 / nrel) ** 0.9) + (0.27 * (pipe_roughness / est_pipe[ppk]))))) ** 16
				b = (37530 / nrel) ** 16
				fl = 2 * ((8 / nrel) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)

				#Determine Vapor Pressure Drop
				#Determine new friction factor using Churchill's equation
				a = (2.457 * Math.log(1 / (((7 / nreg) ** 0.9) + (0.27 * (pipe_roughness / est_pipe[ppk]))))) ** 16
				b = (37530 / nreg) ** 16
				fg = 2 * ((8 / nreg) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)

				delta_pl_per_length = ((3.36 * 10 ** -6) * fl * wl ** 2) / ((est_pipe[ppk]) ** 5 * pl)
				delta_pg_per_length = ((3.36 * 10 ** -6) * fg * wg ** 2) / ((est_pipe[ppk]) ** 5 * pg)

				x = (delta_pl_per_length / delta_pg_per_length) ** 0.5

				#Determine Omega for all flow regime
				stratified_omega = (15400 * x) / (wl / areaft2) ** 0.8
				bubblefroth_omega = (14.2 * x ** 0.75) / (wl / areaft2) ** 0.1
				slug_omega = (1190 * x ** 0.815) / (wl / areaft2) ** 0.5

				hx = (wl / wg) * (ul / ug)
				fh = Math.exp((0.211 * Math.log(hx)) - 3.993)
				delta_ptp_per_length = ((3.36 * 10 ** -6) * fh * wg ** 2) / ((est_pipe[ppk]) ** 5 * pg)

				if est_pipe[ppk] >= 12
					est_pipe[ppk] = 10
				else
				end

				aa = 4.8 - 0.3125 * est_pipe[ppk]
				bb = 0.343 - 0.021 * est_pipe[ppk]
				annular_omega = aa * x ** bb
				c0 = 1.4659
				c1 = 0.49138
				c2 = 0.04887
				c3 = -0.000349
				dispersed_spray_mist_omega = Math.exp((c0 + c1 * Math.log(x) + c2 * (Math.log(x)) ** 2 + c3 * (Math.log(x)) ** 3))
				plug_omega = (27.315 * x ** 0.855) / (wl / areaft2) ** 0.17

				#Determine Omega for select flow regime
				if flow_regime == "Stratified"
					omega = stratified_omega
				elsif flow_regime == "Bubble/Froth"
					omega = bubble_froth_omega
				elsif flow_regime == "Slug"
					omega = slug_omega
				elsif flow_regime == "Wave"
				elsif flow_regime == "Annular"
					omega = annular_omega
				elsif flow_regime == "Dispersed/Spray/Mist"
					omega = dispersed_spray_mist_omega
				elsif flow_regime == "Plug"
					omega = plug_omega
				else
				end

				if flow_regime != "Wave"
					delta_ptp_per_length = delta_pg_per_length * omega ** 2
				else
				end

				#est_pipe[ppk] = Worksheets("Preliminary Size - Entry").Cells(34 - ppk, 46).Value
				#Determine Frictional pressure drop using a 100 ft horizontal pipe basis
				length = system_equivalent_length
				tp_horizontal_deltap = delta_ptp_per_length * length

				#Determine Elevation Pressure Drop, Assumed no elevation for preliminary sizing
				tp_elevation_deltap = 0

				#Total Pressure Drop
				total_dp = tp_horizontal_deltap + tp_elevation_deltap
			else
			end

			desired_flow_regime = "" #TODO Required to modified 
			if flow_regime != desired_flow_regime
				ppk = ppk + 1
				#GoTo Line1
				#TODO should be next... wrongly coded.
			else
				proposed_diameter = est_pipe[ppk]
				actual_dp = total_dp
				ppk = 30
			end
			proposed_diameter = est_pipe[ppk] #TODO Required to modified


			#UOM = "DifferentialPressure"
			#UOMUnit = UserFormLineSegmentDesign.lblSystemDPUnit
			#UOMValue = ActualDP
			#Call ResultsUnitConversion(UOMUnit, UOMValue, UOM)       ''Run through whatever function you have to    convert back &truncate variables back to 
			#ActualDP = UOMValue
			actual_dp = 1 #TODO

			#Pressure drop test
			if system_maximum_deltaP != '' || system_maximum_deltaP != 0
				if actual_dp >= system_maximum_deltaP
					#actual_dp_unit = UserFormLineSegmentDesign.lblSystemDPUnit
					#Msg4 = MsgBox("At the proposed internal pipe diameter of " & ProposedDiameter & " inches, the calculated  pressure drop of " & Round(ActualDP, 2) & " " & ActualDPUnit & " exceeds the maximum allowable pressure   drop per 100 ft (or 30.5 m) specified for this stream.  If the maximum allowable pressure drop is   governing, the user should further consider the flow regime target.  Do you want to redo this calculation?    Otherwise, this violation will be noted in the calculations notes.", vbYesNo, "Excessive Pressure Drop  Calculated")
					#if Msg4 = vbYes
					#ppk = 1
					#UserFormLineSegmentDesign.txtNotes = ""
					#UserFormBaker.txtTargetBy.Value = ""
					#GoTo Line1
					#else
					#UserFormLineSegmentDesign.txtNotes = Notes & " Calculated Delta P of " & Round(ActualDP, 2) & " " &     ActualDPUnit & " at proposed diameter exceeds max specified of " & DeltaP & " " & ActualDPUnit &    "."
					#end
				else
				end
			else
			end    
		end

		{:proposed_diameter => proposed_diameter, :volume_rate => volume_rate, :vm => vm} #TODO some addition params is their
	end

	def liquid_resist(reynold, liquid_fraction)
		reynold = 1000 #TODO need fixed again.. for testing purpose
		if reynold == 100
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 85.204 * liquid_fraction + 0.3208
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 14.749 * liquid_fraction + 0.5307
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1 
				liquid_hold_up = 488.66 * liquid_fraction ** 3 - 90.128 * liquid_fraction ** 2 + 5.2677 * liquid_fraction + 0.6408
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1 
				liquid_hold_up = 0.2652 * liquid_fraction + 0.7355
			end     
		elsif reynold == 500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 53.211 * liquid_fraction + 0.1086
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01 
				liquid_hold_up = 14.749 * liquid_fraction + 0.2157
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 905.47 * liquid_fraction ** 3 - 190.87 * liquid_fraction ** 2 + 13.668 * liquid_fraction + 0.2515
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.4267 * liquid_fraction + 0.5734
			end
		elsif reynold == 1000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 57.845 * liquid_fraction + 0.0127       
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 11.917 * liquid_fraction + 0.1617
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 841.37 * liquid_fraction ** 3 - 167.81 * liquid_fraction ** 2 + 12.109 * liquid_fraction + 0.1709
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.5075 * liquid_fraction + 0.4923
			end
		elsif reynold == 2500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 25.76 * liquid_fraction + 0.0238
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 18.807 * liquid_fraction + 0.0437
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 734.68 * liquid_fraction ** 3 - 109.56 * liquid_fraction ** 2 + 6.6302 * liquid_fraction + 0.1729
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.5708 * liquid_fraction + 0.4304
			end
		elsif reynold == 5000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 27.792 * liquid_fraction - 0.0028
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 14.686 * liquid_fraction + 0.0324
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 1141.8 * liquid_fraction ** 3 - 191.16 * liquid_fraction ** 2 + 10.832 * liquid_fraction + 0.0917
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.6341 * liquid_fraction + 0.3685
			end
		elsif reynold == 10000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 21.267 * liquid_fraction - 0.0071
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 13.392 * liquid_fraction + 0.0123
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 1084.9 * liquid_fraction ** 3 - 184.32 * liquid_fraction ** 2 + 10.577 * liquid_fraction + 0.0706
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.6744 * liquid_fraction + 0.3279
			end
		elsif reynold == 25000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 10.701 * liquid_fraction - 0.0014
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 9.0946 * liquid_fraction + 0.0042
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 501.4 * liquid_fraction ** 3 - 105.07 * liquid_fraction ** 2 + 8.159 * liquid_fraction + 0.0214
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.7805 * liquid_fraction + 0.2204
			end
		elsif reynold == 50000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 10.263 * liquid_fraction - 0.0091
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 5.9438 * liquid_fraction + 0.0017
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 43.376 * liquid_fraction ** 3 - 17.429 * liquid_fraction ** 2 + 3.4135 * liquid_fraction + 0.0306
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.8463 * liquid_fraction + 0.1535
			end
		elsif reynold == 100000
			if liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 2.7049 * liquid_fraction + 0.0033
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 481.29 * liquid_fraction ** 3 - 79.931 * liquid_fraction ** 2 + 5.4056 * liquid_fraction - 0.0165
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.8926 * liquid_fraction + 0.1064
			end
		elsif reynold == 200000
			if liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 1.3135 * liquid_fraction + 0.0035
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.9686 * liquid_fraction + 0.0307
			end
		elsif reynold >= 0.2 * 10 ** 6
			liquid_hold_up = liquid_fraction
		else
			liquid_hold_up = intermediate_hold_up(liquid_fraction, reynold)
		end

		return liquid_hold_up
	end

	def intermediate_hold_up(liquid_fraction, reynold)    
		if reynold > 100 && reynold < 500
			low_reynold = 100
			high_reynold = 500
		elsif reynold > 500 && reynold < 1000
			low_reynold = 500
			high_reynold = 1000
		elsif reynold > 1000 && reynold < 2500
			low_reynold = 1000
			high_reynold = 2500
		elsif reynold > 2500 && reynold < 5000
			low_reynold = 2500
			high_reynold = 5000
		elsif reynold > 5000 && reynold < 10000
			low_reynold = 5000
			high_reynold = 10000
		elsif reynold > 10000 && reynold < 25000
			low_reynold = 10000
			high_reynold = 25000
		elsif reynold > 25000 && reynold < 50000
			low_reynold = 25000
			high_reynold = 50000
		elsif reynold > 50000 && reynold < 100000
			low_reynold = 50000
			high_reynold = 100000
		elsif reynold > 100000 && reynold < 200000
			low_reynold = 100000
			high_reynold = 200000
		end

		high_liquid_hold_up = high_reynold_calc(liquid_fraction, high_reynold)
		low_liquid_hold_up = low_reynold_calc(liquid_fraction, low_reynold)   
		slope = (high_liquid_hold_up - low_liquid_hold_up) / (high_reynold - low_reynold)
		interception = high_liquid_hold_up - (slope * high_reynold)
		liquid_hold_up = (slope * reynold) + interception
		return liquid_hold_up
	end

	def high_reynold_calc(liquid_fraction, high_reynold)
		high_liquid_hold_up = 0;
		if high_reynold == 100
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 85.204 * liquid_fraction + 0.3208
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 14.749 * liquid_fraction + 0.5307
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 488.66 * liquid_fraction ** 3 - 90.128 * liquid_fraction ** 2 + 5.2677 * liquid_fraction + 0.6408
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.2652 * liquid_fraction + 0.7355
			end
		elsif high_reynold == 500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 53.211 * liquid_fraction + 0.1086
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 14.749 * liquid_fraction + 0.2157
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 905.47 * liquid_fraction ** 3 - 190.87 * liquid_fraction ** 2 + 13.668 * liquid_fraction + 0.2515
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.4267 * liquid_fraction + 0.5734
			end
		elsif high_reynold == 1000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 57.845 * liquid_fraction + 0.0127
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 11.917 * liquid_fraction + 0.1617
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 841.37 * liquid_fraction ** 3 - 167.81 * liquid_fraction ** 2 + 12.109 * liquid_fraction + 0.1709
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.5075 * liquid_fraction + 0.4923
			end
		elsif high_reynold == 2500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 25.76 * liquid_fraction + 0.0238
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 18.807 * liquid_fraction + 0.0437
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 734.68 * liquid_fraction ** 3 - 109.56 * liquid_fraction ** 2 + 6.6302 * liquid_fraction + 0.1729
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.5708 * liquid_fraction + 0.4304
			end
		elsif high_reynold == 5000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 27.792 * liquid_fraction - 0.0028
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 14.686 * liquid_fraction + 0.0324
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 1141.8 * liquid_fraction ** 3 - 191.16 * liquid_fraction ** 2 + 10.832 * liquid_fraction + 0.0917
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.6341 * liquid_fraction + 0.3685
			end
		elsif high_reynold == 10000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 21.267 * liquid_fraction - 0.0071
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 13.392 * liquid_fraction + 0.0123
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 1084.9 * liquid_fraction ** 3 - 184.32 * liquid_fraction ** 2 + 10.577 * liquid_fraction + 0.0706
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.6744 * liquid_fraction + 0.3279
			end
		elsif high_reynold == 25000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 10.701 * liquid_fraction - 0.0014
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 9.0946 * liquid_fraction + 0.0042
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 501.4 * liquid_fraction ** 3 - 105.07 * liquid_fraction ** 2 + 8.159 * liquid_fraction + 0.0214
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.7805 * liquid_fraction + 0.2204
			end
		elsif high_reynold == 50000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 10.263 * liquid_fraction - 0.0091
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 5.9438 * liquid_fraction + 0.0017
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 43.376 * liquid_fraction ** 3 - 17.429 * liquid_fraction ** 2 + 3.4135 * liquid_fraction + 0.0306
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.8463 * liquid_fraction + 0.1535
			end
		elsif high_reynold == 100000
			if liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 2.7049 * liquid_fraction + 0.0033
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 481.29 * liquid_fraction ** 3 - 79.931 * liquid_fraction ** 2 + 5.4056 * liquid_fraction - 0.0165
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.8926 * liquid_fraction + 0.1064
			end
		elsif high_reynold == 200000
			if liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 1.3135 * liquid_fraction + 0.0035
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.9686 * liquid_fraction + 0.0307
			end
		elsif high_reynold >= 0.2 * 10 ** 6
			high_liquid_hold_up = liquid_fraction
		end

		return high_liquid_hold_up
	end

	def low_reynold_calc(liquid_fraction, low_reynold)
		low_reynold = low_reynold.to_f
		low_liquid_hold_up = 0
		if low_reynold == 100
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 85.204 * liquid_fraction + 0.3208
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 14.749 * liquid_fraction + 0.5307
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 488.66 * liquid_fraction ** 3 - 90.128 * liquid_fraction ** 2 + 5.2677 * liquid_fraction + 0.6408
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.2652 * liquid_fraction + 0.7355
			end
		elsif low_reynold == 500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 53.211 * liquid_fraction + 0.1086        
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 14.749 * liquid_fraction + 0.2157
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 905.47 * liquid_fraction ** 3 - 190.87 * liquid_fraction ** 2 + 13.668 * liquid_fraction + 0.2515
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.4267 * liquid_fraction + 0.5734
			end
		elsif low_reynold == 1000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 57.845 * liquid_fraction + 0.0127
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 11.917 * liquid_fraction + 0.1617
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 841.37 * liquid_fraction ** 3 - 167.81 * liquid_fraction ** 2 + 12.109 * liquid_fraction + 0.1709
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.5075 * liquid_fraction + 0.4923
			end
		elsif low_reynold == 2500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 25.76 * liquid_fraction + 0.0238
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 18.807 * liquid_fraction + 0.0437
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 734.68 * liquid_fraction ** 3 - 109.56 * liquid_fraction ** 2 + 6.6302 * liquid_fraction + 0.1729
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.5708 * liquid_fraction + 0.4304
			end
		elsif low_reynold == 5000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 27.792 * liquid_fraction - 0.0028
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 14.686 * liquid_fraction + 0.0324
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 1141.8 * liquid_fraction ** 3 - 191.16 * liquid_fraction ** 2 + 10.832 * liquid_fraction + 0.0917
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.6341 * liquid_fraction + 0.3685
			end
		elsif low_reynold == 10000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 21.267 * liquid_fraction - 0.0071
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 13.392 * liquid_fraction + 0.0123
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 1084.9 * liquid_fraction ** 3 - 184.32 * liquid_fraction ** 2 + 10.577 * liquid_fraction + 0.0706
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.6744 * liquid_fraction + 0.3279
			end
		elsif low_reynold == 25000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 10.701 * liquid_fraction - 0.0014
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 9.0946 * liquid_fraction + 0.0042
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 501.4 * liquid_fraction ** 3 - 105.07 * liquid_fraction ** 2 + 8.159 * liquid_fraction + 0.0214
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.7805 * liquid_fraction + 0.2204
			end
		elsif low_reynold == 50000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 10.263 * liquid_fraction - 0.0091
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 5.9438 * liquid_fraction + 0.0017
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 43.376 * liquid_fraction ** 3 - 17.429 * liquid_fraction ** 2 + 3.4135 * liquid_fraction + 0.0306
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.8463 * liquid_fraction + 0.1535
			end
		elsif low_reynold == 100000
			if liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 2.7049 * liquid_fraction + 0.0033
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 481.29 * liquid_fraction ** 3 - 79.931 * liquid_fraction ** 2 + 5.4056 * liquid_fraction - 0.0165
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.8926 * liquid_fraction + 0.1064
			end
		elsif low_reynold == 200000
			if liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 1.3135 * liquid_fraction + 0.0035
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.9686 * liquid_fraction + 0.0307
			end
		elsif low_reynold >= 0.2 * 10 ** 6
			low_liquid_hold_up = liquid_fraction
		end
		return low_liquid_hold_up
	end

	def determine_nominal_pipe_size(proposed_diameter)
		pipe_size = 0.0
		pipe_schedule = ""
		selected_diameter = 0.0

		if proposed_diameter > 0 && proposed_diameter <= 0.269
			pipe_size = 0.125
			pipe_schedule = "Sch. 40"
			selected_diameter = 0.269
		elsif proposed_diameter > 0.269 && proposed_diameter <= 0.364
			pipe_size = 0.25
			pipe_schedule = "Sch. 40"
			selected_diameter = 0.364
		elsif proposed_diameter > 0.364 && proposed_diameter <= 0.493
			pipe_size = 0.375
			pipe_schedule = "Sch. 40"
			selected_diameter = 0.493
		elsif proposed_diameter > 0.493 && proposed_diameter <= 0.622
			pipe_size = 0.5
			pipe_schedule = "Sch. 40"
			selected_diameter = 0.622
		elsif proposed_diameter > 0.622 && proposed_diameter <= 0.824
			pipe_size = 0.75
			pipe_schedule = "Sch. 40"
			selected_diameter = 0.824
		elsif proposed_diameter > 0.824 && proposed_diameter <= 1.049
			pipe_size = 1
			pipe_schedule = "Sch. 40"
			selected_diameter = 1.049
		elsif proposed_diameter > 1.049 && proposed_diameter <= 1.38
			pipe_size = 1.25
			pipe_schedule = "Sch. 40"
			selected_diameter = 1.38
		elsif proposed_diameter > 1.38 && proposed_diameter <= 1.61
			pipe_size = 1.5
			pipe_schedule = "Sch. 40"
			selected_diameter = 1.61
		elsif proposed_diameter > 1.61 && proposed_diameter <= 2.067
			pipe_size = 2
			pipe_schedule = "Sch. 40"
			selected_diameter = 2.067
		elsif proposed_diameter > 2.067 && proposed_diameter <= 2.469
			pipe_size = 2.5
			pipe_schedule = "Sch. 40"
			selected_diameter = 2.469
		elsif proposed_diameter > 2.469 && proposed_diameter <= 3.068
			pipe_size = 3
			pipe_schedule = "Sch. 40"
			selected_diameter = 3.068
		elsif proposed_diameter > 3.068 && proposed_diameter <= 3.548
			pipe_size = 3.5
			pipe_schedule = "Sch. 40"
			selected_diameter = 3.548
		elsif proposed_diameter > 3.548 && proposed_diameter <= 4.026
			pipe_size = 4
			pipe_schedule = "Sch. 40"
			selected_diameter = 4.026
		elsif proposed_diameter > 4.026 && proposed_diameter <= 5.047
			pipe_size = 5
			pipe_schedule = "Sch. 40"
			selected_diameter = 5.047
		elsif proposed_diameter > 5.047 && proposed_diameter <= 6.065
			pipe_size = 6
			pipe_schedule = "Sch. 40"
			selected_diameter = 6.065
		elsif proposed_diameter > 6.065 && proposed_diameter <= 7.981
			pipe_size = 8
			pipe_schedule = "Sch. 40"
			selected_diameter = 7.981
		elsif proposed_diameter > 7.981 && proposed_diameter <= 10.02
			pipe_size = 10
			pipe_schedule = "Sch. 40"
			selected_diameter = 10.02
		elsif proposed_diameter > 10.02 && proposed_diameter <= 11.938
			pipe_size = 12
			pipe_schedule = "Sch. 40"
			selected_diameter = 11.938
		elsif proposed_diameter > 11.938 && proposed_diameter <= 13.124
			pipe_size = 14
			pipe_schedule = "Sch. 40"
			selected_diameter = 13.124
		elsif proposed_diameter > 13.124 && proposed_diameter <= 15
			pipe_size = 16
			pipe_schedule = "Sch. 40"
			selected_diameter = 15
		elsif proposed_diameter > 15 && proposed_diameter <= 16.876
			pipe_size = 18
			pipe_schedule = "Sch. 40"
			selected_diameter = 16.876
		elsif proposed_diameter > 16.876 && proposed_diameter <= 18.812
			pipe_size = 20
			pipe_schedule = "Sch. 40"
			selected_diameter = 18.812
		elsif proposed_diameter > 18.812 && proposed_diameter <= 21.25
			pipe_size = 22
			pipe_schedule = "Sch. 20"
			selected_diameter = 21.25
		elsif proposed_diameter > 21.25 && proposed_diameter <= 22.624
			pipe_size = 24
			pipe_schedule = "Sch. 40"
			selected_diameter = 22.624
		elsif proposed_diameter > 22.624 && proposed_diameter <= 25
			pipe_size = 26
			pipe_schedule = "Sch. 20"
			selected_diameter = 25
		elsif proposed_diameter > 25 && proposed_diameter <= 27
			pipe_size = 28
			pipe_schedule = "Sch. 20"
			selected_diameter = 27
		elsif proposed_diameter > 27 && proposed_diameter <= 29
			pipe_size = 30
			pipe_schedule = "Sch. 20"
			selected_diameter = 29
		elsif proposed_diameter > 29 && proposed_diameter <= 31
			pipe_size = 32
			pipe_schedule = "Sch. 20"
			selected_diameter = 31
		elsif proposed_diameter > 31 && proposed_diameter <= 33
			pipe_size = 34
			pipe_schedule = "Sch. 20"
			selected_diameter = 33
		elsif proposed_diameter > 33 && proposed_diameter <= 35
			pipe_size = 36
			pipe_schedule = "Sch. 20"
			selected_diameter = 35
			#TODO added without clients permission
		elsif proposed_diameter > 35 && proposed_diameter <= 47
			pipe_size = 48
			pipe_schedule = "N/A"
			selected_diameter = proposed_diameter
		elsif proposed_diameter > 47 && proposed_diameter <= 51
			pipe_size = 56
			pipe_schedule = "N/A"
			selected_diameter = proposed_diameter
		elsif proposed_diameter > 51 && proposed_diameter <= 71
			pipe_size = 72
			pipe_schedule = "N/A"
			selected_diameter = proposed_diameter
		end  

		{:pipe_size => pipe_size, :pipe_schedule => pipe_schedule, :proposed_diameter => selected_diameter}
	end

	def p_drop_calc_vapor(pi, project, vapor_viscosity, vapor_density, stream_pressure, stream_temperature, vapor_k, vapor_mw, stream_flow_rate, proposed_diameter, pipe_roughness, system_equivalent_length)
		section_outlet_pressure = (0..101).to_a
		section_outlet_temperature = (0..101).to_a
		t = stream_temperature
		p1 = stream_pressure
		p2 = 0.0
		p2critical = 0.0

		reynold_number = (0.52633 * stream_flow_rate) / ((proposed_diameter / 12.0) * vapor_viscosity)

		#Determine new friction factor using Churchill's equation
		a = (2.457 * Math.log(1.0 / (((7.0 / reynold_number) ** 0.9) + (0.27 * (pipe_roughness / proposed_diameter))))) ** 16.0
		b = (37530 / reynold_number) ** 16.0
		ft = 2.0 * ((8.0 / reynold_number) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0)
		d_reynolds = reynold_number
		length = system_equivalent_length


		#Kf for Pipe
		kf = 4.0 * ft * (length / (proposed_diameter / 12.0))

		#Determine G
		area = (pi / 4.0) * (proposed_diameter) ** 2.0         #in^2
		mass_velocity = stream_flow_rate / area       #lb/hr in^2
		if project.vapor_flow_model == "Isothermic"
			part1 = (p1 + barometric_pressure) ** 2.0
			part2 = (7.41109 * 10.0 ** -6 * (t + 459.67) * mass_velocity ** 2.0) / vapor_mw
			part3 = kf / 2.0
			initial_outlet_pressure = (part1 - (part2 * part3)) ** 0.5
			(1..100).each do |gg|
				part4 = Math.log((stream_pressure + barometric_pressure) / initial_outlet_pressure) 
				#'Log is natural log (aka ln())
				section_outlet_pressure[gg] = (part1 - part2 * (part3 + part4)) ** 0.5
				initial_outlet_pressure = section_outlet_pressure[gg]
				if section_outlet_pressure[gg] ==  section_outlet_pressure[gg - 1]
					p2 = section_outlet_pressure[gg] - barometric_pressure
				end              
			end   

			actual_dp = stream_pressure - p2
			#Determine sonic downstream pressure at each fitting along the system
			#Check for choked flow
			(1..1000).each do |r|
				p2critical = (stream_pressure + barometric_pressure) - ((0.001 * r) * (stream_pressure + barometric_pressure))
				part1 = ((stream_pressure +  barometric_pressure) / p2critical) ** 2
				part2 = 2 * Math.log((p1 + barometric_pressure) / p2critical)
				isothermal_choke_kf = part1 - part2 - 1
				if kf <= isothermal_choke_kf
					r = 1000
				end
			end

			#Determine and document choked conditions
			if (p2critical - barometric_pressure) > p2
				#message1 = MsgBox("Choked flow expected in the system equivalent length of piping containing stream " & Chr(34) & StreamNo & " in the process basis (" & ProcessBasis & ") at the proposed diameter.", vbInformation, "Choked Flow Experienced!")
				notes_choke = "Choked flow expected within the system equivalent length of piping at proposed diameter."
				actual_dp = stream_pressure - p2critical
			end
		elsif project.vapor_flow_model == "Adiabatic"
			part1 = vapor_k / (vapor_k + 1.0)
			part2 = 269866.0 * (vapor_k / (vapor_k + 1.0))
			part3 = ((p1 + barometric_pressure) ** 2.0 * vapor_mw) / (stream_temperature + 459.67)
			part4 = mass_velocity ** 2.0 * (kf / 2.0)
			initial_outlet_pressure = (p1 + barometric_pressure) * (1.0 - (part4 / (part2 * part3))) ** part1
			(1..100).each do |gg|
				part5 = (Math.log((stream_pressure + barometric_pressure) / initial_outlet_pressure)) / vapor_k
				part6 = mass_velocity ** 2.0 * ((kf / 2.0) + part5)
				section_outlet_pressure[gg] = (stream_pressure + barometric_pressure) * (1.0 - (part6 / (part2 * part3))) ** part1
				section_outlet_pressure[gg] = (stream_temperature + 459.69) * (section_outlet_pressure[gg] / (stream_pressure + barometric_pressure)) ** ((vapor_k - 1) / vapor_k)
				initial_outlet_pressure = section_outlet_pressure[gg]
				if section_outlet_pressure[gg] = section_outlet_pressure[gg-1.0]
					p2 = section_outlet_pressure[gg] - barometric_pressure
					t2 = section_outlet_pressure[gg] - 459.69
					gg = 100
				end
			end  

			actual_dp = stream_pressure - p2

			#Determine sonic downstream pressure at each fitting along the system
			#Check for choked flow
			(1..1000).each do |r|
				p2critical = (stream_pressure + barometric_pressure) - ((0.001 * r) * (stream_pressure + barometric_pressure))
				part1 = 2 / (vapor_k + 1)
				part2 = (((stream_pressure + barometric_pressure) / p2critical) ** ((vapor_k + 1) / vapor_k)) - 1
				part3 = (2 / vapor_k) * Math.log((stream_pressure + barometric_pressure) / p2critical)
				adiabatic_choke_kf = (part1 * part2) - Part3
				if Kf <= adiabatic_choke_kf
					r = 1000
				end
			end   

			#Determine and document choked conditions
			if(p2critical - barometric_pressure) > p2
				#message1 = MsgBox("Choked flow expected in the system equivalent length of piping containing stream " & Chr(34) & StreamNo & " in the process basis (" & ProcessBasis & ").", vbInformation, "Choked Flow Experienced!")
				notes_choke = "Choked flow expected within the system equivalent length of piping at proposed diameter."
				actual_dp = stream_pressure - p2critical
			end

		end
		{:actual_dp=>actual_dp, :notes_choke => notes_choke, :d_reynolds => d_reynolds}
	end

	def p_drop_calc_liquid(liquid_viscosity, liquid_density, stream_flow_rate, proposed_diameter, pipe_roughness, system_equivalent_length, pi)
		length = system_equivalent_length      #              'ft
		volume_rate = stream_flow_rate / liquid_density
		nre = (0.52633 * stream_flow_rate) / ((proposed_diameter / 12) * liquid_viscosity)

		#Determine new friction factor using Churchill's equation
		a = (2.457 * Math.log(1 / (((7 / nre) ** 0.9) + (0.27 * (pipe_roughness / proposed_diameter))))) ** 16
		b = (37530 / nre) ** 16
		fm = 2 * ((8 / nre) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)

		n_reynolds = nre
		d_reynolds = n_reynolds
		#Kf for Pipe
		kf = 4 * fm * (length / (proposed_diameter / 12))

		kfd_sum = kf / (proposed_diameter / 12) ** 4

		part1 = ((8 * volume_rate ** 2) / pi ** 2) * kfd_sum
		part2 = liquid_density / (6.00444 * 10 ** 10)
		actual_dp = part1 * part2

		{:actual_dp=>actual_dp, :d_reynolds => d_reynolds} 
	end 

	def p_drop_calc_two_phase(proposed_diameter, stream_liquid_flow_rate, stream_vapor_flow_rate, liquid_density, vapor_density, liquid_viscosity, vapor_viscosity, liquid_surface_tension, process_basis, stream_no, pi, calculated_velocity, pipe_roughness, system_equivalent_length, project)

		dukler_density = (1..100).to_a
		dukler_reynold = (1..100).to_a
		ri = (1..100).to_a

		#Determine volumetric flow rate
		ql = stream_liquid_flow_rate / liquid_density
		qg = stream_vapor_flow_rate / vapor_density
		qm = ql + qg
		volume_rate = qm

		#Determine liquid inlet resistance and physical properties
		liquid_resistance = ql / qm
		m_density = (liquid_density * liquid_resistance) + vapor_density * (1 - vapor_viscosity)
		m_viscosity = (liquid_viscosity * liquid_resistance) + vapor_viscosity * (1 - vapor_viscosity)

		proposed_area = pi * (proposed_diameter / 2) ** 2

		#Determine Vapor and Liquid Superficial Velocity
		vsg = 0.04 * (qg / proposed_area)
		vsL = 0.04 * (ql / proposed_area)
		vm = vsg + vsL

		#Errosion-Corrosion index test
		wl = stream_liquid_flow_rate
		wg = stream_vapor_flow_rate
		pm = (wl + wg) / (ql + qg)
		aec = proposed_area / 144

		um = (wg / (3600 * vapor_density * aec)) + (wl / (3600 * liquid_density * aec))

		if (pm * um ** 2) <= 10000
			#UserFormBaker.lblErrosionIndex.BackColor = &H8000000F 'Back color is normal
			#UserFormFlowRegime.lblECIndex.BackColor = &H8000000F  'Back color is normal
		else
			#msg2 = MsgBox("The errosion index exceeds the recommended level.  Errosion-corrosion may be significant at this velocity and pipe size.", vbInformation, "Errosion-corrosion warning!")
			#UserFormBaker.lblErrosionIndex.BackColor = &H8080FF   'Back color is red
			#UserFormFlowRegime.lblECIndex.BackColor = &H8080FF    'Back color is red
		end

		#UserFormBaker.lblErrosionIndex = Round(Pm * Um ^ 2, 0)
		#UserFormFlowRegime.lblECIndex = Round(Pm * Um ^ 2, 0)

		#Determine average local liquid resistance , Rl, liquid hold up or actual resistance of liquid in piping
		r1[1] = liquid_resistance

		(1..100).each do |i|
			part1 = (liquid_density * liquid_resistance ** 2) / r1[i]
			part2 = (vapor_density * (1 - liquid_resistance) ** 2) / (1 - r1[i])
			dukler_density[i] = part1 + part2
			dukler_reynold[i] = (dukler_density[i] * vm * (proposed_diameter / 12)) / (0.000671969 * m_viscosity)

			if dukler_reynold[i] > 0.2 * 10 ** 6 #To maintain a bubble/froth flow regime and give economical pipe sizes
				r1[i + 1] = liquid_resistance
			else
				reynold = dukler_reynold[i]
				liquid_fraction = liquid_resistance
				liquid_hold_up = liquid_resist(reynold, liquid_fraction)
				r1[i + 1] = liquid_hold_up
			end

			if r1[i + 1] = r1[1]
				d_reynolds = dukler_reynold[i]
				d_density = dukler_density[i]
				i = 100
			end
		end

		#Flow regime test
		#'Determine Baker Parameters Bx, By
		wl = stream_liquid_flow_rate
		wg = stream_vapor_flow_rate
		pl = liquid_density
		pg = vapor_density
		ul = liquid_viscosity
		ug = vapor_viscosity
		ol = liquid_surface_tension
		area = pi * ((proposed_diameter / 12) / 2) ** 2  #ft^2

		bx = 531 * (WL / Wg) * (((PL * Pg) ** 0.5) / (PL ** (2 / 3))) * (uL ** (1 / 3) / OL)
		by = 2.16 * (Wg / Area) * (1 / (PL * Pg) ** 0.5)

		#targetBy = UserFormBaker.txtTargetBy.Value
		target_by = 0

		if target_by != ""
			target_by = target_by + 0
		end

		if target_by = "" || target_by = 0 || target_by <= by
			#UserFormFlowRegime.lblBx = Round(bx, 0)
			#UserFormFlowRegime.lblBy = Round(by, 0)
			#UserFormFlowRegime.lblLiquidVelocity = Round(VsL, 2)
			#UserFormFlowRegime.lblVaporVelocity = Round(Vsg, 2)
			#UserFormFlowRegime.lblProcessBasis = ProcessBasis
			#UserFormFlowRegime.lblStreamNo = StreamNo
			#UserFormFlowRegime.lblPipeID = ProposedDiameter
			#UserFormFlowRegime.cmbFlowRegime = Empty
			#UserFormFlowRegime.lblCalcType = CalcType
			if proposed_diameter <= 2.469 && bx < 125
				#UserFormFlowRegime.cmbDesiredlFlowRegime = "Dispersed/Spray/Mist"
			elsif proposed_diameter > 2.469 && bx < 125
				#UserFormFlowRegime.cmbDesiredlFlowRegime = "Annular"
			elsif proposed_diameter > 2.469 && bx >= 125
				#UserFormFlowRegime.cmbDesiredlFlowRegime = "Bubble/Froth"
			else
				#UserFormFlowRegime.cmbDesiredlFlowRegime = ""
			end
			#UserFormFlowRegime.Show
			#FlowRegime = UserFormFlowRegime.cmbFlowRegime
			#DesiredFlowRegime = UserFormFlowRegime.cmbDesiredlFlowRegime
		else
		end

		flow_regime = "Slug" #TODO
		if flow_regime == "Slug"
			#msg1 = MsgBox("Slug flow regime should be avoided in the two phase pipe design due to potential liquid hammer issues.", vbInformation, "Slug Flow Regime Identified!")
		elsif flow_regime == "Dispersed/Spray/Mist"
			#msg1 = MsgBox("Mist flow regime should be avoided in the two phase pipe design due to potential phase disengagement issues'", vbInformation, "Mist Flow Regime Identified!")
		end

		if project.two_phase_flow_model == "Dukler"
			#Determine single phase friction factor
			s = 1.281 + 0.478 * Math.log(liquid_resistance) + 0.444 * (Math.log(liquid_resistance)) ** 2 + 0.09399999 * (Math.log(liquid_resistance)) ** 3 + 0.0084330001 * (Math.log(liquid_resistance)) ** 4
			#Determine two phase friction factor
			ftpr = 1 - (Math.log(liquid_resistance) / s)
			fo = 0.0014 + (0.125 / d_reynolds ** 0.32)
			ftp = ftpr * fo

			#Determine Frictional pressure drop using system equivalent length pipe basis
			length = system_equivalent_length
			dPf = 4 * (ftp / (144 * 32.2)) * (length / (proposed_diameter / 12)) * m_density * (vm ** 2 / 2)

			#Determine Elevation Pressure Drop, Assumed no elevation for preliminary sizing
			dpe = 0

			#Determine Acceleration Pressure Drop, Assumed no contribution
			dpa = 0

			#Total Pressure Drop
			total_dp = dPf + dpe + dpa
		elsif project.two_phase_flow_model == "Lockhart-Martinelli" #From project
			areaft2 = pi * ((proposed_diameter / 12) / 2) ** 2        #        'ft^2
			nrel = (pl * vsL * (proposed_diameter / 12)) / (0.000671969 * ul)
			nreg = (pl * vsL * (proposed_diameter / 12)) / (0.000671969 * ug)
			#Determine Liquid Pressure Drop
			#Determine new friction factor using Churchill's equation
			a = (2.457 * Math.log(1 / (((7 / nrel) ** 0.9) + (0.27 * (pipe_roughness / proposed_diameter))))) ** 16
			b = (37530 / nrel) ** 16
			fL = 2 * ((8 / nrel) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)

			#Determine Vapor Pressure Drop
			#Determine new friction factor using Churchill's equation
			a = (2.457 * Math.log(1 / (((7 / nreg) ** 0.9) + (0.27 * (pipe_roughness / proposed_diameter))))) ** 16
			b = (37530 / nreg) ** 16
			fg = 2 * ((8 / nreg) ** 12 + (1 / ((a + b) ** (3 / 2)))) ** (1 / 12)
			delta_pl_per_length = ((3.36 * 10 ** -6) * fL * wl ** 2) / ((proposed_diameter) ** 5 * pl)
			delta_pg_per_length = ((3.36 * 10 ** -6) * fg * Wg ** 2) / ((proposed_diameter) ** 5 * pg)

			x = (delta_pl_per_length / delta_pg_per_length) ** 0.5

			#Determine Omega for all flow regime
			stratified_omega = (15400 * x) / (wl / areaft2) ** 0.8
			bubble_froth_omega = (14.2 * x ** 0.75) / (wl / areaft2) ** 0.1

			slug_omega = (1190 * X ** 0.815) / (wl / areaft2) ** 0.5

			hx = (wl / wg) * (ul / ug)
			fh = Math.exp((0.211 * Math.log(hx)) - 3.993)
			delta_ptp_per_length = ((3.36 * 10 ** -6) * fh * wg ** 2) / ((proposed_diameter) ** 5 * pg)

			if proposed_diameter >= 12
				proposed_diameter_aa = 10
				proposed_diameter_bb = 10
			else
				proposed_diameter_aa = proposed_diameter
				proposed_diameter_bb = proposed_diameter
			end
			aa = 4.8 - 0.3125 * proposed_diameter_aa
			bb = 0.343 - 0.021 * proposed_diameter_bb
			annular_omega = aa * x ** bb

			c0 = 1.4659
			c1 = 0.49138
			c2 = 0.04887
			c3 = -0.000349
			dispersed_spray_mist_omega = Math.exp((c0 + c1 * Math.log(x) + c2 * (Math.log(x)) ** 2 + c3 * (Math.log(x)) ** 3))
			plug_omega = (27.315 * x ** 0.855) / (wl / areaft2) ** 0.17

			#Determine Omega for select flow regime
			if flow_regime == "Stratified"
				omega = stratified_omega
			elsif flow_regime == "Bubble/Froth"
				omega = bubble_froth_omega
			elsif flow_regime == "Slug"
				omega = slug_omega
			elsif flow_regime == "Wave"
			elsif flow_regime == "Annular"
				omega = AnnularOmega
			elsif flow_regime == "Dispersed/Spray/Mist"
				omega = dispersed_spray_mist_omega
			elsif flow_regime == "Plug"
				omega = plug_omega
			end

			if flow_regime != "Wave"
				delta_ptp_per_length = delta_pg_per_length * omega ** 2
			end

			#Determine Frictional pressure drop using a 100 ft horizontal pipe basis
			length = system_equivalent_length
			tp_horizontal_deltap = delta_ptp_per_length * length

			#Determine Elevation Pressure Drop, Assumed no elevation for preliminary sizing
			tp_elevation_deltap = 0

			#Total Pressure Drop
			total_dp = tp_horizontal_deltap + tp_elevation_deltap
		end

		actual_dp = total_dp
		calculated_velocity = vm
		{:actual_dp => actual_dp, :calculated_velocity => calculated_velocity}    
	end

	def calc_flow_regime_values(stream_liquid_flow_rate,stream_vapor_flow_rate,liquid_density,vapor_density,liquid_viscosity,liquid_surface_tension)
		pi=3.14159265358979
		ql=stream_liquid_flow_rate/liquid_density
		qg=stream_vapor_flow_rate/vapor_density
		wl = stream_liquid_flow_rate
		wg = stream_vapor_flow_rate
		pm = (wl + wg) / (ql + qg)
		#TODO check bx calculation values. 
		#bx = 531 * (wl / wg) * (((liquid_density * vapor_density) ** 0.5) / (liquid_density ** (2 / 3))) * (liquid_viscosity ** (1 / 3) / liquid_surface_tension)
		bx = 111 #TODO

		#array declarations
		pipe_id = []
		est_area = []
		area = []
		aec = []
		um = []
		fluid_momentum = []
		vsg = []
		vsl = []
		by = []

		(0..32).each do |i|
			pipe_id[i] = PipeSizing.pipe_size_cycle[i][:diameter].to_f
			est_area[i] = pi * (pipe_id[i] / 2) ** 2
			area[i] = pi * ((pipe_id[i] / 12) / 2) ** 2 
			aec[i] = est_area[i] / 144
			um[i] = (wg / (3600 * vapor_density * aec[i])) + (wl / (3600 * liquid_density * aec[i]))
			fluid_momentum[i] = pm * um[i] ** 2
			vsg[i] = 0.04 * (qg / est_area[i])
			vsl[i] = 0.04 * (ql / est_area[i])
			by[i] = 2.16 * (wg / area[i]) * (1 / (liquid_density * vapor_density) ** 0.5)   
		end  
		#return values
		{:bx=>bx, :by=>by, :pipe_id=> pipe_id, :errosion_index=> fluid_momentum, :vapor_superficial_density=> vsg, :liquid_superficial_density=> vsl}

	end

	def determine_pipe_diameter(pipe_size, pipe_schedule)
		if pipe_size == 0.125
			if pipe_schedule == "Sch. 10S"
				pipe_d = 0.307
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 0.269
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 0.269
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 0.215
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 0.215
			end
		elsif pipe_size==0.25
			if pipe_schedule == "Sch. 40"
				pipe_d = 0.364
			elsif pipe_schedule == "Sch. 80"
				pipe_d = 0.302
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 0.41
			elsif pipe_schedule == "Sch. 40ST" 
				pipe_d = 0.364
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 0.364
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 0.302
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 0.302  
			end
		elsif pipe_size==0.375
			if pipe_schedule == "Sch. 10S"
				pipe_d = 0.545
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 0.493
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 0.493
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 0.423
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 0.423
			end    
		elsif pipe_size==0.5
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 0.71
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 0.674
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 0.622
			elsif pipe_schedule == "Sch. 40S" 
				pipe_d = 0.622
			elsif pipe_schedule == "Sch. 80XS" 
				pipe_d = 0.546
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 0.546
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 0.546
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 0.464
			elsif pipe_schedule == "Sch. XX" 
				pipe_d = 0.252
			end
		elsif pipe_size==0.75
			if pipe_schedule == "Sch. 5S"
				pipe_d = 0.92
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 0.884
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 0.824
			elsif pipe_schedule == "Sch. 40S" 
				pipe_d = 0.824
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 0.824
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 0.742
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 0.742
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 0.742
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 0.612
			elsif pipe_schedule == "Sch. XX" 
				pipe_d = 0.434
			end
		elsif pipe_size ==1
			if pipe_schedule == "Sch. 5S"
				pipe_d = 1.185
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 1.097
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 1.049
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 1.049
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 1.049
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 0.957
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 0.957
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 0.957
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 0.815
			elsif pipe_schedule == "Sch. XX"
				pipe_d = 0.599
			end
		elsif pipe_size ==1.25
			if pipe_schedule == "Sch. 5S"
				pipe_d = 1.53
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 1.442
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 1.38
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 1.38
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 1.38
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 1.278
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 1.278
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 1.278
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 1.16
			elsif pipe_schedule == "Sch. XX" 
				pipe_d = 0.896
			end
		elsif pipe_size == 1.5
			if pipe_schedule == "Sch. 5S"
				pipe_d = 1.77
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 1.682
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 1.61
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 1.61
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 1.61
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 1.5
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 1.5
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 1.5
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 1.338
			elsif pipe_schedule == "Sch. XX"
				pipe_d = 1.1
			end   
		elsif pipe_size == 2
			if pipe_schedule == "Sch. 5S"
				pipe_d = 2.245
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 2.157
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 2.067
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 2.067
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 2.067
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 1.939
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 1.939
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 1.939
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 1.687
			elsif pipe_schedule == "Sch. XX"
				pipe_d = 1.503
			end
		elsif pipe_size == 2.5
			if pipe_schedule == "Sch. 5S"
				pipe_d = 2.709
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 2.635
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 2.469
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 2.469
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 2.469
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 2.323
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 2.323
			elsif pipe_schedule == "Sch. 80"
				pipe_d = 2.323
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 2.125
			elsif pipe_schedule == "Sch. XX"
				pipe_d = 1.771
			end
		elsif pipe_size == 3
			if pipe_schedule == "Sch. 5S"
				pipe_d = 3.334
			elsif  pipe_schedule == "Sch. 10S"
				pipe_d = 3.26
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 3.068
			elsif pipe_schedule == "Sch. 40S" 
				pipe_d = 3.068
			elsif pipe_schedule == "Sch. 40"
				pipe_d = 3.068
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 2.9
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 2.9
			elsif pipe_schedule == "Sch. 80"
				pipe_d = 2.9
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 2.624
			elsif pipe_schedule == "Sch. XX"
				pipe_d = 2.3
			end
		elsif pipe_size ==3.5
			if  pipe_schedule == "Sch. 5S"
				pipe_d = 3.834
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 3.76
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 3.548
			elsif pipe_schedule == "Sch. 40S" 
				pipe_d = 3.548
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 3.548
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 3.364
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 3.364
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 3.364
			end
		elsif pipe_size == 4
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 4.334
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 4.26
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 4.026
			elsif pipe_schedule == "Sch. 40S" 
				pipe_d = 4.026
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 4.026
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 3.826
			elsif pipe_schedule == "Sch. 80S" 
				pipe_d = 3.826
			elsif pipe_schedule == "Sch. 80"
				pipe_d = 3.826
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 3.624
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 3.438
			elsif pipe_schedule == "Sch. XX"
				pipe_d = 3.152
			end 
		elsif pipe_size ==5
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 5.345
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 5.295
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 5.047
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 5.047
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 5.047
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 4.813
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 4.813
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 4.813
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 4.563
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 4.313
			elsif pipe_schedule == "Sch. XX"
				pipe_d = 4.063
			end
		elsif pipe_size ==6
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 6.407
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 6.357
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 6.065
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 6.065
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 6.065
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 5.761
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 5.761
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 5.761
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 5.501
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 5.187
			elsif pipe_schedule == "Sch. XX" 
				pipe_d = 4.897
			end
		elsif pipe_size == 8
			if  pipe_schedule == "Sch. 5S"
				pipe_d = 8.407
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 8.329
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 8.125
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 8.071
			elsif pipe_schedule == "Sch. 40ST"
				pipe_d = 7.981
			elsif pipe_schedule == "Sch. 40S"
				pipe_d = 7.981
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 7.981
			elsif pipe_schedule == "Sch. 60" 
				pipe_d = 7.813
			elsif pipe_schedule == "Sch. 80XS"
				pipe_d = 7.625
			elsif pipe_schedule == "Sch. 80S"
				pipe_d = 7.625
			elsif pipe_schedule == "Sch. 100"
				pipe_d = 7.437
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 7.187
			elsif pipe_schedule == "Sch. 140"
				pipe_d = 7.001
			elsif pipe_schedule == "Sch. XX" 
				pipe_d = 6.875
			elsif pipe_schedule == "Sch. 160" 
				pipe_d = 6.813
			end
		elsif pipe_size == 10
			if pipe_schedule == "Sch. 5S"
				pipe_d = 10.482
			elsif  pipe_schedule == "Sch. 10S"
				pipe_d = 10.42
			elsif  pipe_schedule == "Sch. 20" 
				pipe_d = 10.25
			elsif  pipe_schedule == "Sch. 30" 
				pipe_d = 10.136
			elsif  pipe_schedule == "Sch. 40ST"
				pipe_d = 10.02
			elsif  pipe_schedule == "Sch. 40S" 
				pipe_d = 10.02
			elsif  pipe_schedule == "Sch. 40" 
				pipe_d = 10.02
			elsif  pipe_schedule == "Sch. 80S"
				pipe_d = 9.75
			elsif  pipe_schedule == "Sch. 60XS"
				pipe_d = 9.75
			elsif  pipe_schedule == "Sch. 80" 
				pipe_d = 9.562
			elsif  pipe_schedule == "Sch. 100"
				pipe_d = 9.312
			elsif  pipe_schedule == "Sch. 120"
				pipe_d = 9.062
			elsif  pipe_schedule == "Sch. 140"
				pipe_d = 8.75
			elsif  pipe_schedule == "Sch. XX" 
				pipe_d = 8.75
			elsif  pipe_schedule == "Sch. 160"
				pipe_d = 8.5
			end 
		elsif pipe_size == 12
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 12.438
			elsif  pipe_schedule == "Sch. 10S"
				pipe_d = 12.39
			elsif  pipe_schedule == "Sch. 20"
				pipe_d = 12.25
			elsif  pipe_schedule == "Sch. 30"
				pipe_d = 12.09
			elsif  pipe_schedule == "Sch. ST"
				pipe_d = 12#
			elsif  pipe_schedule == "Sch. 40S"
				pipe_d = 12#
			elsif  pipe_schedule == "Sch. 40" 
				pipe_d = 11.938
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 11.75
			elsif  pipe_schedule == "Sch. 80S"
				pipe_d = 11.75
			elsif  pipe_schedule == "Sch. 60" 
				pipe_d = 11.626
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 11.374
			elsif pipe_schedule == "Sch. 100"
				pipe_d = 11.062
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 10.75
			elsif pipe_schedule == "Sch. XX" 
				pipe_d = 10.75
			elsif pipe_schedule == "Sch. 140"
				pipe_d = 10.5
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 10.126
			end
		elsif pipe_size == 14
			if  pipe_schedule == "Sch. 5S"
				pipe_d = 13.686
			elsif  pipe_schedule == "Sch. 10S"
				pipe_d = 13.624
			elsif  pipe_schedule == "Sch. 10" 
				pipe_d = 13.5
			elsif  pipe_schedule == "Sch. 20" 
				pipe_d = 13.376
			elsif  pipe_schedule == "Sch. 30" 
				pipe_d = 13.25
			elsif  pipe_schedule == "Sch. ST" 
				pipe_d = 13.25
			elsif  pipe_schedule == "Sch. 40" 
				pipe_d = 13.124
			elsif  pipe_schedule == "Sch. XS" 
				pipe_d = 13#
			elsif  pipe_schedule == "Sch. 60" 
				pipe_d = 12.812
			elsif  pipe_schedule == "Sch. 80" 
				pipe_d = 12.5
			elsif  pipe_schedule == "Sch. 100" 
				pipe_d = 12.124
			elsif  pipe_schedule == "Sch. 120" 
				pipe_d = 11.812
			elsif  pipe_schedule == "Sch. 140" 
				pipe_d = 11.5
			elsif  pipe_schedule == "Sch. 160" 
				pipe_d = 11.188
			end    
		elsif pipe_size == 16
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 15.67
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 15.624
			elsif pipe_schedule == "Sch. 10" 
				pipe_d = 15.5
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 15.376
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 15.25
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 15.25
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 15#
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 15#
			elsif pipe_schedule == "Sch. 60" 
				pipe_d = 14.688
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 14.312
			elsif pipe_schedule == "Sch. 100" 
				pipe_d = 13.938
			elsif pipe_schedule == "Sch. 120" 
				pipe_d = 13.562
			elsif pipe_schedule == "Sch. 140" 
				pipe_d = 13.124
			elsif pipe_schedule == "Sch. 160" 
				pipe_d = 12.812
			end
		elsif pipe_size == 18
			if pipe_schedule == "Sch. 5S"
				pipe_d = 17.67
			elsif  pipe_schedule == "Sch. 10S"
				pipe_d = 17.624
			elsif  pipe_schedule == "Sch. 10" 
				pipe_d = 17.5
			elsif  pipe_schedule == "Sch. 20" 
				pipe_d = 17.376
			elsif  pipe_schedule == "Sch. ST" 
				pipe_d = 17.25
			elsif  pipe_schedule == "Sch. 30" 
				pipe_d = 17.124
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 17#
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 16.876
			elsif pipe_schedule == "Sch. 60" 
				pipe_d = 16.5
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 16.124
			elsif pipe_schedule == "Sch. 100"
				pipe_d = 15.688
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 15.25
			elsif pipe_schedule == "Sch. 140"
				pipe_d = 14.876
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 14.438
			end
		elsif pipe_size == 20
			if  pipe_schedule == "Sch. 5S" 
				pipe_d = 19.624
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 19.564
			elsif pipe_schedule == "Sch. 10" 
				pipe_d = 19.5
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 19.25
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 19.25
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 19#
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 19#
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 18.812
			elsif pipe_schedule == "Sch. 60" 
				pipe_d = 18.376
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 17.938
			elsif pipe_schedule == "Sch. 100"
				pipe_d = 17.438
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 17
			elsif pipe_schedule == "Sch. 140"
				pipe_d = 16.5
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 16.062
			end
		elsif pipe_size == 22
			if pipe_schedule == "Sch. 5S"
				pipe_d = 21.624
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 21.564
			elsif pipe_schedule == "Sch. 10" 
				pipe_d = 21.5
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 21.25
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 21.25
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 21#
			elsif  pipe_schedule == "Sch. XS"
				pipe_d = 21#
			elsif pipe_schedule == "Sch. 60" 
				pipe_d = 20.25
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 19.75
			elsif pipe_schedule == "Sch. 100"
				pipe_d = 19.25
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 18.75
			elsif pipe_schedule == "Sch. 140"
				pipe_d = 18.25
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 17.75
			end
		elsif pipe_size == 24
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 23.565
			elsif pipe_schedule == "Sch. 10" 
				pipe_d = 23.5
			elsif pipe_schedule == "Sch. 10S" 
				pipe_d = 23.5
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 23.25
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 23.25
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 23#
			elsif  pipe_schedule == "Sch. 30" 
				pipe_d = 22.876
			elsif  pipe_schedule == "Sch. 40" 
				pipe_d = 22.624
			elsif pipe_schedule == "Sch. 60" 
				pipe_d = 22.062
			elsif pipe_schedule == "Sch. 80" 
				pipe_d = 21.562
			elsif pipe_schedule == "Sch. 100"
				pipe_d = 20.938
			elsif pipe_schedule == "Sch. 120"
				pipe_d = 20.376
			elsif pipe_schedule == "Sch. 140"
				pipe_d = 19.876
			elsif pipe_schedule == "Sch. 160"
				pipe_d = 19.312
			end
		elsif pipe_size == 26
			if pipe_schedule == "Sch. 10"
				pipe_d = 25.376
			elsif pipe_schedule == "Sch. ST"
				pipe_d = 25.25
			elsif pipe_schedule == "Sch. XS"
				pipe_d = 25#
			elsif pipe_schedule == "Sch. 20"
				pipe_d = 25
			end
		elsif pipe_size == 28
			if pipe_schedule == "Sch. 10"
				pipe_d = 27.376
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 27.25
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 27#
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 27#
			elsif  pipe_schedule == "Sch. 30" 
				pipe_d = 26.75
			end
		elsif pipe_size == 30
			if pipe_schedule == "Sch. 5S" 
				pipe_d = 29.5
			elsif  pipe_schedule == "Sch. 10"
				pipe_d = 29.376
			elsif pipe_schedule == "Sch. 10S"
				pipe_d = 29.376
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 29.25
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 29#
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 29#
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 28.75
			end
		elsif pipe_size == 32
			if pipe_schedule == "Sch. 10"
				pipe_d = 31.376
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 31.25
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 31#
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 31#
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 30.75
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 30.624
			end    
		elsif pipe_size == 34
			if pipe_schedule == "Sch. 10" 
				pipe_d = 33.312
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 33.25
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 33
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 33#
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 32.75
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 32.624
			end
		elsif pipe_size == 36
			if pipe_schedule == "Sch. 10" 
				pipe_d = 35.367
			elsif pipe_schedule == "Sch. ST" 
				pipe_d = 35.25
			elsif pipe_schedule == "Sch. XS" 
				pipe_d = 35#
			elsif pipe_schedule == "Sch. 20" 
				pipe_d = 35#
			elsif pipe_schedule == "Sch. 30" 
				pipe_d = 34.75
			elsif pipe_schedule == "Sch. 40" 
				pipe_d = 34.5
			end
		else
			pipe_d = 0
		end#end main if
		return pipe_d      

	end #end determine_pipe_diameter

	def target_two_phase_regime_estimate
		@line_sizing = LineSizing.find(params[:line_sizing_id])
		render :json => @line_sizing.target_two_phase_regime
	end

	def baker_flow_regime(bx,by)

		flow_regime = ""

		if bx >= 0.1 and bx < 0.75
			annular_by = Math.exp(9.774459 - 0.6548 * Math.log(bx))
			wave_by = 7000
		  if by >= annular_by
			  flow_regime =  "Annular"
		  elsif by < annular_by and by >= wave_by
			  flow_regime = "Wave"
		  elsif by < wave_by
			  flow_regime = "Stratified"
      end
    end

		if bx >= 0.75 and bx < 3
			dispersed_by = Math.exp((11.3976 - 0.6084 * Math.log(bx) + 0.0779 * Math.log(bx)) ** 2.0)
			annular_by = Math.exp(9.774459 - 0.6548 * Math.log(bx))
			wave_by = -1505 * Math.log(bx) + 6850
			if by >= dispersed_by
				flow_regime = "Dispersed/Spray/Mist"
			elsif by >= annular_by and by < dispersed_by
				flow_regime = "Annular"
			elsif by >= wave_by and by < annular_by
				flow_regime = "Wave"
			elsif by < wave_by
				flow_regime = "Stratified"
			end
		end

		if bx >= 3 and bx < 20
			dispersed_by = Math.exp(11.3976 - 0.6084 * Math.log(bx) + 0.0779 * (Math.log(bx)) ** 2)
			annular_by = Math.exp(10.7448 - 1.6265 * Math.log(bx) + 0.2839 * (Math.log(bx)) ** 2)
			slug_by  = Math.exp(9.774459 - 0.6548 * Math.log(bx))
			wave_by  = -1505 * Math.log(bx) + 6850
			if by >= dispersed_by
				flow_regime = "Dispersed/Spray/Mist"
			elsif by >= annular_by and  by < dispersed_by
				flow_regime = "Annular"
			elsif by >= slug_by and by < annular_by
				flow_regime = "Slug"
			elsif by >= wave_by and by < slug_by
				flow_regime = "Wave"
			elsif by < wave_by 
				flow_regime = "Stratified"
			end
		end

		if bx >= 20 and bx < 80
			disperse_by = Math.exp(11.3976 - 0.6084 * Math.log(bx) + 0.0779 * (Math.log(bx)) ** 2)
			annular_by = Math.exp(10.7448 - 1.6265 * Math.log(bx) + 0.2839 * (Math.log(bx)) ** 2)
			slug_by = Math.exp(9.774459 - 0.6548 * Math.log(bx))
			if by >= dispersed_by
				flow_regime = "Dispersed/Spray/Mist"
			elsif by >= annular_by and by < dispersed_by
				flow_regime = "Annular"
			elsif by >= slug_by and by < annular_by
				flow_regime = "Slug"
			elsif by < slug_by
				flow_regime = "Stratified"
			end
		end

		if bx >= 80 and bx < 150
			dispersed_by = Math.exp(11.3976 - 0.6084 * Math.log(bx) + 0.0779 * (Math.log(bx)) ** 2)
			annular_by= Math.exp(10.7448 - 1.6265 * Math.log(bx) + 0.2839 * (Math.log(bx)) ** 2)
			slug_by = Math.exp(7.8206 - 0.2189 * Math.log(bx))
			plug_by = Math.exp(9.774459 - 0.6548 * Math.log(bx))
				if by >= dispersed_by
					flow_regime = "DispersedBy/Spray/Mist"
				elsif by >= annular_by and by < dispersed_by
					flow_regime = "Annular"
				elsif by >= slug_by and by < annular_by
					flow_regime = "Slug"
				elsif by >= plug_by and by < slug_by
					flow_regime = "Plug"
				elsif by < plug_by
					flow_regime = "Stratified"
				end
		end

		if bx >= 150 and bx < 2200
			bubble_by = Math.exp(14.569802 - 1.0173 * Math.log(bx))
			slug_by = Math.exp(7.8206 - 0.2189 * Math.log(bx))
			plug_by = Math.exp(9.774459 - 0.6548 * Math.log(bx))
			if by >= bubble_by
				flow_regime =  "Bubble/Froth"
			elsif by >= slug_by and by < bubble_by
				flow_regime = "Slug"
			elsif by >= plug_by and by < slug_by
				flow_regime =  "Plug"
			elsif by >= plug_by
				flow_regime = "Stratified"
			end
		end

		if bx >= 2200 and bx <= 10000
			bubble_by = Math.exp(14.569802 - 1.0173 * Math.log(bx))
			slug_by = Math.exp(7.8206 - 0.2189 * Math.log(bx))
			plug_by = Math.exp(9.774459 - 0.6548 * Math.log(bx))
			if by >= bubble_by
				flow_regime = "BubbleBy"
			elsif by >= slug_by and by < bubble_by
				flow_regime = "Slug"
			elsif by >= plug_by and by < slug_by
				flow_regime = "Plug"
			end
		end
		return flow_regime
	end

	def design_condition_design
		@line_sizing          = LineSizing.find(params[:line_sizing_id])
		source                = @line_sizing.dc_design_basis
		mop                   = @line_sizing.dc_maximum_operating_pressure
		mot                   = @line_sizing.dc_maximum_operating_temperature
		pressure_allowance    = @line_sizing.dc_pressure_allowance
		temperature_allowance = @line_sizing.dc_temperature_allowance
		design_pressure       = 0.0
		design_temperature    = 0.0

		if source == 'source'
			source_design_pressure    = @line_sizing.dc_source_design_pressure
			source_design_temperature = @line_sizing.dc_source_design_temperature
			source_loss               = @line_sizing.dc_source_statice_frictional_dp

			if !source_design_pressure.nil? and source_design_pressure != 0.0
				if !source_loss.nil? and source_loss != 0.0
					design_pressure1 = source_design_pressure+source_loss
				else
					design_pressure2 = source_design_pressure
				end
			end

			design_pressure3 = mop+pressure_allowance

			design_pressure1 = 0.0 if design_pressure1.nil?
			design_pressure2 = 0.0 if design_pressure2.nil?

			design_pressure = [design_pressure1, design_pressure2, design_pressure3].max

			design_temperature1 = mot + temperature_allowance
			design_temperature2 = source_design_temperature
			design_temperature = [design_temperature1, design_temperature2].max

		elsif source == 'destination'
			destination_design_pressure    = @line_sizing.dc_destination_design_pressure
			destination_design_temperature = @line_sizing.dc_destination_design_temperature
			destination_loss               = @line_sizing.dc_destination_statice_frictional_dp

			if !destination_design_pressure.nil? and destination_design_pressure > 0.0
				if !destination_loss.nil? and destination_loss > 0.0
					design_pressure1 = destination_design_pressure+destination_loss
				else
					design_pressure2 = mop+pressure_allowance
				end
			end

			design_pressure3 = mop + pressure_allowance

			design_pressure1 = 0.0 if design_pressure1.nil?
			design_pressure2 = 0.0 if design_pressure2.nil?

			design_pressure = [design_pressure1,design_pressure2,design_pressure3].max
			design_temperature1 = mot+temperature_allowance
			design_temperature2 = destination_design_temperature
			design_temperature = [design_temperature1,design_temperature2].max
		elsif source == 'none'
			design_pressure = mop + pressure_allowance
			design_temperature = mot + temperature_allowance
		end

		b = false
		(1..1000).each do |dxx|
			diff_p = design_pressure - (5.0 * dxx.to_f)
			if diff_p < 5 and diff_p > 0
				diff_p = 5
				design_pressure = (5 * dxx.to_f) + diff_p
				b = true
			elsif diff_p <= 0
				b = true
			end
			break if b
		end

		b = false
		(1..1000).each do |dxx|
			diff_p = design_temperature - (5.0 * dxx)
			if diff_p < 5 and diff_p > 0
				diff_p = 5
				design_temperature = (5 * dxx) + diff_p
				b = true
			elsif diff_p <= 0
				b = true
			end
			break if b
		end
		@line_sizing.update_attributes(
			:dc_design_pressure => design_pressure,
			:dc_design_temperature => design_temperature,
			:dc_spt_design_perssure => design_pressure,
			:dc_spt_design_temperature => design_temperature,
			:dc_pc_design_pressure => design_pressure,
			:dc_pc_design_temperature => design_temperature
		)
		render :json => {:design_pressure => design_pressure, :design_temperature => design_temperature}
	end

	def straight_pipe_thickness_design
		@line_sizing = LineSizing.find(params[:line_sizing_id])
		design_pressure = @line_sizing.dc_spt_design_perssure
		outer_diameter = @line_sizing.dc_spt_pipe_outer_diameter
		allowable_stress = @line_sizing.dc_spt_allowable_stress
		joint_factor = @line_sizing.dc_spt_lweld_joint_factor
		coefficient = @line_sizing.dc_spt_coefficient_y
		pressure_thickness = (design_pressure * outer_diameter) / (2.0 * ((allowable_stress * joint_factor) + (design_pressure * coefficient)))

		mechanical_allowance = @line_sizing.dc_spt_mechanical_thickness_allowance
		corrosion_allowance = @line_sizing.dc_spt_erosion_corrosion_allowance

		mechanical_allowance = 0.0 if mechanical_allowance.nil?
		corrosion_allowance = 0.0 if corrosion_allowance.nil?

		minimum_required_thickness = mechanical_allowance + corrosion_allowance + pressure_thickness
		cf = @line_sizing.project.base_unit_cf(:mtype => 'Length', :msub_type => 'Small Dimension Length')

		pressure_thickness = pressure_thickness.round(cf[:decimals])
		minimum_required_thickness = minimum_required_thickness.round(cf[:decimals])

		render :json => {:pressure_thickness => pressure_thickness, :minimum_required_thickness => minimum_required_thickness}
	end

	def calculate_outer_diameter
		@line_sizing = LineSizing.find(params[:line_sizing_id])
		project = @line_sizing.project
		pipe_size = params[:pipe_size]
		od = PipeSizing.pipe_size_to_pipe_od(pipe_size.to_i,'mm')
		od = @line_sizing.convert_to_project_unit(:dc_spt_pipe_outer_diameter,od.to_f)
		render :json => {:diameter => od}
	end

	private

	def default_form_values

		@line_sizing = @company.line_sizings.find(params[:id]) rescue @company.line_sizings.new
		@comments = @line_sizing.comments
		@new_comment = @line_sizing.comments.new

		@attachments = @line_sizing.attachments
		@new_attachment = @line_sizing.attachments.new

		@project = @user_project_settings.project
		@projects = @company.projects

		p = @project.convert_pipe_roughness_values
		@pipes = p[:pipes]
		@project_pipes = p[:project_pipes]

		@units_of_measurement_obj = @company.unit_of_measurements
		@uom = {}

		@projects.each do |project|
			@uom[project.id.to_s] = {} if @uom[project.id].nil?
			@uom[project.id.to_s]["pressure"] = project.unit('Pressure', 'General')
			@uom[project.id.to_s]["temperature"] = project.unit('Temperature', 'General')
			@uom[project.id.to_s]["density"] = project.unit('Density', 'General')
			@uom[project.id.to_s]["viscosity"] = project.unit('Viscosity', 'Dynamic')
			@uom[project.id.to_s]["flowrate"] = project.unit('Mass Flow Rate', 'General')
			@uom[project.id.to_s]["surface_tension"] = project.unit('Surface Tension', 'General')
			@uom[project.id.to_s]["large_dimension_length"] = project.unit('Length', 'Large Dimension Length')
		end

		@sizing_criteria_category_types = SizingCriteriaCategoryType.where("sizing_criteria_categories.company_id = ?", @company.id).joins(:sizing_criteria_category).all

		@sizing_criteria_category_types_data = {}

		@sizing_criteria_category_types.each do |sizing_criteria_category_type|
			@sizing_criteria_category_types_data[sizing_criteria_category_type.sizing_criteria_category_id] = {} if @sizing_criteria_category_types_data[sizing_criteria_category_type.sizing_criteria_category_id].nil?

			@sizing_criteria_category_types_data[sizing_criteria_category_type.sizing_criteria_category_id][sizing_criteria_category_type.id] = sizing_criteria_category_type.name;
		end

		@two_phase_flow_dropdown = @line_sizing.target_two_phase_regime rescue []
	end
end
