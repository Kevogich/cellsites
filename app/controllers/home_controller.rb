class HomeController < ApplicationController

  before_filter :authenticate_user!, :except => [ :index ]

  def index
    redirect_to new_user_session_url and return unless user_signed_in?
    
    if current_user.has_role?('superadmin')
      redirect_to superadmin_home_url
    elsif current_user.has_role?('admin')      
      redirect_to admin_home_url
    else
      #redirect_to user_home_url
      redirect_to admin_home_url
    end   
    
  end

end
