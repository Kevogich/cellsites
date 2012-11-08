class Admin::UnitsController < AdminController

  respond_to :html, :json

  before_filter :find_unit, :only => [ :show, :edit, :update, :destroy ]

  def destroy
    @unit.destroy
    flash[:notice] = "Unit has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_units_path }
    end
  end

  def new
    @unit = Unit.new
  end

  def create
    @unit = @company.units.new( params[:unit] )
    if @unit.save
      flash[:notice] = "Unit has been created"
      respond_to do |format|
        format.js
        format.html { redirect_to admin_units_path }
      end
    else
      flash[:notice] = "Unit can not be saved"
      respond_to do |format|
        format.js
        format.html { render :new }
      end
    end
  end

  def find_unit
    @unit = Unit.find params[:id]
    unless @unit
      # raise error!
    end
  end

end

