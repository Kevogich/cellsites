class Admin::DriverSizingsController < AdminController
  
  def index
    @steam_turbines = @company.steam_turbines.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
    @hydraulic_turbines = @company.hydraulic_turbines.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
    @turbo_expanders = @company.turbo_expanders.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
    @eletric_motors = @company.electric_motors.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
    
    if @user_project_settings.client_id.nil?     
      flash[:error] = "Please Update Project Setting"      
      redirect_to admin_sizings_path
    end
  end
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
    @breadcrumbs << { :name => 'Driver Sizing', :url => admin_driver_sizings_path }
  end
end
