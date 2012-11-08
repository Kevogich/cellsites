class ApplicationController < ActionController::Base

  before_filter :authenticate_user!
  after_filter :flash_to_headers

  helper :all

  protect_from_forgery

  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      if resource_or_scope.has_role?('superadmin')
        superadmin_home_url
      elsif resource_or_scope.role == 'project_execution' || resource_or_scope.role == 'project_setup'
		  admin_dashboard_path
      else
        admin_home_url
      end
    else
      super
    end
  end
  
  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash[:error] unless flash[:error].blank?
  end


end
