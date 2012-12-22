class CommentsController < ApplicationController

  def create
    #raise params.inspect
    @comment = Comment.new(params[:comment])
    @comment.item_tag_tab = params[:attachment_vendor] if params[:comment][:commentable_type] == "ItemTypesTransmitAndProposal"
    @comment.user_id = current_user.id
    @comment.save

    flash[:notice] = "Comment Saved"

    redirect_to :back
  end

end
