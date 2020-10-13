class ApplicationController < ActionController::Base

  before_filter :authenticate_user!
  after_filter :flash_to_headers

  helper :all
  helper_method :mda

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

  private

  #creating multidimensional array
  #ref link http://www.ehow.com/how_2091651_create-multidimensional-array-ruby.html
  def mda(width,height)
    Array.new(width).map!{ Array.new(height) }
  end


end

  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash[:error] unless flash[:error].blank?
  end

  private

  #creating multidimensional array
  #ref link http://www.ehow.com/how_2091651_create-multidimensional-array-ruby.html
  def mda(width,height)
    Array.new(width).map!{ Array.new(height) }
  end


end
