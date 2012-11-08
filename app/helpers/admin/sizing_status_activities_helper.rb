module Admin::SizingStatusActivitiesHelper

  def sizing_status(sizing)
    @latest_status = sizing.sizing_status_activities.latest_status
    @latest_status.status.humanize
  end

  # @param sizing [Object]
  def sizing_status_request_button(sizing)
    @latest_status = sizing.sizing_status_activities.latest_status if defined?(@latest_status)
    if (@latest_status.status == 'new' || @latest_status.status == 'reject_review') && @latest_status.user_id == current_user.id
      link_text = "Request for Review"
    elsif @latest_status.status == 'pending_review' && @latest_status.user_id == current_user.id
      link_text = "Review"
    elsif (@latest_status.status == 'reviewed' || @latest_status.status == 'reject_approval') && @latest_status.user_id == current_user.id
      link_text = 'Request for Approval'
    elsif @latest_status.status == 'pending_approval' && @latest_status.user_id == current_user.id
      link_text = 'Approve'
    else
      link_text = 'View Status History'
    end

    content_tag :a, :href => admin_sizing_status_activity_path(@latest_status), :class => 'btn sizing_status_btn' do
      link_text
    end
  end
end
