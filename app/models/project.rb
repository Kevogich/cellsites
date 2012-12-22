require 'alchemist'

class Project < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  has_one  :pressure_relief_system_design_parameter
  has_many :project_pipes
  has_many :pipes, :through => :project_pipes
  has_many :unit_of_measurements, :dependent => :destroy
  has_many :heat_and_material_balances, :dependent => :destroy
  has_many :project_sizing_criterias, :dependent => :destroy
  has_many :sizing_criteria_categories, :through => :project_sizing_criterias
  has_many :process_units, :dependent => :destroy
  has_many :line_sizings, :dependent => :destroy
  has_many :vessel_sizings, :dependent => :destroy
  has_many :pump_sizings, :dependent => :destroy
  has_many :compressor_sizing_tags, :dependent => :destroy
  has_many :electric_motors, :dependent => :destroy
  has_many :steam_turbines, :dependent => :destroy
  has_many :hydraulic_turbines, :dependent => :destroy
  has_many :turbo_expanders, :dependent => :destroy
  has_many :control_valve_sizings, :dependent => :destroy
  has_many :flow_element_sizings, :dependent => :destroy
  has_many :storage_tank_sizings, :dependent => :destroy
  has_many :column_sizings, :dependent => :destroy
  has_many :heat_exchanger_sizings, :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :project_users
  has_many :users, :through => :project_users
  has_many :item_types_transmit_and_proposals, :dependent => :destroy
  has_many :procure_items, :dependent => :destroy
  has_many :project_vendor_lists
  has_many :vendor_lists, :through => :project_vendor_lists
  has_many :project_item_types
  has_many :item_types, :through => :project_item_types , :dependent => :destroy
  has_many :process_units, :dependent => :destroy
  has_many :request_for_quotation_setups, :dependent => :destroy
  has_many :procure_rfq_sections, :through => :request_for_quotation_setups , :dependent => :destroy
  acts_as_commentable

  #TODO VALIDATIONS NEED TO ADD IN PROJECT
  validates_presence_of :client_id, :project_num

  accepts_nested_attributes_for :pressure_relief_system_design_parameter
  accepts_nested_attributes_for :request_for_quotation_setups
    
  #serialize :sizing_criterias

  def units_of_measurement
    { 1 => "US Customary", 2 => "SI" }[ units_of_measurement_id ]
  end

  #TODO WHAT TO REMOVE UNNESSCERY CODE
=begin
  def self.sizing_criterias
    {
      'sc101' => { 'name' => 'General Recommendation', 'vmin' => 5, 'vmax' => 15, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 4 },
      'sc102' => { 'name' => 'Laminar Flow', 'vmin' => 4, 'vmax' => 5, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 4 },
      'sc103' => { 'name' => 'Turbulent Flow (100 lb/ft^2)', 'vmin' => 5, 'vmax' => 8, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 4 },
      'sc104' => { 'name' => 'Turbulent Flow (50 lb/ft^2)', 'vmin' => 6, 'vmax' => 10, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 4 },
      'sc105' => { 'name' => 'Turbulent Flow (20 lb/ft^2)', 'vmin' => 10, 'vmax' => 15, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 4 },
      'sc201' => { 'name' => 'General Service', 'vmin' => 2, 'vmax' => 16, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc202' => { 'name' => 'General Service (1" Diameter)', 'vmin' => 2, 'vmax' => 3, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc203' => { 'name' => 'General Service (2" Diameter)', 'vmin' => 3, 'vmax' => 4.5, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc204' => { 'name' => 'General Service (4" Diameter)', 'vmin' => 5, 'vmax' => 7, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc205' => { 'name' => 'General Service (6" Diameter)', 'vmin' => 7, 'vmax' => 9, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc206' => { 'name' => 'General Service (8" Diameter)', 'vmin' => 8, 'vmax' => 10, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc207' => { 'name' => 'General Service (10" Diameter)', 'vmin' => 10, 'vmax' => 12, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc208' => { 'name' => 'General Service (12" Diameter)', 'vmin' => 10, 'vmax' => 14, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc209' => { 'name' => 'General Service (16" Diameter)', 'vmin' => 10, 'vmax' => 15, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc210' => { 'name' => 'General Service (>20" Diameter)', 'vmin' => 10, 'vmax' => 16, 'v' => 0, 'pmin' => 0, 'pmax' => 0, 'p' => 1.5 },
      'sc301' => { 'name' => 'Carbon Stell Transportation Piping:Phernolic Water', 'vmin' => 0, 'vmax' => 3, 'v' => 3, 'pmin' => 0, 'pmax' => 0, 'p' => 0 },
      'sc302' => { 'name' => 'Carbon Stell Transportation Piping:Concentrated Sulphuric Acid', 'vmin' => 0, 'vmax' => 4, 'v' => 4, 'pmin' => 0, 'pmax' => 0, 'p' => 0 },
      'sc303' => { 'name' => 'Carbon Stell Transportation Piping:Salt Water', 'vmin' => 0, 'vmax' => 6, 'v' => 6, 'pmin' => 0, 'pmax' => 0, 'p' => 0 },
      'sc304' => { 'name' => 'Carbon Stell Transportation Piping:Caustic Solution', 'vmin' => 0, 'vmax' => 4, 'v' => 4, 'pmin' => 0, 'pmax' => 0, 'p' => 0 },
    }
  end
  def self.sizing_criteria_categories
    [
      { :name => 'Pressure Service & Equipment', :criterias => [ 'sc101', 'sc102', 'sc103', 'sc104', 'sc105' ] },
      { :name => 'Water Service', :criterias => [ 'sc201', 'sc202', 'sc203', 'sc204', 'sc205', 'sc206', 'sc207', 'sc208', 'sc209', 'sc210' ] },
      { :name => 'Special Liquids', :criterias => [ 'sc301', 'sc302', 'sc303', 'sc304' ] },
    ]
  end

  def sizing_criterias
    Project.sizing_criterias.merge( self[:sizing_criterias].presence || {} )
  end

  def pipes=(pipes_params)
    pipes_selected = []
    pipes_params[:base].each do |pipe_base|
      pipes_selected << pipe_base[0].to_i if pipe_base[1] == "1"
    end
    pipes_selected.each do |pipe_selected|
      if pipe = project_pipes.where( :pipe_id => pipe_selected ).first
        pipe.update_attributes( :roughness => pipes_params[:roughness][pipe_selected.to_s].to_f ) if pipes_params[:roughness][pipe_selected.to_s].to_f != pipe.roughness
      else
        project_pipes.create( :pipe_id => pipe_selected, :roughness => pipes_params[:roughness][pipe_selected.to_s].to_f )
      end
    end
    if pipes_selected.empty?
      project_pipes.delete_all
    else
      project_pipes.where( :pipe_id.not_in => pipes_selected ).delete_all
    end
  end
=end

  #TODO: NEEDS TO BUILD
  def pipes=(pipes_params)
    project_pipes.delete_all
    project_pipes.create(:pipe_id => pipes_params[:base], :roughness => pipes_params[:roughness][pipes_params[:base].to_s].to_f)    
  end
  
  def heat_and_material_balances=(hnm_params)
    hnm_params.delete('#x#')    
    hnm_params.each do |k, hnm_param|
      hnm = heat_and_material_balances.where(:id=>hnm_param[:id]).first
      heat_and_material_balances.create(:case => hnm_param[:case]) if hnm.nil? && !hnm_param[:case].blank?
      hnm.update_attributes(:case => hnm_param[:case]) if !hnm.nil?      
    end
  end
  
  #TODO: NEEDS MODIFICATION FOR BETTER CODING
  def project_sizing_criterias=(psc_params)    
    psc_params.each do |k, psc_param|
      psc = project_sizing_criterias.where(:id => psc_param[:id]).first
      psc.update_attributes(psc_param)
    end
  end
  
  def process_units=(pu_params)
    #raise pu_params.to_yaml
    pu_params.each do |i, pu_param|
      pu = process_units.where(:id => pu_param[:id]).first      
      process_units.create(pu_param) if pu.nil? && !pu_param[:name].blank? #create
      pu.delete if !pu.nil? && pu_param[:name].blank? #delete
      pu_param.delete('created_by') if !pu.nil? #update     
      pu.update_attributes(pu_param) if !pu.nil? && !pu_param[:name].blank? #update
    end
  end

  # Multistep editing form
  def steps
    @@steps ||= {
      :information => { :no => 1, :name => 'Project Details', :prev => nil, :next => :measurement_unit },
      :measurement_unit => { :no => 2, :name => 'Select Units of Measurement', :prev => :information, :next => :process_units },
      :process_units => { :no => 3, :name => 'Process Units', :prev => :information, :next => :pipe_roughness },
      :pipe_roughness => { :no => 4, :name => 'Select Pipe Roughness', :prev => :measurement_unit, :next => :heat_and_material_balance },
      :heat_and_material_balance => { :no => 5, :name => 'Heat & Material Balance Setup', :prev => :pipe_roughness, :next => :sizing_criteria },
      :sizing_criteria => { :no => 6, :name => 'Sizing Criteria', :prev => :heat_and_material_balance, :next => :flow_model },
      :flow_model => { :no => 7, :name => 'Select Flow Model', :prev => :sizing_criteria, :next => :piping_and_instrumentation_design_parameters },
      :piping_and_instrumentation_design_parameters => { :no => 8, :name => 'Piping and Instrumentation Design Parameters', :prev => :flow_model, :next => :rotating_equiment_design_parameters },
      :rotating_equiment_design_parameters => { :no => 9, :name => 'Rotating Equiment Design Parameters', :prev => :piping_and_instrumentation_design_parameters, :next => :mechanical_driver_design_parameters },
      :mechanical_driver_design_parameters => { :no => 10, :name => 'Mechanical Driver Design Parameters', :prev => :rotating_equiment_design_parameters, :next => :fixed_equipment_design_parameters },
      :fixed_equipment_design_parameters => { :no => 11, :name => 'Fixed Equipment Design Parameters', :prev => :mechanical_driver_design_parameters, :next => :pressure_relief_system_design_parameter },
      :pressure_relief_system_design_parameter => { :no => 12, :name => 'Fixed Equipment Design Parameters', :prev => :fixed_equipment_design_parameters, :next => :vendor_schedule_setup },
      :vendor_schedule_setup => { :no => 13, :name => 'Vendor Schedule Setup', :prev => :pressure_relief_system_design_parameter, :next => :request_for_quotation_setup },
      :request_for_quotation_setup => { :no => 14, :name => 'Request For Quotation Set up', :prev => :vendor_schedule_setup, :next => nil }
    }
  end

  def step( id )
    steps[ id ].merge( :id => id )
  end

  def current_step
    @current_step || steps.first[1].merge( :id => steps.first[0] )
  end

  def current_step=(step_id)
    @current_step = step( step_id.to_sym ) if step_id.present?
  end

  def next_step
    current_step[:next] and step( current_step[:next] )
  end

  def prev_step
    current_step[:prev] and step( current_step[:next] )
  end

  # Multistep  
  #TODO Modification is needed
  #HERE IS THE CODE FOR GETTING UNITS
  def unit(measurement, measurement_sub_type)    
    measure_unit = self.unit_of_measurements.
    joins(:measure_unit, :measurement_sub_type, :measurement).
    where("measurements.name = ? AND measurement_sub_types.name = ? AND measure_units.unit_type_id = ?", measurement, measurement_sub_type, self.units_of_measurement_id.to_i).
    select("measure_units.*").
    first
    
    measure_unit.unit rescue ""       
  end
  
  def measure_unit(measurement, measurement_sub_type)
    rs_measure_unit = self.unit_of_measurements.
    joins(:measure_unit, :measurement_sub_type, :measurement).
    where("measurements.name = ? AND measurement_sub_types.name = ? AND measure_units.unit_type_id = ?", measurement, measurement_sub_type, self.units_of_measurement_id.to_i).
    select("measure_units.*, measurement_sub_types.name as sub_type, measurements.name as measurement_name, unit_of_measurements.decimal_places as decimals").
    first
    
    measure_unit = {}
    measure_unit[:measurement] = rs_measure_unit.measurement_name rescue ""
    measure_unit[:sub_type] = rs_measure_unit.sub_type rescue ""
    measure_unit[:unit_name] = rs_measure_unit.unit_name rescue ""
    measure_unit[:unit] = rs_measure_unit.unit rescue ""
    measure_unit[:base_unit] = rs_measure_unit.base_unit rescue ""
    measure_unit[:conversion_factor] = rs_measure_unit.conversion_factor.to_f rescue 1
    measure_unit[:decimal_places] = rs_measure_unit.decimals.to_i rescue 10
    return measure_unit
  end
  
  #TODO Modification needs  
  def conversion_factor(measurement, measurement_sub_type)
    measure_unit = self.unit_of_measurements.
    joins(:measure_unit, :measurement_sub_type, :measurement).
    where("measurements.name = ? AND measurement_sub_types.name = ? AND measure_units.unit_type_id = ?", measurement, measurement_sub_type, self.units_of_measurement_id.to_i).
    select("measure_units.*").
    first
    
    measure_unit.conversion_factor rescue 1
  end

  #generic method to get the unit of measurements details
  #params is {:mtype => "name", :msub_type =>  "sub_type_name")
  def get_uom_details(params)
	  measurement = Measurement.where(:name => params[:mtype]).first
	  measurement_sub_type_id = measurement.measurement_sub_types.where(:name => params[:msub_type]).first.id
	  uom = self.unit_of_measurements.where(:measurement_id => measurement.id, :measurement_sub_type_id => measurement_sub_type_id).first
	  if uom.nil?
		  return nil
	  else
		  begin
			  pre = MeasureUnit.find(uom.previous_measure_unit_id)
			  previous_unit = {:unit_name => pre.unit_name, :unit => pre.unit}
		  rescue Exception => e
			  previous_unit = nil
		  end
		  cur = MeasureUnit.find(uom.measure_unit_id)
		  current_unit = {:unit_name => cur.unit_name, :unit => cur.unit}
	  end
	  return {:previous_unit => previous_unit, :current_unit => current_unit}
  end

  #convert temperature using formulas
  #params {:subtype => "General", :value => 2}
  def convert_temperature(params)
	  uom = self.get_uom_details(:mtype => "Temperature" , :msub_type => params[:subtype])
	  value = params[:value].to_f.send(uom[:previous_unit][:unit_name].downcase.to_sym).to.send(uom[:current_unit][:unit_name].downcase.to_sym)
	  return value.to_f
  end

  def convert_sizing_criteria_values(multiply_factor)
	  vuom = self.unit_conversion_factor(:mtype => 'Velocity', :msub_type => 'General')
	  duom = self.unit_conversion_factor(:mtype => 'Pressure', :msub_type => 'Differential')

	  velocities = [:velocity_max,:velocity_min,:velocity_sel]
	  delta = [:delta_per_100ft_min,:delta_per_100ft_max,:delta_per_100ft_sel]

	  self.project_sizing_criterias.each do |s|
		  velocities.each do |v|
			  if s.attribute_present?(v)
				  s.update_attributes(v => (s.send(v) * vuom[:factor]).round(vuom[:decimals]))
			  end
		  end
		  delta.each do |d|
			  if s.attribute_present?(d)
				  s.update_attributes(d => (s.send(d) * duom[:factor]).round(duom[:decimals]))
			  end
		  end
	  end
  rescue Exception => e
	  logger.debug e
  end

  #get conversion factor for any measure unit
  #params is {:mtype => "name", :msub_type =>  "sub_type_name")
  def unit_conversion_factor(params)
	  measurement = Measurement.where(:name => params[:mtype]).first
    measurement_sub_type_id = measurement.measurement_sub_types.where(:name => params[:msub_type]).first.id
	  uom = self.unit_of_measurements.where(:measurement_id => measurement.id, :measurement_sub_type_id => measurement_sub_type_id).first
    current_coversion_factor = 1 * MeasureUnit.find(uom.previous_measure_unit_id).conversion_factor.to_f
	  converted_conversion_factor = 1 / MeasureUnit.find(uom.measure_unit_id).conversion_factor.to_f
	  return {:factor => current_coversion_factor * converted_conversion_factor, :decimals => uom.decimal_places}
  rescue Exception => e
	  return {:factor => 1.0, :decimals => 4 }
  end

  #get conversion factor for a specified previous measure unit
  #params is {:mtype => "name", :msub_type =>  "sub_type_name", :previous_unit => 'Feet per second')
  #previous_unit   example:  'Inches per second'
  def specified_units_cf(params)
	  measurement = Measurement.where(:name => params[:mtype]).first
	  measurement_sub_type_id = measurement.measurement_sub_types.where(:name => params[:msub_type]).first.id
	  uom = self.unit_of_measurements.where(:measurement_id => measurement.id, :measurement_sub_type_id => measurement_sub_type_id).first
	  previous = MeasureUnit.where(:unit_name => params[:previous_unit],:measurement_id => measurement.id, :measurement_sub_type_id => measurement_sub_type_id, :unit_type_id => units_of_measurement_id).first.conversion_factor.to_f
	  current = MeasureUnit.find(uom.measure_unit_id).conversion_factor.to_f
	  return {:factor => previous/current, :decimals => uom.decimal_places}
  end

  #method to get the conversion for base unit
  def base_unit_cf(params)
    measurement = Measurement.where(:name => params[:mtype]).first
    measurement_sub_type_id = measurement.measurement_sub_types.where(:name => params[:msub_type]).first.id
    uom = self.unit_of_measurements.where(:measurement_id => measurement.id, :measurement_sub_type_id => measurement_sub_type_id).first
    previous = MeasureUnit.find(uom.measure_unit_id).conversion_factor.to_f
    return {:factor => previous, :decimals => uom.decimal_places}
  end

  #method to convert pipe roughness values
  #according to the unit measurements specified in the project
  def convert_pipe_roughness_values
	  uom =  specified_units_cf(:mtype => "Length", :msub_type => "Small Dimension Length", :previous_unit => "Inches")
	  pipes = []
	  project_pipes = {}
	  Pipe.all.each do |p|
		  a = p.attributes
		  a["roughness_recommended"] = (a["roughness_recommended"] * uom[:factor]).round(uom[:decimals])
		  pipes << a
	  end

	  company.project_pipes.each do |p|
		  a = {}
		  a["pipe_id"] = p.pipe_id
		  a["roughness"] = (p.roughness * uom[:factor]).round(uom[:decimals]) 
		  project_pipes[p.project_id] = a
	  end
	  return {:pipes => pipes, :project_pipes => project_pipes}
  end

  
  #TODO Project unit conversion method
  # Here is the method to change the database values
  def convert_values(multiply_factor)

	  #Piping and Instrumentation Design Parameters
	  self.barometric_pressure = (self.barometric_pressure.to_f * multiply_factor["Pressure"]["Absolute"].to_f)
	  self.maximum_operating_pressure_allowance = (self.maximum_operating_pressure_allowance.to_f * multiply_factor["Pressure"]["Absolute"].to_f)
	  self.design_pressure_allowance = (self.design_pressure_allowance.to_f * multiply_factor["Pressure"]["Absolute"].to_f)
	  self.default_pressure_drop_ratio_factor = (self.default_pressure_drop_ratio_factor.to_f * multiply_factor["Pressure"]["Differential Pressure"].to_f)
	  self.minimum_control_value_pressure_drop = (self.minimum_control_value_pressure_drop.to_f * multiply_factor["Pressure"]["Differential Pressure"].to_f)      
	  self.maximum_operating_temperature_allowance = convert_temperature(:value => self.maximum_operating_temperature_allowance, :subtype => "General")
	  self.design_temperature_allowance = convert_temperature(:value => self.design_temperature_allowance.to_f, :subtype => "General")      

	  #Rotating Equiment Design Parameters
	  self.allowable_centrifugal_compressor_mawt = convert_temperature(:value => self.allowable_centrifugal_compressor_mawt, :subtype => "General")
	  self.allowable_compression_ratio_per_recip_comp_stage_start = convert_temperature(:value => self.allowable_compression_ratio_per_recip_comp_stage_start, :subtype =>  "General")
	  self.allowable_compression_ratio_per_recip_comp_stage_end = convert_temperature(:value => self.allowable_compression_ratio_per_recip_comp_stage_end, :subtype => "General")

	  #Fixed Equipment Design Parameters
	  self.min_pressure_vessel_design_pressure = (self.min_pressure_vessel_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f)
	  self.minimum_exchanger_design_pressure = (self.minimum_exchanger_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f)
	  self.maximum_collection_header_back_pressure = (self.maximum_collection_header_back_pressure.to_f * multiply_factor["Pressure"]["General"].to_f)      
	  self.minimum_ambient_design_temperature = (convert_temperature(:value => self.minimum_ambient_design_temperature, :subtype => "General"))      

	  #sizing criteria conversion
	  self.convert_sizing_criteria_values(multiply_factor)

    #line sizing
    line_sizings.each do |line_sizing|
      #Stream Properties
      line_sizing.pressure = (line_sizing.pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.temperature = convert_temperature(:value => line_sizing.temperature, :subtype => "General")
      line_sizing.flowrate = (line_sizing.flowrate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
      line_sizing.vapor_density = (line_sizing.vapor_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
      line_sizing.vapor_viscosity = (line_sizing.vapor_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
      line_sizing.liquid_density = (line_sizing.liquid_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
      line_sizing.liquid_viscosity = (line_sizing.liquid_viscosity.to_f * multiply_factor["Viscosity"]["General"].to_f) if !multiply_factor["Viscosity"].nil?
      line_sizing.liquid_surface_tension = (line_sizing.liquid_surface_tension.to_f * multiply_factor["Surface Tension"]["General"].to_f) if !multiply_factor["Surface Tension"].nil?
      
      #Sizing Criteria
      line_sizing.system_equivalent_length = (line_sizing.system_equivalent_length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      line_sizing.system_maximum_deltaP = (line_sizing.system_maximum_deltaP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.pipe_roughness = (line_sizing.pipe_roughness.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      
      line_sizing.sc_required_id = (line_sizing.sc_required_id.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      line_sizing.sc_proposed_id = (line_sizing.sc_proposed_id.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      line_sizing.sc_pipe_size = (line_sizing.sc_pipe_size.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
      line_sizing.sc_calculated_system_dp = (line_sizing.sc_calculated_system_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.sc_calculated_velocity = (line_sizing.sc_calculated_velocity.to_f * multiply_factor["Velocity"]["General"].to_f) if !multiply_factor["Velocity"].nil?
      line_sizing.sc_system_equivalent_length = (line_sizing.sc_system_equivalent_length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      line_sizing.sc_fluid_momentum = (line_sizing.sc_fluid_momentum.to_f * multiply_factor["Fluid Momentum"]["General"].to_f) if !multiply_factor["Fluid Momentum"].nil?
            
      line_sizing.pipe_sizings.each do |pipe_sizing|
        pipe_sizing.pipe_id = (pipe_sizing.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
        pipe_sizing.length = (pipe_sizing.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        pipe_sizing.elev = (pipe_sizing.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        pipe_sizing.p_outlet = (pipe_sizing.p_outlet.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        
        pipe_sizing.save
      end
      
      #Design Conditions
      line_sizing.dc_source_design_pressure = (line_sizing.dc_source_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_source_design_temperature = convert_temperature(:value => line_sizing.dc_source_design_temperature, :subtype => "General")

      line_sizing.dc_source_statice_frictional_dp = (line_sizing.dc_source_statice_frictional_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_destination_design_pressure = (line_sizing.dc_destination_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_destination_design_temperature = convert_temperature(:value => line_sizing.dc_destination_design_temperature, :subtype => "General")

      line_sizing.dc_destination_statice_frictional_dp = (line_sizing.dc_destination_statice_frictional_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      
      line_sizing.dc_maximum_operating_pressure = (line_sizing.dc_maximum_operating_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_maximum_operating_temperature = convert_temperature(:value => line_sizing.dc_maximum_operating_temperature, :subtype => "General")

      line_sizing.dc_pressure_allowance = (line_sizing.dc_pressure_allowance.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_temperature_allowance = convert_temperature(:value => line_sizing.dc_temperature_allowance, :subtype => "General")
      line_sizing.dc_design_pressure = (line_sizing.dc_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_design_temperature = convert_temperature(:value => line_sizing.dc_design_temperature, :subtype => "General")
      line_sizing.dc_design_vaccum = (line_sizing.dc_design_vaccum.to_f * multiply_factor["Pressure"]["Absolute"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_min_design_temperature = convert_temperature(:value => line_sizing.dc_min_design_temperature, :subtype => "General")
      
      line_sizing.dc_spt_design_perssure = (line_sizing.dc_spt_design_perssure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_spt_design_temperature = convert_temperature(:value => line_sizing.dc_spt_design_temperature, :subtype => "General")      
      line_sizing.dc_spt_minimum_temperature = convert_temperature(:value => line_sizing.dc_spt_minimum_temperature, :subtype => "General")      
      line_sizing.dc_spt_allowable_stress = (line_sizing.dc_spt_allowable_stress.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_spt_lweld_joint_factor = convert_temperature(:value => line_sizing.dc_spt_lweld_joint_factor, :subtype => "General")
      line_sizing.dc_spt_mechanical_thickness_allowance = (line_sizing.dc_spt_mechanical_thickness_allowance.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      line_sizing.dc_spt_erosion_corrosion_allowance = (line_sizing.dc_spt_erosion_corrosion_allowance.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      line_sizing.dc_spt_pressure_design_thickness = (line_sizing.dc_spt_pressure_design_thickness.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      line_sizing.dc_spt_minimum_required_thickness = (line_sizing.dc_spt_minimum_required_thickness.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      
      line_sizing.dc_pc_design_pressure = (line_sizing.dc_pc_design_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_pc_design_temperature = convert_temperature(:value => line_sizing.dc_pc_design_temperature, :subtype => "General")      
      line_sizing.dc_pc_flange_pressure_rating = (line_sizing.dc_pc_flange_pressure_rating.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      line_sizing.dc_pc_flange_temperature_rating = convert_temperature(:value => line_sizing.dc_pc_flange_temperature_rating, :subtype => "General")

      line_sizing.dc_pc_insulation_thickness = (line_sizing.dc_pc_insulation_thickness.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
                  
      line_sizing.save
    end
    #end line sizing

    vessel_sizings.each do |vessel_sizing|
      vessel_sizing.convert_values(multiply_factor)
    end

    pump_sizings.each do |pump_sizing|
      pump_sizing.convert_values(multiply_factor)
    end
        
  
    #compressor sizing
    compressor_sizing_tags.each do |compressor_sizing_tag|
      compressor_sizing_tag.compressor_sizings.each do |compressor_sizing|
        compressor_sizing.convert_values(multiply_factor,self)
      end
    end

    #electric motor
    electric_motors.each do |electric_motor|
      electric_motor.convert_values(multiply_factor,self)
    end
    
    #steam turbines
    steam_turbines.each do |steam_turbine|
      steam_turbine.convert_values(multiply_factor,self)
    end
    
    #hydraulic turbines
    hydraulic_turbines.each do |hydraulic_turbine|
      hydraulic_turbine.convert_values(multiply_factor,self)
    end
    
    #turbo expanders
    turbo_expanders.each do |turbo_expander|
      turbo_expander.convert_values(multiply_factor,self)
    end
    
    #control valve sizings
    control_valve_sizings.each do |control_valve_sizing|
      control_valve_sizing.convert_values(multiply_factor,self)
    end

    #flow element sizings
    flow_element_sizings.each do |flow_element_sizing|
      flow_element_sizing.convert_values(multiply_factor,self)
    end

    #storage tank sizings
    storage_tank_sizings.each do |storage_tank_sizing|
      storage_tank_sizing.convert_values(multiply_factor,self)
    end
    
    #column sizings
    column_sizings.each do |column_sizing|
      column_sizing.convert_values(multiply_factor,self)
    end
    
    #heat exchanger sizing
    heat_exchanger_sizings.each do |heat_exchanger_sizing|
      heat_exchanger_sizing.convert_values(multiply_factor,self)
    end
  rescue Exception => e
	  logger.debug e
  end
  
  def project_units
    decimal_places_hash = {}    
    sql_results = unit_of_measurements.select("measurements.name AS measurement, measurement_sub_types.name AS measurement_sub_type, measure_units.unit AS measure_unit, unit_of_measurements.decimal_places").joins(:measurement, :measurement_sub_type, :measure_unit)
    sql_results.each do |uom|     
      decimal_places_hash[uom[:measurement].to_s] = {} if decimal_places_hash[uom[:measurement].to_s].nil?
      decimal_places_hash[uom[:measurement].to_s][uom[:measurement_sub_type].to_s] = {} if decimal_places_hash[uom[:measurement].to_s][uom[:measurement_sub_type].to_s].nil?
      decimal_places_hash[uom[:measurement].to_s][uom[:measurement_sub_type].to_s][:unit] = uom[:measure_unit].to_s
      decimal_places_hash[uom[:measurement].to_s][uom[:measurement_sub_type].to_s][:decimal_places] = uom[:decimal_places].to_s
    end
    decimal_places_hash
  end 
  
  #TODO need impleted this method for units and decimals
  def project_units1
    decimal_places_hash = {}    
    
    sql_results = unit_of_measurements.select("measurements.name AS measurement, measurement_sub_types.name AS measurement_sub_type, measure_units.unit AS measure_unit, unit_of_measurements.decimal_places").joins(:measurement, :measurement_sub_type, :measure_unit)

    sql_results.each do |uom|
      measurement = uom[:measurement].downcase.gsub(/[" "']/, "_")
      measurement_sub_type = uom[:measurement_sub_type].downcase.gsub(/[" "']/, "_")
      measurement_type = "#{measurement}_#{measurement_sub_type}"
      decimal_places_hash[measurement_type] = {}
      decimal_places_hash[measurement_type][:unit] = uom[:measure_unit].to_s
      decimal_places_hash[measurement_type][:decimal_places] = uom[:decimal_places].to_i
    end  
   
    decimal_places_hash    
  end  
end
