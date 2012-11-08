class Superadmin::CompaniesController < SuperadminController

  before_filter :find_company, :only => [ :show, :edit, :update, :destroy ]

  def index
    @companies = Company.all
  end

  def show
  end

  def destroy
    @company.destroy
    flash[:notice] = "Company has been deleted"
    redirect_to superadmin_companies_path
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new( params[:company] )
    if @company.save
      flash[:notice] = "Company has been created"
      redirect_to superadmin_companies_path
    else
      flash[:notice] = "Company can not be saved"
      render :new
    end
  end

  def update
    if @company.update_attributes( params[:company] )
      flash[:notice] = "Company has been updated"
      redirect_to superadmin_company_path( @company )
    else
      flash[:notice] = "Company can not be saved"
      render :edit
    end
  end

  def find_company
    @company = Company.find params[:id]
    unless @company
      # raise error!
    end
  end

  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Companies', :url => superadmin_companies_path }
  end

end


