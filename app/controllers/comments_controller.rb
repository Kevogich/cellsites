class CommentsController < ApplicationController

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.save

    flash[:notice] = "Comment Saved"

    redirect_to :back
  end

end
