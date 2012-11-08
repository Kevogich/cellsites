class Superadmin::MeasureUnitsController < SuperadminController

  def index
    @measurement_sub_types = MeasurementSubType.joins(:measurement).order('measurements.name, measurement_sub_types.name')
    @measurements = @measurement_sub_types.group_by { |ms| ms.measurement.name}

    @rs_measure_units = MeasureUnit.order('unit_name')
    @measure_units = @rs_measure_units.group_by {|mu| mu.measurement_sub_type_id}
  end

  def new
    @measurements = Measurement.order('name')
    @measure_unit = MeasureUnit.new
    render :layout => false
  end

  def create
    measure_unit = params[:measure_unit]
    measure_unit[:user_id] = measure_unit[:created_by] = measure_unit[:updated_by] = current_user.id
    @measure_unit = MeasureUnit.new(measure_unit)
    if @measure_unit.save
      flash[:notice] = "Measure Unit is Created"
    else
      flash[:error] = "Measure Unit is Not Created"
    end
  end

  def edit
    @measure_unit = MeasureUnit.find(params[:id])
    @measurements = Measurement.order('name')
    @measurement_sub_types = MeasurementSubType.where(:measurement_id => @measure_unit.measurement_id)
    render :layout => false
  end

  def update
    @measure_unit = MeasureUnit.find(params[:id])
    if @measure_unit.update_attributes(params[:measure_unit])
      flash[:notice] = "Measure Unit is updated"
    else
      flash[:error] = "Measure Unit is Not updated"
    end

  end

  def destroy
    measure_unit = MeasureUnit.find(params[:id])
    measure_unit.destroy
    flash[:notice] = "Measure Unit has been deleted"
    redirect_to superadmin_measure_units_path
  end

  def get_measurement_sub_types
    @id = params[:id]
    @measurement = Measurement.find(@id)
    @measurement_sub_types = @measurement.measurement_sub_types
  end
end
