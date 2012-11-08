class Superadmin::MeasurementSubTypesController < SuperadminController

  layout :false

  def index
    @measurement = Measurement.find(params[:measurement_id])
    @measurement_sub_types = @measurement.measurement_sub_types
  end

  def new
    @measurement = Measurement.find(params[:measurement_id])
    @measurement_sub_type = @measurement.measurement_sub_types.new
  end

  def create
    measurement_sub_type = params[:measurement_sub_type]
    @measurement_sub_type = MeasurementSubType.new(measurement_sub_type)
    if @measurement_sub_type.save
      flash[:notice] = "Measurement sub type is created"
    else
      flash[:notice] = "Measurement sub type not created"
    end
  end

  def edit
    @measurement_sub_type = MeasurementSubType.find(params[:id])
  end

  def update
    @measurement_sub_type = MeasurementSubType.find(params[:id])
    if @measurement_sub_type.update_attributes(params[:measurement_sub_type])
      flash[:notice] = "Measurement sub type is updated"
    else
      flash[:notice] = "Measurement sub type not updated"
    end
  end

  def destroy
    @id = params[:id]
    @measurement_sub_type = MeasurementSubType.find(params[:id])
    @measurement_sub_type.destroy
    flash[:notice] = 'Measurement sub type deleted successfully'
  end
end
