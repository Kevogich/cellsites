class Admin::MeasurementsController < AdminController
  
  respond_to :html, :json
  
  def index   
    @company = current_user.company
    @measurements = @company.measurements    
    
  end
  
  def new
    @measurement = Measurement.new
  end  
  
  def create
    @company = current_user.company
    measurement = params[:measurement]
    measurement[:created_by] = measurement[:updated_by] = current_user.id
    @measurement = @company.measurements.new(measurement)
    if @measurement.save
      flash[:notice] = "Measurement is Created"
      redirect_to admin_measurements_path
    else
      flash[:notice] = "Measurement Unit is Not Created"
      render :new
    end
  end
  
  def edit
    @company = current_user.company
    @measurement = @company.measurements.find(params[:id])
  end
  
  def update
    @measurement = Measurement.find(params[:id])
    measurement = params[:measurement]
    measurement[:updated_by] = current_user.id    
    if @measurement.update_attributes(measurement)
      flash[:notice] = "Measurement has been updated"
      redirect_to admin_measurements_path
    else
      flash[:notice] = "Measurement can not be saved"
      render :edit
    end
  end
  
  def destroy
    @measurement = Measurement.find(params[:id])
    @measurement.destroy
    flash[:notice] = "Measurement has been deleted"
    redirect_to admin_measurements_path 
  end
  
  def get_measurement_sub_types
    @id = params[:id]
    @measurement = Measurement.find(@id)
    @measurement_sub_types = @measurement.measurement_sub_types    
  end
  
  def set_breadcrumbs
    super    
    @breadcrumbs << { :name => 'Measurements', :url => admin_measurements_path }
  end
end
