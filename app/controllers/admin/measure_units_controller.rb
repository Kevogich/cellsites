class Admin::MeasureUnitsController < AdminController
  
  def index
    @company = current_user.company
    @measure_units = @company.measure_units.order("measurement_id ASC")  
  end
  
  def new
    @company = current_user.company
    @measurements = @company.measurements    
    @measure_unit = MeasureUnit.new
  end
  
  def create
    @company = current_user.company
    measure_unit = params[:measure_unit]
    measure_unit[:user_id] = measure_unit[:created_by] = measure_unit[:updated_by] = current_user.id
    @measure_unit = @company.measure_units.new(measure_unit)
    if @measure_unit.save
      flash[:notice] = "Measure Unit is Created"
      redirect_to admin_measure_units_path
    else
      flash[:error] = "Measure Unit is Not Created"
      render :new
    end
  end
  
  def edit
    @measure_unit = MeasureUnit.find(params[:id])
    @measurement_sub_types = MeasurementSubType.where(:measurement_id => @measure_unit.measurement_id)
  end
  
  def update
    @measure_unit = MeasureUnit.find(params[:id])
    if @measure_unit.update_attributes(params[:measure_unit])
      redirect_to admin_measure_units_path
    else
      render :edit
    end
    
  end
  
  def destroy
    measure_unit = MeasureUnit.find(params[:id])
    measure_unit.destroy    
    flash[:notice] = "Measure Unit has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_measure_units_path }
    end
  end
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Measure Units', :url => admin_measure_units_path }
  end
end
