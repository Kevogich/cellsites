class Superadmin::MeasurementsController < SuperadminController

  def index
    @measurements = Measurement.all
  end

  def new
    @measurement = Measurement.new
    render :layout => false
  end

  def create
    @measurement = Measurement.new(params[:measurement])
    if @measurement.save
      flash[:notice] = 'Measurement Saved Successfully'
    else
      flash[:error] = 'Something wrong while saving the record'
    end
  end

  def edit
    @measurement = Measurement.find(params[:id])
    render :layout => false
  end

  def update
    @measurement = Measurement.find(params[:id])
    if @measurement.update_attributes(params[:measurement])
      flash[:notice] = 'Measurement Updated Successfully'
    else
      flash[:error] = 'Something wrong while saving the record'
    end
  end

  def destroy
    @measurement = Measurement.find(params[:id])
    @measurement.destroy
    flash[:notice] = 'Measurement deleted successfully'
    redirect_to superadmin_measurements_path
  end
end
