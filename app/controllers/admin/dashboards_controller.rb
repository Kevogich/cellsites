class Admin::DashboardsController < ApplicationController
	layout 'admin'

  def show
	  @clients = []
	  current_user.projects.each do |p|
		  @clients << p.client
	  end
  end

  def projects
	  @client = Client.find(params[:id])
	  @projects = @client.projects
  end

  def process_units
	  @project = Project.find(params[:id])
      user_project_setting = current_user.user_project_setting
	  @default_process_unit_id = user_project_setting.process_unit_id rescue 0
	  @process_units = @project.process_units
  end

  def setdefault
	  process_unit = ProcessUnit.find(params[:id])
	  project = process_unit.project
      user_project_setting = current_user.user_project_setting
	  user_project_setting.update_attributes(:project_id => project.id, :process_unit_id => params[:id], :client_id => project.client.id)
	  redirect_to "#{process_units_admin_dashboard_path}?id=#{project.id}"
  end

  def clients
  end

  def set_breadcrumbs
	  super
      @breadcrumbs << { :name => 'Clients', :url => admin_clients_path }
  end
end
