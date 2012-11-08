class Admin::SizingsController < AdminController
  
  def index   
    @user_project_setting = current_user.user_project_setting
    if @user_project_setting.nil?      
      @user_project_setting = UserProjectSetting.new({:user_id=>current_user.id})
      @user_project_setting.save(false)      
    else
      @user_project_setting = current_user.user_project_setting
    end
    
    @clients = @company.clients
    @projects = @company.projects.where(:client_id => (@user_project_setting.client_id rescue 0))
    @process_units = @company.process_units.where(:project_id => (@user_project_setting.project_id rescue 0))
        
    @projects = @company.projects
    @client_projects = {}
    @projects.each do |project|
      @client_projects[project.client_id.to_s] = [] if @client_projects[project.client_id.to_s].nil?
      @client_projects[project.client_id.to_s] << project
    end
    
    @project_process_units = {}    
    @company.process_units.each do |process_unit|
      @project_process_units[process_unit.project_id.to_s] = [] if @project_process_units[process_unit.project_id.to_s].nil?
      @project_process_units[process_unit.project_id.to_s] << process_unit
    end    
  end
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
  end
end
