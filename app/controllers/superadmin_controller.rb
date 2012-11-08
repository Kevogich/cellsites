class SuperadminController < ApplicationController

  before_filter :authenticate_superadmin!
  before_filter :set_breadcrumbs

  def index
  end

  private
  def authenticate_superadmin!
    unless current_user.has_role?( 'superadmin' )
      flash[:error] = "Access Denied"
      redirect_to root_url
    end
  end

  def set_breadcrumbs
    @breadcrumbs ||= []
    @breadcrumbs << { :name => 'Home', :url => root_path }
    @breadcrumbs << { :name => 'RaoTechAdmin', :url => superadmin_home_path }
  end
end
