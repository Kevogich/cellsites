class Admin::UnitOfMeasurementsController < AdminController
  
  def index
    @unit_type = params[:measurement_type]
    project_id = params[:project_id]

    @project = Project.find(project_id)
    @project.update_attributes({:units_of_measurement_id => params[:unit_type_id]})

    @measurement_sub_types = MeasurementSubType.joins(:measurement).order('measurements.name, measurement_sub_types.name')
    @measurements = @measurement_sub_types.group_by { |ms| ms.measurement.name}

    @rs_measure_units = MeasureUnit.where(:unit_type_id => params[:unit_type_id]).order('unit_name')
    @measure_units = @rs_measure_units.group_by {|mu| mu.measurement_sub_type_id}

    @rs_unit_of_measurements = @project.unit_of_measurements
    @unit_of_measurements = {}
    @rs_unit_of_measurements.each do |unit_of_measurement|
    @unit_of_measurements[unit_of_measurement.measurement_sub_type_id] = {:measure_unit_id => unit_of_measurement.measure_unit_id, :decimal_places => unit_of_measurement.decimal_places}
    end

    render :layout => false
  end

=begin
  def create
    @project = Project.find(params[:project_id])
    multiply_factor = {}
    uom_params = params[:unit_of_measurement]
    #logger.debug uom_params.to_yaml
    uoms = @project.unit_of_measurements
    
    ActiveRecord::Base.transaction do
      uom_params.each do |v, uom_param|                  
        next if uom_param[:measure_unit_id].blank?
        #current db measure values                
        current_db_measure_unit = @project.unit_of_measurements.where("unit_of_measurements.measurement_id = ? AND unit_of_measurements.measurement_sub_type_id = ?", uom_param[:measurement_id], uom_param[:measurement_sub_type_id]).joins(:measure_unit, :measurement, :measurement_sub_type).select("unit_of_measurements.id, measurements.name AS measurement, measurement_sub_types.name AS measurement_sub_type , measure_units.conversion_factor").first
        if current_db_measure_unit.nil?  
          UnitOfMeasurement.create({
            :company_id => @company.id,
            :project_id => @project.id,
            :measurement_id => uom_param[:measurement_id],
            :measurement_sub_type_id => uom_param[:measurement_sub_type_id],
            :measure_unit_id => uom_param[:measure_unit_id],
      		:measure_type => uom_param[:measure_type],
      		:decimal_places => uom_param[:decimal_places],
            :created_by => current_user.id,
            :updated_by => current_user.id        
          })
          
          current_db_measure_unit = @project.unit_of_measurements.where("unit_of_measurements.measurement_id = ? AND unit_of_measurements.measurement_sub_type_id = ?", uom_param[:measurement_id], uom_param[:measurement_sub_type_id]).joins(:measure_unit, :measurement, :measurement_sub_type).select("unit_of_measurements.id, measurements.name AS measurement, measurement_sub_types.name AS measurement_sub_type , measure_units.conversion_factor").first
        end
        current_db_base_value =   1 * (current_db_measure_unit[:conversion_factor].to_f) #based on 1 unit   
       
        #current input params
        measure_unit = MeasureUnit.where("measurement_id = ? AND measurement_sub_type_id = ? AND id = ?", uom_param[:measurement_id], uom_param[:measurement_sub_type_id], uom_param[:measure_unit_id]).first
        next if measure_unit.conversion_factor.nil?
        current_coversion_factor = 1 / measure_unit.conversion_factor
        multiply_factor[current_db_measure_unit[:measurement].to_s] = {} if multiply_factor[current_db_measure_unit[:measurement].to_s].nil?      
        multiply_factor[current_db_measure_unit[:measurement].to_s][current_db_measure_unit[:measurement_sub_type].to_s] = {} if multiply_factor[current_db_measure_unit[:measurement].to_s][current_db_measure_unit[:measurement_sub_type].to_s].nil?
        #multiply_factor[current_db_measure_unit[:measurement].to_s][current_db_measure_unit[:measurement_sub_type].to_s] = (current_db_base_value * current_coversion_factor).to_f
        multiply_factor[current_db_measure_unit[:measurement].to_s][current_db_measure_unit[:measurement_sub_type].to_s] = (current_db_measure_unit[:conversion_factor].to_f / measure_unit.conversion_factor.to_f)
              
        #update the values
        uom = UnitOfMeasurement.find(current_db_measure_unit[:id])
        uom.update_attributes({
          :measure_unit_id => uom_param[:measure_unit_id],
      	  :measure_type => uom_param[:measure_type],
      	  :decimal_places => uom_param[:decimal_places],
          :updated_by => current_user.id
        })
      end
      
      #logger.debug multiply_factor.to_yaml
      #@project.convert_values(multiply_factor)
    end   
    
    respond_to do |format|
      format.js      
    end        
  end
=end

  def create
	  @project = Project.find(params[:project_id])
	  uom_params = params[:unit_of_measurement]
      multiply_factor = {}

	  ActiveRecord::Base.transaction do
		  uom_params.each do |k, uom|
			  next if uom[:measure_unit_id].blank?
			  u = UnitOfMeasurement.find_or_initialize_by_measurement_sub_type_id_and_project_id(uom[:measurement_sub_type_id], @project.id)
			  u.company_id = @project.company_id
			  u.project_id = @project.id
			  u.measurement_id = uom[:measurement_id]
			  u.measurement_sub_type_id = uom[:measurement_sub_type_id]
			  u.previous_measure_unit_id = u.measure_unit_id
			  u.previous_measure_unit_id = uom[:measure_unit_id] if u.measure_unit_id.nil?
			  u.measure_unit_id = uom[:measure_unit_id]
			  u.measure_type = uom[:measure_type]
			  u.decimal_places = uom[:decimal_places]
			  u.save
			  current_coversion_factor = 1 * MeasureUnit.find(u.previous_measure_unit_id).conversion_factor.to_f
			  converted_conversion_factor = 1 / MeasureUnit.find(u.measure_unit_id).conversion_factor.to_f
			  conversion_factor = current_coversion_factor * converted_conversion_factor
			  measurement = Measurement.find(u.measurement_id).name
			  measurement_sub_type = MeasurementSubType.find(u.measurement_sub_type_id).name
			  multiply_factor[measurement] = {} if multiply_factor[measurement].nil?
			  #multiply_factor[measurement][measurement_sub_type] = {} if multiply_factor[measurement][measurement_sub_type].nil?
			  multiply_factor[measurement][measurement_sub_type] = conversion_factor
		  end
		  @project.convert_values(multiply_factor)
	  end
  end

end
