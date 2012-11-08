class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :user
  belongs_to :commentable, :polymorphic => true

  default_scope :order => 'created_at DESC'
  scope :recent, order('created_at DESC').limit(5)
end
