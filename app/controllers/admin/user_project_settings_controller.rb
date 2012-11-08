class Admin::UserProjectSettingsController < ApplicationController
  
  def update
    @user_project_setting = current_user.user_project_setting
    if @user_project_setting.update_attributes(params[:user_project_setting])
      flash[:notice] = "Updated Project Settings successfully."
      redirect_to :back
    end
  end
end
