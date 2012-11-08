class Admin::RolesController < AdminController

  before_filter :find_role, :only => [ :show, :edit, :update, :destroy ]

  def index
    @groups = @company.groups
    @titles = @company.titles
    @units = @company.units
    @roles = Role.all
  end

  def destroy
    @role.destroy
    flash[:notice] = "Role has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_roles_path }
    end
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new( params[:role] )
    if @role.save
      flash[:notice] = "Role has been created"
      respond_to do |format|
        format.js
        format.html { redirect_to admin_roles_path }
      end
    else
      flash[:notice] = "Role can not be saved"
      respond_to do |format|
        format.js
        format.html { render :new }
      end
    end
  end

  def find_role
    @role = Role.find params[:id]
    unless @role
      # raise error!
    end
  end

  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Roles', :url => admin_roles_path }
  end

end

