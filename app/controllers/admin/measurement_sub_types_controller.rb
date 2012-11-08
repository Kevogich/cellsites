class Admin::MeasurementSubTypesController < AdminController
  
  def index
    @measurement = Measurement.find(params[:measurement_id])
    @measurement_sub_types = @measurement.measurement_sub_types
  end
  
  def new
    @measurement = Measurement.find(params[:measurement_id])
    @measurement_sub_type = MeasurementSubType.new
  end
  
  def create
    measurement_sub_type = params[:measurement_sub_type]
    measurement_sub_type[:created_by] = measurement_sub_type[:updated_by] = current_user.id  
    @measurement_sub_type = MeasurementSubType.new(measurement_sub_type)
    if @measurement_sub_type.save
      flash[:notice] = "Measurement Suby Type is created"
      redirect_to admin_measurement_sub_types_path(:measurement_id => @measurement_sub_type.measurement_id)
    else
      flash[:notice] = "Measurement Suby Type not created"
      render :new
    end
  end
  
  def edit
    @measurement_sub_type = MeasurementSubType.find(params[:id])
    @measurement = @measurement_sub_type.measurement
  end
  
  def update
    @measurement_sub_type = MeasurementSubType.find(params[:id])
    params[:measurement_sub_type][:updated_by] = current_user.id
    if @measurement_sub_type.update_attributes(params[:measurement_sub_type])
      flash[:notice] = "Measurement sub type has been updated"
      redirect_to admin_measurement_sub_types_path(:measurement_id => @measurement_sub_type.measurement_id)
    else
      flash[:notice] = "Measurement sub type can not be saved"
      render :edit
    end
  end
  
  def destroy
    @measurement_sub_type = MeasurementSubType.find(params[:id])
    @measurement_sub_type.destroy
    flash[:notice] = "Measurement sub type has been deleted"
    redirect_to admin_measurement_sub_types_path(:measurement_id => @measurement_sub_type.measurement_id) 
  end
  
  def set_breadcrumbs
    super    
    @breadcrumbs << { :name => 'Measurements', :url => admin_measurements_path }
  end
end
