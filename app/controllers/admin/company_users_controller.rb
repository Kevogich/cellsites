class Admin::CompanyUsersController < AdminController

  before_filter :find_company_user, :only => [ :show, :edit, :update, :destroy ]

  def index
    @company_users = @company.company_users
	@titles = {}
	Title.all.collect do |t|
		@titles[t.id] = t.name
	end
  end

  def show
  end

  def edit
    @attachments = @company_user.attachments
    @new_attachment = @company_user.attachments.new
    @comments = @company_user.comments
    @new_comment = @company_user.comments.new
  end

  def destroy
    @company_user.destroy
    flash[:notice] = "User has been deleted"
    redirect_to admin_company_users_path
  end

  def new
    @company_user = CompanyUser.new
    @company_user.user = User.new
  end

  def create
	ids = params[:company_user][:user_attributes][:role_ids]
	params[:company_user][:user_attributes][:role_ids] = [ids]
    @company_user = @company.company_users.new(params[:company_user])

    if @company_user.save
      flash[:notice] = "User has been created"
      redirect_to admin_company_users_path
    else
      flash[:notice] = "User cannot be saved"
      render :new
    end
  end

  def update
	ids = params[:company_user][:user_attributes][:role_ids]
	params[:company_user][:user_attributes][:role_ids] = [ids]
    if @company_user.update_attributes( params[:company_user] )
      flash[:notice] = "User has been updated"
      redirect_to admin_company_user_path( @company_user )
    else
      flash[:notice] = "User cannot be saved"
      render :edit
    end
  end

  def find_company_user
    @company_user = CompanyUser.find params[:id]
    unless @company_user
      # raise error!
    end
  end

  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Users', :url => admin_company_users_path }
  end

end

