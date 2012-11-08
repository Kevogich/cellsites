class SizingStatusActivity < ActiveRecord::Base

  #acts_as_state_machine :initial => :new,  :column => 'status'

  belongs_to :user
  belongs_to :sizing, :polymorphic => true

=begin
  state :new
  state :pending_review
  state :reviewed
  state :pending_approval
  state :approved

  event :submit_review do
    transitions :to => :pending_review, :from => :new
  end

  event :reviewed do
    transitions :to => :reviewed, :from => :pending_review
  end

  event :submit_approval do
    transitions :to => :pending_approval, :from => :reviewed
  end

  event :approved do
    transitions :from => :pending_approval, :to => :approved
  end
=end

  def self.latest_status
    order('created_at DESC').first
  end

  def status_history
    statues = sizing.sizing_status_activities
    .select("sizing_status_activities.status, sizing_status_activities.created_at, requester.name AS requester_name, action_perform.name AS action_perform_name, sizing_status_activities.sizing_type, sizing_status_activities.sizing_id")
    .joins("INNER JOIN users requester on requester.id = sizing_status_activities.request_user_id")
    .joins("INNER JOIN users action_perform on action_perform.id = sizing_status_activities.user_id")
    .order('sizing_status_activities.id DESC')
  end

  def self.reviewer
    rs_status = where("status = 'reviewed'").first
    rs_status.user.name rescue ''
  end

  def self.created_by
  	rs_status = where("status = 'new'").first
    rs_status.user.name rescue ''
  end

  def self.approver
    rs_status = where("status = 'approved'").first
    rs_status.user.name rescue ''
  end
end
