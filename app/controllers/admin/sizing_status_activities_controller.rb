class Admin::SizingStatusActivitiesController < AdminController

	def show
		@company_users = @company.company_users.includes(:user).where("access_type_id = 1 AND user_id <> ?", current_user.id)
		@latest_status = SizingStatusActivity.find(params[:id])
		@sizing_statues = @latest_status.status_history
		@sizing_status_activity = SizingStatusActivity.new

		render :layout => false
	end

	def create
		@latest_status = SizingStatusActivity.find(params[:sizing_status_activity_id])
		sizing_status_activity = SizingStatusActivity.new(params[:sizing_status_activity])
		sizing_status_activity.user_id = @latest_status.request_user_id if sizing_status_activity.status == 'reject_review'
		#if reject approval, this is sent back to user who initiated it
		if sizing_status_activity.status == 'reject_approval'
			sizing = @latest_status.sizing
			s = sizing.sizing_status_activities.where(:status => "new").first
			sizing_status_activity.user_id  = s.user_id
		end
		sizing_status_activity.user_id = current_user.id if sizing_status_activity.status == 'reviewed' || sizing_status_activity.status == 'approved'
		sizing_status_activity.request_user_id = current_user.id

		if sizing_status_activity.save
			@message = "saved successfully."
		else
			@message = "something is wrong."
		end
	end
end
