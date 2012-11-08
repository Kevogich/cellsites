class Admin::UsersController < AdminController

  before_filter :find_user, :only => [ :show, :edit, :update, :destroy ]

  def index
    @users = User.all
  end

  def show
  end

  def destroy
    @user.destroy
    flash[:notice] = "User has been deleted"
    redirect_to admin_users_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new( params[:user] )
    if @user.save
      flash[:notice] = "User has been created"
      redirect_to admin_users_path
    else
      flash[:notice] = "User can not be saved"
      render :new
    end
  end

  def update
    if @user.update_attributes( params[:user] )
      flash[:notice] = "User has been updated"
      redirect_to admin_user_path( @user )
    else
      flash[:notice] = "User can not be saved"
      render :edit
    end
  end

  def find_user
    @user = User.find params[:id]
    unless @user
      # raise error!
    end
  end

  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Users', :url => admin_users_path }
  end

end

