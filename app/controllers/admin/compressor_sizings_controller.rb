class Admin::CompressorSizingsController < AdminController

	#TODO Remove redundant code
	before_filter :default_form_values, :only => [:new, :create, :edit, :update]

	def index
		@compressor_sizing_tags = @company.compressor_sizing_tags.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))

		if @user_project_settings.client_id.nil?     
			flash[:error] = "Please Update Project Setting"      
			redirect_to admin_sizings_path
		end
	end

	def new
		@compressor_sizing_tag = @company.compressor_sizing_tags.new
		@compressor_sizing = CompressorSizing.new
	end

	def create
		compressor_sizing_tag = params[:compressor_sizing_tag]
		compressor_sizing_tag[:created_by] = compressor_sizing_tag[:updated_by] = current_user.id    
		params[:compressor_sizing][:suction_pipings_attributes] = params[:suction_pipings].values
		@compressor_sizing_tag = @company.compressor_sizing_tags.new(compressor_sizing_tag)    

		if @compressor_sizing_tag.save
      @compressor_sizing_tag.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
			if request.xhr?
				render :json => {:compressor_sizing_id => @compressor_sizing_tag.id}
			else
				flash[:notice] = "New compressor sizing created successfully."
				redirect_to edit_admin_compressor_sizing_path(@compressor_sizing_tag)
			end
		else
			render :new
		end
	end

	def edit
		@compressor_sizing_tag = @company.compressor_sizing_tags.find(params[:id])    

		@compressor_sizing_mode_id = params[:compressor_sizing_mode]    
		@compressor_sizing = CompressorSizing.where(:compressor_sizing_mode_id=>@compressor_sizing_mode_id).first    
		if @compressor_sizing.nil?
			@compressor_sizing = CompressorSizing.new({:compressor_sizing_tag_id=>params[:id], :compressor_sizing_mode_id=>@compressor_sizing_mode_id})
			@compressor_sizing.save if !@compressor_sizing_mode_id.nil?
		end

		@compressor_sizing_tag.compressor_sizings.update_all(:selected_sizing => false)
		@compressor_sizing.update_attributes({:selected_sizing => true})

		if !@compressor_sizing.process_basis_id.nil?
			heat_and_meterial_balance = HeatAndMaterialBalance.find(@compressor_sizing.process_basis_id)
			@streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
		end
	end

	def update
		compressor_sizing_tag = params[:compressor_sizing_tag]
		compressor_sizing_tag[:updated_by] = current_user.id
		params[:compressor_sizing][:suction_pipings_attributes] = params[:suction_pipings].values
		params[:discharges].values.each do |d| 
			d[:discharge_circuit_piping_attributes] = d[:circuit_piping].values
			d.delete(:circuit_piping)
		end
		params[:compressor_sizing][:compressor_sizing_discharges_attributes] = params[:discharges].values
		#raise params[:discharges].to_yaml

		compressor_sizing = params[:compressor_sizing]

		@compressor_sizing_tag = @company.compressor_sizing_tags.find(params[:id])    
		@compressor_sizing = CompressorSizing.where(:compressor_sizing_mode_id=>compressor_sizing[:compressor_sizing_mode_id]).first   

		if !@compressor_sizing.nil? && !@compressor_sizing.process_basis_id.nil? 
			heat_and_meterial_balance = HeatAndMaterialBalance.find(@compressor_sizing.process_basis_id)
			@streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
		end

		if @compressor_sizing_tag.update_attributes(compressor_sizing_tag) && @compressor_sizing.update_attributes(compressor_sizing)
			if request.xhr?
				flash[:notice] = "Updated compressor sizing successfully."
				render :json => {:compressor_sizing_id => @compressor_sizing.id}
			else
				flash[:notice] = "Updated compressor sizing successfully."
				redirect_to admin_compressor_sizings_path       
			end
		else      
			render :edit
		end
	end

	def destroy
		@compressor_sizing_tag = @company.compressor_sizing_tags.find(params[:id])
		if @compressor_sizing_tag.destroy
			flash[:notice] = "Deleted #{@compressor_sizing_tag.compressor_sizing_tag} successfully."
			redirect_to admin_compressor_sizings_path
		end
	end

	def clone
		@compressor_sizing_tag = @company.compressor_sizing_tags.find(params[:id])
		new_tag = @compressor_sizing_tag.clone
		@compressor_sizing = @compressor_sizing_tag.compressor_sizings[0]
		new_sizing = @compressor_sizing.deep_clone([
												"suction_pipings",
												"compressor_sizing_discharges",
												"compressor_reciprocation_designs",
												"compressor_centrifugal_designs"
												])
		new_tag.compressor_sizing_tag = params[:tag]
		new_tag.compressor_sizings << new_sizing
		if new_tag.save
			render :json => {:error => false, :url => edit_admin_compressor_sizing_path(new_tag) }
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
		form_values[:pressure_value] = pressure_stream.stream_value.to_f rescue nil

		temperature = property.where(:phase => "Overall", :property => "Temperature").first
		temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
		form_values[:temperature_value] = temperature_stream.stream_value.to_f rescue nil

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
		form_values[:pressure] = pressure_stream.stream_value.to_f rescue nil

		render :json => form_values
	end

	def clone_circuit_piping

		src_circuit_pipings = CompressorSizingDischarge.find(params[:src_circuit_piping]).discharge_circuit_piping
		trg_compressor_sizing_discharge = CompressorSizingDischarge.find(params[:trg_cricuit_piping])

		trg_compressor_sizing_discharge.discharge_circuit_piping.delete_all

		src_circuit_pipings.each do |circuit_piping|
			DischargeCircuitPiping.create({
				:discharge_circuit_pipings_id => trg_compressor_sizing_discharge.id,
				:discharge_circuit_pipings_type => "CompressorSizingDischarge",
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

		render :json => {:success=>true}    
	end

	def compressor_sizing_summary
		@compressor_sizings = @company.compressor_sizing_tags.all    
	end

	def add_compressor_sizing_mode
		@compressor_sizing_tag = @company.compressor_sizing_tags.find(params[:compressor_sizing_tag_id])  
		@compressor_sizing_tag.compressor_sizing_modes.create({:mode_name=>params[:mode_name]})
		@compressor_sizing_tag.save
	end

	def edit_compressor_sizing_mode    
		@compressor_sizing_mode = CompressorSizingMode.find(params[:id])
		@compressor_sizing_mode.update_attributes({:mode_name=>params[:mode_name]})  
	end

	def delete_compressor_sizing_mode
		@compressor_sizing_mode = CompressorSizingMode.find(params[:id])
		@compressor_sizing_mode.destroy
	end

	def set_breadcrumbs
		super
		@breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
		@breadcrumbs << { :name => 'Compressor sizings', :url => admin_compressor_sizings_path }
	end

	def suction_pipings
		@suction_piping = SuctionPiping.new
		@unique_id = Time.now.to_i
		render :partial => "suction_piping"
	end

	def discharges
		@discharge = CompressorSizingDischarge.new
		@unique_id = @discharge.object_id
		render :partial => "discharge"
	end

	#render a new row for discharge circuit piping
	def discharge_circuit_pipings
		@discharge_circuit_piping = DischargeCircuitPiping.new
		@unique_id = params[:unique_id]
		render :partial => "discharge_circuit_piping_row"
	end

	#render a table for discharge circuit piping
	#unique id is specific to a discharge
	def discharge_circuit_piping_div
		@discharge_circuit_piping = DischargeCircuitPiping.new
		@unique_id = params[:unique_id]
		@unique_id1 = @discharge_circuit_piping.object_id
		render :partial => "discharge_circuit_piping_table"
	end

	#calculation actions
	def suction_calculate
		@compressor_sizing = CompressorSizing.find(params[:compressor_sizing_id])
		project = @compressor_sizing.compressor_sizing_tag.project

		pipeid                     = (1..100).to_a
		length                     = (1..100).to_a
		flow_percentage            = (1..100).to_a
		reynold_number             = (1..100).to_a
		ft                         = (1..100).to_a
		kfi                        = (1..100).to_a
		dover_di                   = (1..100).to_a
		nre                        = (1..100).to_a
		kfii                       = (1..100).to_a
		kfd                        = (1..100).to_a
		f                          = (1..100).to_a
		kff                        = (1..100).to_a
		doverdii                   = (1..100).to_a
		elevation                  = (1..100).to_a
		pressure_drop              = (1..100).to_a
		inlet_pressure             = (1..100).to_a
		inlet_temperature          = (1..100).to_a
		section_outlet_pressure    = (0..100).to_a
		section_outlet_temperature = (0..100).to_a
		fittings                   = (1..100).to_a
		fittingdp                  = (1..100).to_a
		pi = 3.14159265358979
		barometric_pressure = project.barometric_pressure
		pipe_roughness = project.pipes[0].roughness_recommended
		e = pipe_roughness
		e = e / 12
		count = @compressor_sizing.suction_pipings.length
		circuit_pipings = @compressor_sizing.suction_pipings

		mass_flow_rate = @compressor_sizing.su_mass_flow_rate
		pressure       = @compressor_sizing.su_pressure
		temperature    = @compressor_sizing.su_temperature
		viscosity      = @compressor_sizing.su_vapor_viscosity
		vapor_mw       = @compressor_sizing.su_vapor_mw
		vapor_k        = @compressor_sizing.su_vapor_k
		vapor_z        = @compressor_sizing.su_vapor_z

		relief_rate = mass_flow_rate
		relief_pressure = pressure
		relief_temperature = temperature


		(0..count-1).each do |p|
			circuit_piping = circuit_pipings[p]
			fitting           = circuit_piping.fitting
			fitting_tag       = circuit_piping.fitting_tag
			pipe_size         = circuit_piping.pipe_size
			pipe_schedule     = circuit_piping.pipe_schedule
			pipe_id           = circuit_piping.pipe_id
			per_flow          = circuit_piping.per_flow
			fitting_length    = circuit_piping.length
			fitting_elevation = circuit_piping.elev
			cv = circuit_piping.ds_cv

			relief_rate1 = relief_rate * (flow_percentage[p] / 100)
			nre[p] = (0.52633 * relief_rate1) / (pipeid[p] * viscosity)

			a = (2.457 * Math.log(1.0 / (((7.0 / nre[p]) ** 9.0) + (0.27 * (e / pipeid[p]))))) ** 16.0
			#TODO 0.9 changed to 9 to avoid complex number
			b = (37530 / nre[p]) ** 16.0
			f[p] = 2.0 * ((8.0 / nre[p]) ** 12.0 + ( 1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0) 
			p_drop = 0

			fd        = 4.0 * f[p]
			nreynolds = nre[p]
			d         = pipe_id
			d1        = pipe_id
			d2        = per_flow

			fitting_type = PipeSizing.get_fitting_tag(circuit_piping.fitting)[:value]
			if fitting_type == 'Pipe'
				kf = 4.0 * f[p] * (length[p]/pipeid[p])
			elsif fitting_type == "Control Valve" and p_drop == ""
				kf = ((29.9 * d ** 2.0)/ cv) ** 2.0
			elsif fitting_type == "Orifice" and p_drop == ""
				beta = cv_dorifice / d
				if nreynolds <= 10.0 ** 4.0
					#UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientLR.Show
					#FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
				elsif nreynolds > 10.0 ** 4.0
					#UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientHR.Show
					#FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
				end
				#TODO dummy value
				flow_c = 1.0
				kf = (1.0 - beta ** 2.0) / (flow_c ** 2.0 * beta ** 4.0)
			elsif fitting_type == "Equipment"
				p_drop = ""
			elsif fitting_type == "Control Valve" and p_drop != ""
				p_drop = ""
			elsif fitting_type == "Orifice" and p_drop != ""
				p_drop = ""
			else
				result = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)
				dover_d = result[:dover_d]
				kfii[p] = result[:kf]
				doverdii[p] = dover_d
			end

			choke_counter = 0
			sumkff = 0
			sumkff = sumkff + kff[p]
			pipeid[p] = pipe_id
			inlet_pressure[1] = relief_pressure
			inlet_temperature[1] = relief_temperature
			#determine g
			area = (pi / 4.0) * (pipeid[p]) ** 2.0
			mass_velocity = relief_rate1/area
			if project.vapor_flow_model == "Isothermic"
				part1 = (inlet_pressure[p] + barometric_pressure) ** 2.0
				part2 = (7.41109 * 10.0 ** -6.0 * (relief_temperature + 459.67) * mass_velocity ** 2.0) / vapor_mw
				part3 = sumkff/2.0
				initial_outlet_pressure = (part1 - (part2 * part3)) ** 0.5
				(1..100).each do |gg|
					part4 = Math.log((inlet_pressure[p] + barometric_pressure) / initial_outlet_pressure) # 'Log is natural log (aka ln())
					#TODO using dummy value
					#part4 = 10.0
					section_outlet_pressure[gg] = (part1 - part2 * (part3 + part4)) ** 0.5
					initial_outlet_pressure = section_outlet_pressure[gg]
					if section_outlet_pressure[gg] ==  section_outlet_pressure[gg - 1]
						inlet_pressure[p+1] = section_outlet_pressure[gg] - barometric_pressure
					end              
				end   
				#Determine sonic downstream pressure at each fitting along the system
				#Check for choked flow
				p1 = inlet_pressure[p]
				p2 = inlet_pressure[p+1]
				pressure_drop = p1 - p2
				(1..1000).each do |r|
					p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
					part1 = ((p1 + barometric_pressure) / p2_critical) ** 2.0
					part2 = 2.0 ** Math.log((p1 + barometric_pressure) / p2_critical)
					isothermal_choke_kf = part1 - part2 - 1
					isothermal_choke_kf = 10.0
					if sumkff <= isothermal_choke_kf
						break
					end
				end
				#Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
			elsif project.vapor_flow_model == "Adiabatic"
				part1 = vapor_k / (vapor_k + 1)
				part2 = 269866 * (vapor_k / (vapor_k + 1))
				part3 = ((inlet_pressure[p] + barometric_pressure) ** 2.0 * vapor_mw) / (inlet_temperature[p] + 459.67)
				part4 = mass_velocity ** 2.0 * (sumkff / 2.0)
				initial_outlet_pressure = (inlet_pressure[p] + barometric_pressure) * (1.0 - (part4 / (part2 * part3))) ** part1
				(1..100).each do |gg|
					part5 = Math.log(inlet_pressure[p] + barometric_pressure / initial_outlet_pressure) / vapor_k
					part6 = mass_velocity ** 2.0 * ((sumkff / 2.0) + part5)
					section_outlet_pressure[gg] = (inlet_pressure[p] + barometric_pressure) * ( 1 - (part6 / (part2 * part3))) ** part1
					section_outlet_temperature[gg] = (inlet_temperature[p] + 459.69) * (section_outlet_pressure[gg] / (inlet_pressure[p] + barometric_pressure)) ** (( vapor_k -1) / vapor_k)
					initial_outlet_pressure = section_outlet_pressure[gg]
					if section_outlet_pressure == section_outlet_pressure[gg -1]
						inlet_pressure[p +1] = section_outlet_pressure[gg] - barometric_pressure
						inlet_temperature[p +1] = section_outlet_temperature[gg] - 459.69
						#TODO need reiview
						#Worksheets("FE Circuit").Cells(15720 + nn, 91).Value = InletPress(nn + 1)
						#Worksheets("FE Circuit").Cells(15720 + nn, 94).Value = InletTemp(nn + 1)
						gg = 100
					end
				end
				#Determine sonic downstream pressure at each fitting along the system
				#Check for choked flow
				#P1 = InletPress(nn)
				#P2 = InletPress(nn + 1)
				p1 = inlet_pressure[p]
				p2 = inlet_pressure[p+1]
				pressure_drop = p1 - p2
				(0..1000).each do |r|
					p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
					part1 = 2.0 / (vapor_k +1)
					part2 = (((p1 + barometric_pressure) / p2_critical) ** ((vapor_k + 1) / vapor_k)) -1
					part3 = (2.0 / vapor_k) * Math.log((p1 + barometric_pressure) / p2_critical)
					adiabatic_choke_kf = (part1 * part2) - part3
					break if sumkff <= adiabatic_choke_kf
				end
				# Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
			end
			#TODO pressure drop is generating complex number
			circuit_piping.update_attributes(:delta_p => pressure_drop)
		end
		@compressor_sizing.calculate_suction_dps
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else
		render :json => {:success => true }
	end

	def discharge_calculate
		@compressor_sizing = CompressorSizing.find(params[:compressor_sizing_id])
		project = @compressor_sizing.compressor_sizing_tag.project

		pipeid                    = (1..1000).to_a
		length                    = (1..1000).to_a
		flow_percentage           = (1..1000).to_a
		nre                       = (1..1000).to_a
		ft                        = (1..1000).to_a
		kfi                       = (1..1000).to_a
		kff                       = (1..1000).to_a
		kfperdiameter             = (1..1000).to_a
		doverdi                   = (1..1000).to_a
		elevation                 = (1..1000).to_a
		pressure_drop             = (1..1000).to_a
		fitting_s                 = (1..1000).to_a
		fitting_dp                = (1..1000).to_a
		fitting_circuit           = (1..1000).to_a
		path_stream               = (1..1000).to_a
		circuit_list              = (1..1000).to_a
		outlet_pressure           = (0..1000).to_a
		outlet_temperature        = (0..1000).to_a
		section_inlet_pressure    = (0..1000).to_a
		section_inlet_temperature = (0..1000).to_a

		pi = 3.14159265358979
		barometric_pressure = project.barometric_pressure
		pipe_roughness = project.pipes[0].roughness_recommended
		e = pipe_roughness
		e = e / 12.0

		mass_flow_rate = @compressor_sizing.su_mass_flow_rate
		pressure       = @compressor_sizing.su_pressure
		temperature    = @compressor_sizing.su_temperature
		viscosity      = @compressor_sizing.su_vapor_viscosity
		vapor_mw       = @compressor_sizing.su_vapor_mw
		vapor_k        = @compressor_sizing.su_vapor_k
		vapor_z        = @compressor_sizing.su_vapor_z
		relief_rate = mass_flow_rate
		relief_pressure = pressure
		relief_temperature = temperature

		@compressor_sizing.compressor_sizing_discharges.each do |discharge|
			count = discharge.discharge_circuit_piping.length
			circuit_pipings = discharge.discharge_circuit_piping
			(0..count-1).each do |p|
				circuit_piping = circuit_pipings[p]
				fitting           = circuit_piping.fitting
				fitting_tag       = circuit_piping.fitting_tag
				pipe_size         = circuit_piping.pipe_size
				pipe_schedule     = circuit_piping.pipe_schedule
				pipe_id           = circuit_piping.pipe_id
				per_flow          = circuit_piping.per_flow
				fitting_length    = circuit_piping.length
				fitting_elevation = circuit_piping.elev
				cv = circuit_piping.ds_cv

				relief_rate1 = relief_rate * (flow_percentage[p] / 100)
				nre[p] = (0.52633 * relief_rate1) / (pipeid[p] * viscosity)

				a = (2.457 * Math.log(1.0 / (((7.0 / nre[p]) ** 9.0) + (0.27 * (e / pipeid[p]))))) ** 16.0 
				#TODO 0.9 changed to 9 to avoid complex number
				b = (37530 / nre[p]) ** 16.0
				ft[p] = 2.0 * ((8.0 / nre[p]) ** 12.0 + ( 1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0) 
				p_drop = 0

				fd        = 4.0 * ft[p]
				nreynolds = nre[p]
				d         = pipe_id
				d1        = pipe_id
				d2        = per_flow

				fitting_type = PipeSizing.get_fitting_tag(circuit_piping.fitting)[:value]
				if fitting_type == 'Pipe'
					kf = 4.0 * f[p] * (length[p]/pipeid[p])
				elsif fitting_type == "Control Valve" and p_drop == ""
					kf = ((29.9 * d ** 2.0)/ cv) ** 2.0
				elsif fitting_type == "Orifice" and p_drop == ""
					beta = cv_dorifice / d
					if nreynolds <= 10.0 ** 4.0
						#UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2)
						#UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
						#UserFormOrificeCoefficientLR.Show
						#FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
					elsif nreynolds > 10.0 ** 4.0
						#UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
						#UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
						#UserFormOrificeCoefficientHR.Show
						#FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
					end
					#TODO dummy value
					flow_c = 1.0
					kf = (1.0 - beta ** 2.0) / (flow_c ** 2.0 * beta ** 4.0)
				elsif fitting_type == "Equipment"
					p_drop = ""
				elsif fitting_type == "Control Valve" and p_drop != ""
					p_drop = ""
				elsif fitting_type == "Orifice" and p_drop != ""
					p_drop = ""
				else
					result = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)
					dover_d = result[:dover_d]
					kfi[p] = result[:kf]
				end

				sumkff = 0
				#PipeID(h) = Worksheets("Compressor Circuit").Cells(15774 - h + CircuitPipingCount, 84).Value
   				#Kff(h) = Worksheets("Compressor Circuit").Cells(15774 - h + CircuitPipingCount, 91).Value
				pipeid[p] = pipe_id
				sumkff = sumkff + kff[p]

				#determine g
				area = (pi / 4.0) * (pipeid[p]) ** 2.0
				mass_velocity = relief_rate1/area
				if project.vapor_flow_model == "Isothermic"
					part1 = (outlet_pressure[p] + barometric_pressure) ** 2.0
					part2 = (7.41109 * 10.0 ** -6 * (relief_temperature + 459.67) * mass_velocity ** 2.0) / vapor_mw
					part3 = sumkff/2.0
					initial_inlet_pressure = (part1 - (part2 * part3)) ** 0.5
					(1..100).each do |gg|
						part4 = Math.log(initial_inlet_pressure / (outlet_pressure[p-1] + barometric_pressure)) # 'Log is natural log (aka ln())
						section_inlet_pressure[gg] = (part1 - part2 * (part3 + part4)) ** 0.5
						initial_inlet_pressure = section_inlet_pressure[gg]
						if section_inlet_pressure[gg] ==  section_inlet_pressure[gg - 1]
							outlet_pressure[p+1] = section_inlet_pressure[gg] - barometric_pressure
							break
						end              
					end   
					#Determine sonic downstream pressure at each fitting along the system
					#Check for choked flow
					p1 = outlet_pressure[p-1]
					p2 = outlet_pressure[p]
					pressure_drop[p] = p2 - p1
					(1..1000).each do |r|
						p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
						part1 = ((p1 + barometric_pressure) / p2_critical) ** 2.0
						part2 = 2.0 ** Math.log((p1 + barometric_pressure) / p2_critical)
						isothermal_choke_kf = part1 - part2 - 1
						break if sumkff <= isothermal_choke_kf
					end
					#Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
				elsif project.vapor_flow_model == "Adiabatic"
					part1 = vapor_k / (vapor_k + 1)
					part2 = 269866 * (vapor_k / (vapor_k + 1))
					part3 = ((outlet_pressure[p-1] + barometric_pressure) ** 2.0 * vapor_mw) / (outlet_temperature[p] + 459.67)
					part4 = mass_velocity ** 2.0 * (sumkff / 2.0)
					initial_inlet_pressure = (outlet_pressure[p] + barometric_pressure) * (1 - (part4 / (part2 * part3))) ** part1
					(1..100).each do |gg|
						part5 = Math.log(outlet_pressure[p] + barometric_pressure / initial_inlet_pressure) / vapor_k
						part6 = mass_velocity ** 2.0 * ((sumkff / 2.0) + part5)
						section_inlet_pressure[gg] = (outlet_pressure[p] + barometric_pressure) * ( 1 - (part6 / (part2 * part3))) ** part1
						section_inlet_temperature[gg] = (outlet_temperature[p] + 459.69) * (section_inlet_pressure[gg] / (outlet_pressure[p-1] + barometric_pressure)) ** (( vapor_k -1) / vapor_k)
						initial_inlet_pressure = section_inlet_pressure[gg]
						if section_inlet_pressure == section_inlet_pressure[gg -1]
							outlet_pressure[p] = section_outlet_pressure[gg] - barometric_pressure
							outlet_temperature[p] = section_outlet_temperature[gg] - 459.69
							#TODO need reiview
							#Worksheets("FE Circuit").Cells(15720 + nn, 91).Value = InletPress(nn + 1)
							#Worksheets("FE Circuit").Cells(15720 + nn, 94).Value = InletTemp(nn + 1)
							break
						end
					end
					#Determine sonic downstream pressure at each fitting along the system
					#Check for choked flow
					p1 = outlet_pressure[p-1]
					p2 = outlet_pressure[p]
					pressure_drop[p] = p2 - p1
					(0..1000).each do |r|
						p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
						part1 = 2.0 / (vapor_k +1)
						part2 = (((p1 + barometric_pressure) / p2_critical) ** ((vapor_k + 1) / vapor_k)) -1
						part3 = (2.0 / vapor_k) * Math.log((p1 + barometric_pressure) / p2_critical)
						adiabatic_choke_kf = (part1 * part2) - part3
						break if sumkff <= adiabatic_choke_kf
					end
					# Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
				end
				circuit_piping.update_attributes(:delta_p => pressure_drop[p])
			end
			discharge.calculate_suction_dps
		end
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else
		render :json => {:success => true }
	end

	def centrifugal_design_calculate
		@compressor_sizing = CompressorSizing.find(params[:compressor_sizing_id])
		project = @compressor_sizing.compressor_sizing_tag.project
		centrifugal_design = @compressor_sizing.compressor_centrifugal_designs.find(params[:section_id])

		barometric_pressure = project.barometric_pressure.to_f

		mass_rate = centrifugal_design.suction_mass_flow_rate
		w = mass_rate / 60
		temperature = centrifugal_design.suction_temperature
		t1 = temperature = 459.67
		p1 = centrifugal_design.suction_pressure
		pressure = p1
		vapor_z = centrifugal_design.suction_vapor_z
		vapor_mw = centrifugal_design.suction_vapor_mw
		vapor_k = centrifugal_design.suction_vapor_z
		compression_ratio = centrifugal_design.compression_ratio
		compression_path = @compressor_sizing.cd_compression_path
		efficiency = centrifugal_design.efficiency

		#Performance Calculations
		#Determine on inlet volume rate
		volume_rate = (w * 1545 * t1 * vapor_z) / (vapor_mw * p1 * 144)

		polyeff = 0.0
		iseneff = 0.0


		#determine efficiency
		if volume_rate >= 100 and volume_rate < 500
			polyeff = 0.7
			iseneff = 0.67
			nominalspeed = 20500
		elsif volume_rate >= 500 and volume_rate <= 7500
			polyeff = 0.8
			iseneff = 0.78
			nominalspeed = 10500
		elsif volume_rate >= 7500 and volume_rate <= 20000
			polyeff = 0.86
			iseneff = 0.83
			nominalspeed = 8200
		elsif volume_rate >= 20000 and volume_rate <= 33000
			polyeff = 0.86
			iseneff = 0.83
			nominalspeed = 6500
		elsif volume_rate >= 33000 and volume_rate <= 55000
			polyeff = 0.86
			iseneff = 0.83
			nominalspeed = 4900
		elsif volume_rate >= 55000 and volume_rate <= 80000
			polyeff = 0.86
			iseneff = 0.83
			nominalspeed = 4300
		elsif volume_rate >= 80000 and volume_rate <= 115000
			polyeff = 0.86
			iseneff = 0.83
			nominalspeed = 3600
		elsif volume_rate >= 115000 and volume_rate <= 145000
			polyeff = 0.86
			iseneff = 0.83
			nominalspeed = 2800
		elsif volume_rate >= 145000 and volume_rate <= 200000
			polyeff = 0.86
			iseneff = 0.83
			nominalspeed = 2500
		end


		if compression_path == "polytrophic"
			efficiency = iseneff * 100
		else
			efficiency = polyeff * 100
		end

		#determine compression ratio
		#
		#
		#determine differential pressure
		discharge_p = (p1 * compression_ratio) - barometric_pressure
		suction_p = pressure
		diff_pressure = discharge_p - suction_p

		if discharge_p <= suction_p
			#MsgBox("The pressure to the suction of the compressor is determined greater than or equal to the pressure at the discharge of the compressor.  Therefore, no compression is expected.  Please review the input data for accuracy or select an alternate design path.", vbOKOnly, "Inappropriate Compressor Differential Advisory!")
		end

		if compression_path == "isentropic"
			vapor_z2 = centrifugal_design.discharge_vapor_z
			vapor_z = (vapor_z + vapor_z2) / 2.0

			vapor_k2 = centrifugal_design.discharge_vapor_k
			vapor_k = (vapor_k + vapor_k2) / 2.0

			part1 = (1545 / vapor_mw)
			part2 = (vapor_z * t1) / ((vapor_k - 1.0) / vapor_k)
			part3 = ((p2 / p1) ** ((vapor_k - 1.0) / vapor_k)) - 1.0
			diff_head = part1 * part2 * part3
			safety_factor  = project.compressor_design_safety_factor.to_f
			safety_factor_head = diff_head * safety_factor
			required_head = diff_head + safety_factor_head

			#Gas horsepower
			nis = efficiency / 100.0

			gas_hp = (w * diff_head) / (nis * 33000.0)

			#Mechanical loss
			mechanical_loss = gas_hp ** 0.4

			#Break horse power
			break_hp = gas_hp + mechanical_loss

			#Determine temperature
			deltat = t1 * (((((p2 / p1) ** ((vapor_k - 1) / vapor_k)) - 1)) / nis)
			t2 = (t1 + deltat) - 459.67
		elsif compression_path == "polytropic"
			np = efficiency/100
			aa = (vapor_k / (vapor_k - 1)) * np
			n = -aa / (1 - aa)
			vapor_z2 = centrifugal_design.discharge_vapor_z
			vapor_z = (vapor_z + vapor_z2) / 2.0
			part1 = (1545 / vapor_mw)
			part2 = (vapor_z * t1) / ((n - 1) / n)
			part3 = ((p2 / p1) ** ((n - 1) / n)) - 1
			diff_head = part1 * part2 * part3
			safety_factor  = project.compressor_design_safety_factor.to_f
			safety_factor_head = diff_head * safety_factor
			required_head = diff_head + safety_factor_head
			raise required_head.to_yaml

			#Gas horsepower
			gas_hp = (w * diff_head) / (np * 33000)

			#Mechanical loss
			mechanical_loss = gas_hp ** 0.4

			#Break horse power
			break_hp = gas_hp + mechanical_loss

			#determine temperature
			t2 = (t1 * ((p2 / p1) ** ((n - 1.0) / n))) - 459.67
		end

		#Determine max head per stage
		hmax_stage = 15000 - 1500 * vapor_mw ** 0.35

		#TODO dummy value
		no_of_wheel = 3

		#Determine head per impeller
		head_per_impeller = required_head / no_of_wheel

		#Determine stage speed
		speed = nominal_speed * (required_head / (no_of_wheel * hmax_stage)) ** 0.5

		centrifugal_design.update_attributes(
			:speed => speed,
			:discharge_pressure => discharge_p,
			:discharge_temperature => t2,
			:differential_pressure => differential_pressure,
			:differential_head => diff_head,
			:safety_factor => safety_factor_head,
			:required_differential_head => required_head,
			:max_head_stage => hmax_stage,
			:head_per_impeller => head_per_impeller,
			:gas_hp => gas_hp,
			:mechanical_losses => mechanical_losses,
			:brake_horsepower => break_hp
		)


	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else 
		render :json => {:success=>true}    
	end

	def reciprocation_design_calculate
		pi = 3.14159265358979
		@compressor_sizing = CompressorSizing.find(params[:compressor_sizing_id])
		project = @compressor_sizing.compressor_sizing_tag.project
		reciprocation_design = @compressor_sizing.compressor_reciprocation_designs.find(params[:section_id])

		barometric_pressure = project.barometric_pressure.to_f

		#standard conditions
		pl = @compressor_sizing.rd_standard_pressure
		tl = @compressor_sizing.rd_standard_temperature + 459.67


		#mechanical specification
		cylinder_no = reciprocation_design.no_of_cylinders
		pd_type = reciprocation_design.type
		bore = reciprocation_design.bore
		stroke = reciprocation_design.stroke
		rod = reciprocation_design.rod_diameter
		speed = reciprocation_design.piston_speed
		clearance = reciprocation_design.clearance
		mass_rate = @compressor_sizing.su_mass_flow_rate
		w = mass_rate / 60
		t1 = reciprocation_design.suction_temperature + 459.67
		p1 = reciprocation_design.suction_pressure + barometric_pressure
		pressure = p1
		vapor_mw = reciprocation_design.suction_vapor_mw
		vapor_z = reciprocation_design.suction_vapor_z
		vapor_k = reciprocation_design.suction_vapor_k

		compressor_lubrication = @compressor_sizing.rd_compressor_lubrication
		lube_factor = @compressor_sizing.rd_volumetric_cf
		gas_service = @compressor_sizing.rd_gas_service
		gas_factor = @compressor_sizing.rd_gs_volumetric_cf

		discharge_vapor_z = reciprocation_design.discharge_vapor_z

		#Swept Volume
		swept_volume = pi * (bore ** 2.0 / 4.0) * stroke

		#Suction Bottle Sizes
		suction_multiplier = 0.000000000000005 * p1 ** 5.0 - 0.000000000015516 * p1 ** 4.0 + 0.00000002080644 * p1 ** 3.0 - 0.000008728648653 * p1 ** 2.0 + 0.000832919778816 * p1 + 7.01286020627231
		suction_multiplier = suction_multiplier.round(1)
		suction_volume = suction_multiplier * swept_volume

		#Discharge Bottle Sizes
		discharge_multiplier = -0.000000000000012 * p1 ** 5.0 + 0.000000000025364 * p1 ** 4.0 - 0.000000021919563 * p1 ** 3.0 + 0.000008768725059 * p1 ** 2.0 - 0.001333127592261 * p1 + 5.0124434403524
		discharge_multiplier = discharge_multiplier.round(1)
		discharge_volume = discharge_multiplier * swept_volume

		vapor_z = reciprocation_design.suction_vapor_z

		compression_ratio = reciprocation_design.compression_ratio

		#Determine Differential Pressure
		discharge_p = (p1 * compression_ratio) - barometric_pressure
		p2 = p1 * compression_ratio
		suction_p = pressure
		diff_pressure = discharge_p - suction_p

		#Performance Calculations
		#Determine on inlet volume rate
		volume_rate = (w * 1545 * t1 * vapor_z) / (vapor_mw * p1 * 144)

		cylinderno = reciprocation_design.no_of_cylinders

		#determine piston displacement
		if pd_type == "SA-TE"
			pd = cylinderno * (4.55 * 10 ** -4) * stroke * speed * bore ** 2.0
			pdtype_description = "Single Acting - Head End"
		elsif pdtype == "SA-CE"
			pd = cylinderno * (4.55 * 10 ** -4) * stroke * speed * (bore ** 2.0 - rod ** 2.0)
			pdtype_description = "Single Acting - Crank End"
		elsif pdtype == "DA"
			pd = cylinderno * (4.55 * 10 ** -4) * stroke * speed * (2.0 * bore ** 2.0 - rod ** 2.0)
			pdtype_description = "Double Acting"
		end

		part1 = (vapor_z / discharge_z) * compression_ratio ** (1 / vapor_k) - 1
		ve = 96 - lube_factor - gas_factor - compression_ratio - (clearance * part1)

	    #Determine Theoretical Discharge Temperature (Td)
		deltat = t1 * (compression_ratio ** ((vapor_k - 1) / vapor_k)) - 1
		t2 = t1 + deltat

	    #Determine Compressor Capacity
        capacity = (pd * ve * p1 * 10 ** -6) / vapor_z            #assume z @ 14.4 is 1.0
	    compressor_capacity = capacity * (14.4 / standard_pressure) * (standard_temperature / t1) * (1 / vapor_z)  #note that standard z is assumed equal to 1

       #Determine Stage HP
	   zavg = (vapor_z + discharge_vapor_z) * 0.5

       bhp_stage = 3.03 + zavg * ((compressor_capacity * t1) / e) * (vapor_k / (vapor_k - 1)) * (pl / tl) * ((p2 / p1) ** ((vapor_k - 1) / vapor_k) - 1)
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else 
		render :json => {:success=>true}    


	end

	def cd_interstage_piping_calculate
		model = CompressorCentrifugalDesign.find(params[:section_id])
		suction_piping_calculate(model)
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else
		render :json => {:success => true}
	end

	def rd_interstage_piping_calculate
	    model = CompressorReciprocationDesign.find(params[:section_id])
		suction_piping_calculate(model)
	rescue Exception => e
		render :json => {:success => false, :error => "Error\n#{e.to_s}\n#{e.backtrace.join("\n")}"}
	else
		render :json => {:success => true}
	end

	private

	def default_form_values
    @compressor_sizing_tag = @company.compressor_sizing_tags.find(params[:id]) rescue @company.compressor_sizing_tags.new
    @comments = @compressor_sizing_tag.comments
    @new_comment = @compressor_sizing_tag.comments.new

    @attachments = @compressor_sizing_tag.attachments
    @new_attachment = @compressor_sizing_tag.attachments.new

		@project = @user_project_settings.project
		@streams = []    
	end


	#each centrifugal design and reciprocation design has its own suction piping
	#this method is used for calculation of both
	#params model should be centrifugal design or reciprocation design
	#this calculates the interstage delta p
	#
	def suction_piping_calculate(model)
		pipeid                     = (1..100).to_a
		length                     = (1..100).to_a
		flow_percentage            = (1..100).to_a
		reynold_number             = (1..100).to_a
		ft                         = (1..100).to_a
		kfi                        = (1..100).to_a
		dover_di                   = (1..100).to_a
		nre                        = (1..100).to_a
		kfii                       = (1..100).to_a
		kfd                        = (1..100).to_a
		f                          = (1..100).to_a
		kff                        = (1..100).to_a
		doverdii                   = (1..100).to_a
		elevation                  = (1..100).to_a
		pressure_drop              = (1..100).to_a
		inlet_pressure             = (1..100).to_a
		inlet_temperature          = (1..100).to_a
		section_outlet_pressure    = (0..100).to_a
		section_outlet_temperature = (0..100).to_a
		fittings                   = (1..100).to_a
		fittingdp                  = (1..100).to_a
		pi = 3.14159265358979

		project = model.compressor_sizing.compressor_sizing_tag.project

		barometric_pressure = project.barometric_pressure
		pipe_roughness = project.pipes[0].roughness_recommended
		e = pipe_roughness
		e = e / 12

		if model.class.name == "CompressorCentrifugalDesign"
			count = model.compressor_centrifugal_design_pipings.length
			circuit_pipings = model.compressor_centrifugal_design_pipings
		else
			count = model.compressor_reciprocation_design_pipings.length
			circuit_pipings = model.compressor_reciprocation_design_pipings
		end

		compressor_sizing = model.compressor_sizing

		mass_flow_rate = compressor_sizing.su_mass_flow_rate
		pressure       = compressor_sizing.su_pressure
		temperature    = compressor_sizing.su_temperature
		viscosity      = compressor_sizing.su_vapor_viscosity
		vapor_mw       = compressor_sizing.su_vapor_mw
		vapor_k        = compressor_sizing.su_vapor_k
		vapor_z        = compressor_sizing.su_vapor_z

		relief_rate = mass_flow_rate
		relief_pressure = pressure
		relief_temperature = temperature


		(0..count-1).each do |p|
			circuit_piping = circuit_pipings[p]
			fitting           = circuit_piping.fitting
			fitting_tag       = circuit_piping.fitting_tag
			pipe_size         = circuit_piping.pipe_size
			pipe_schedule     = circuit_piping.pipe_schedule
			pipe_id           = circuit_piping.pipe_id
			per_flow          = circuit_piping.per_flow
			fitting_length    = circuit_piping.length
			fitting_elevation = circuit_piping.elev
			cv = circuit_piping.ds_cv

			relief_rate1 = relief_rate * (flow_percentage[p] / 100)
			nre[p] = (0.52633 * relief_rate1) / (pipeid[p] * viscosity)

			a = (2.457 * Math.log(1.0 / (((7.0 / nre[p]) ** 0.9) + (0.27 * (e / pipeid[p]))))) ** 16.0 
			b = (37530 / nre[p]) ** 16.0
			f[p] = 2.0 * ((8.0 / nre[p]) ** 12.0 + ( 1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0) 
			p_drop = 0

			fd        = 4 * f[p]
			nreynolds = nre[p]
			d         = pipe_id
			d1        = pipe_id
			d2        = per_flow

			fitting_type = PipeSizing.get_fitting_tag(circuit_piping.fitting)[:value]
			if fitting_type == 'Pipe'
				kf = 4 * f[p] * (length[p]/pipeid[p])
			elsif fitting_type == "Control Valve" and p_drop == ""
				kf = ((29.9 * d ** 2.0)/ cv) ** 2.0
			elsif fitting_type == "Orifice" and p_drop == ""
				beta = cv_dorifice / d
				if nreynolds <= 10 ** 4.0
					#UserFormOrificeCoefficientLR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientLR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientLR.Show
					#FlowC = UserFormOrificeCoefficientLR.txtOrificeCoefficient.Value + 0
				elsif nreynolds > 10 ** 4.0
					#UserFormOrificeCoefficientHR.lblBeta = Round(Beta, 2)
					#UserFormOrificeCoefficientHR.lblPipeReynoldNumber = Round(Nreynolds, 0)
					#UserFormOrificeCoefficientHR.Show
					#FlowC = UserFormOrificeCoefficientHR.txtOrificeCoefficient.Value
				end
				#TODO dummy value
				flow_c = 1.0
				kf = (1 - beta ** 2.0) / (flow_c ** 2.0 * beta ** 4.0)
			elsif fitting_type == "Equipment"
				p_drop = ""
			elsif fitting_type == "Control Valve" and p_drop != ""
				p_drop = ""
			elsif fitting_type == "Orifice" and p_drop != ""
				p_drop = ""
			else
				result = PipeSizing.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, fd)
				dover_d = result[:dover_d]
				kfii[p] = result[:kf]
				doverdii[p] = dover_d
			end

			choke_counter = 0
			sumkff = 0
			sumkff = sumkff + kff[p]
			pipeid[p] = pipe_id
			inlet_pressure[1] = relief_pressure
			inlet_temperature[1] = relief_temperature
			#determine g
			area = (pi / 4.0) * (pipeid[p]) ** 2.0
			mass_velocity = relief_rate1/area
			if project.vapor_flow_model == "Isothermic"
				part1 = (inlet_pressure[p] + barometric_pressure) ** 2.0
				part2 = (7.41109 * 10.0 ** -6 * (relief_temperature + 459.67) * mass_velocity ** 2.0) / vapor_mw
				part3 = sumkff/2.0
				initial_outlet_pressure = (part1 - (part2 * part3)) ** 0.5
				(1..100).each do |gg|
					part4 = Math.log((inlet_pressure[p] + barometric_pressure) / initial_outlet_pressure) # 'Log is natural log (aka ln())
					#part4 = 10.0
					section_outlet_pressure[gg] = (part1 - part2 * (part3 + part4)) ** 0.5
					initial_outlet_pressure = section_outlet_pressure[gg]
					if section_outlet_pressure[gg] ==  section_outlet_pressure[gg - 1]
						inlet_pressure[p+1] = section_outlet_pressure[gg] - barometric_pressure
					end              
				end   
				#Determine sonic downstream pressure at each fitting along the system
				#Check for choked flow
				p1 = inlet_pressure[p]
				p2 = inlet_pressure[p+1]
				pressure_drop = p1 - p2
				(1..1000).each do |r|
					p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
					part1 = ((p1 + barometric_pressure) / p2_critical) ** 2.0
					part2 = 2.0 ** Math.log((p1 + barometric_pressure) / p2_critical)
					isothermal_choke_kf = part1 - part2 - 1
					break if sumkff <= isothermal_choke_kf
				end
				#Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
			elsif project.vapor_flow_model == "Adiabatic"
				part1 = vapor_k / (vapor_k + 1)
				part2 = 269866 * (vapor_k / (vapor_k + 1))
				part3 = ((inlet_pressure[p] + barometric_pressure) ** 2.0 * vapor_mw) / (inlet_temperature[p] + 459.67)
				part4 = mass_velocity ** 2.0 * (sumkff / 2.0)
				initial_outlet_pressure = (inlet_pressure[p] + barometric_pressure) * (1 - (part4 / (part2 * part3))) ** part1
				(1..100).each do |gg|
					part5 = Math.log(inlet_pressure[p] + barometric_pressure / initial_outlet_pressure) / vapor_k
					part6 = mass_velocity ** 2.0 * ((sumkff / 2.0) + part5)
					section_outlet_pressure[gg] = (inlet_pressure[p] + barometric_pressure) * ( 1 - (part6 / (part2 * part3))) ** part1
					section_outlet_temperature[gg] = (inlet_temperature[p] + 459.69) * (section_outlet_pressure[gg] / (inlet_pressure[p] + barometric_pressure)) ** (( vapor_k -1) / vapor_k)
					initial_outlet_pressure = section_outlet_pressure[gg]
					if section_outlet_pressure == section_outlet_pressure[gg -1]
						inlet_pressure[p +1] = section_outlet_pressure[gg] - barometric_pressure
						inlet_temperature[p +1] = section_outlet_temperature[gg] - 459.69
						#TODO need reiview
						#Worksheets("FE Circuit").Cells(15720 + nn, 91).Value = InletPress(nn + 1)
						#Worksheets("FE Circuit").Cells(15720 + nn, 94).Value = InletTemp(nn + 1)
						gg = 100
					end
				end
				#Determine sonic downstream pressure at each fitting along the system
				#Check for choked flow
				#P1 = InletPress(nn)
				#P2 = InletPress(nn + 1)
				p1 = inlet_pressure[p]
				p2 = inlet_pressure[p+1]
				pressure_drop = p1 - p2
				(0..1000).each do |r|
					p2_critical = (p1 + barometric_pressure) - ((0.001 * r) * (p1 + barometric_pressure))
					part1 = 2.0 / (vapor_k +1)
					part2 = (((p1 + barometric_pressure) / p2_critical) ** ((vapor_k + 1) / vapor_k)) -1
					part3 = (2.0 / vapor_k) * Math.log((p1 + barometric_pressure) / p2_critical)
					adiabatic_choke_kf = (part1 * part2) - part3
					break if sumkff <= adiabatic_choke_kf
				end
				# Worksheets("FE Circuit").Cells(15720 + nn, 92).Value = (P2Critical - BarometricPressure)
			end
			circuit_piping.update_attributes(:delta_p => pressure_drop)
			puts pressure_drop
		end
		units = project.project_units1

		if model.class.name == "CompressorCentrifugalDesign"
		    interstage_deltap = model.compressor_centrifugal_design_pipings.sum(:delta_p)
		else
		    interstage_deltap = model.compressor_reciprocation_design_pipings.sum(:delta_p)
		end
		model.update_attributes(:interstage_dp => interstage_deltap)
	end

end
