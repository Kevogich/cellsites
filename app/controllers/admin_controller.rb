class AdminController < ApplicationController

  layout 'admin'

  before_filter :authenticate_admin!
  before_filter :set_company, :set_user_project_settings
  before_filter :access_permission
  before_filter :set_breadcrumbs

  helper_method :user_access_type, :user_project_setting
  helper_method :clients, :projects, :process_units

  def index

  end

  #js file
  def sizing_data
    
    @project_units = current_user.user_project_setting.project.project_units
    @project_units1 = current_user.user_project_setting.project.project_units1
    
    respond_to do |format|
      format.js     
    end        
  end

  def client_projects
    projects = projects(params[:client_id]).map do |p|
      {:id => p.id, :project_num => p.project_num}
    end
    render :json => {:projects => projects}
  end

  def project_process_units
    process_units = process_units(params[:project_id]).map do |p|
      {:id => p.id, :name => p.name}
    end
    render :json => {:process_units => process_units}
  end

  private

  def authenticate_admin!
    #unless current_user.has_role?( 'admin' )
    unless current_user.roles
      flash[:error] = "Access Denied"
      redirect_to root_url
    end
  end

  def set_company
    unless @company = current_user.company
      flash[:error] = "Company not found"
      sign_out current_user
      redirect_to new_user_session_url
    end
  end

  def user_access_type
    return @user_access_type if defined?(@user_access_type)
    if current_user.role == "project_execution"
		@user_access_type = 0 
	else
		@user_access_type = 1 
	end
  end


  def access_permission
	  if !params[:controller].include?("sizing")
		  default_actions = %w(new create edit update destroy)
		  if current_user.role == "project_execution" && default_actions.include?(params[:action])
			  flash[:error] = 'Access denied you have Read Only permissions'
			  redirect_to :back
		  end
	  end
  end
  
  def set_user_project_settings
    @user_project_settings = current_user.user_project_setting
    if @user_project_settings.nil?
      @user_project_settings = UserProjectSetting.new({:user_id => current_user.id})
      @user_project_settings.save(:validate =>false)
    end
  end

  def user_project_setting
    return @user_project_setting if defined?(@user_project_setting)
    @user_project_setting = current_user.user_project_setting
  end

  def clients
    return @clients if defined?(@clients)
    @clients = @company.clients
  end

  def projects(client_id)
    return @projects if defined?(@projects)
    @projects = @company.projects.where(:client_id => client_id)
  end

  def process_units(project_id)
    return @process_units if defined?(@process_units)
    @process_units = @company.process_units.where(:project_id => project_id)
  end
  
  def set_breadcrumbs    
    @breadcrumbs ||= []
    @breadcrumbs << { :name => 'Home', :url => root_path }
    @breadcrumbs << { :name => "#{@company.name} Admin", :url => admin_home_path }
  end
end
