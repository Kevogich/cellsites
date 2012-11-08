class AttachmentsController < ApplicationController

  def create

    @attachment = Attachment.new(params[:attachment])
    @attachment.user_id = current_user.id

    if @attachment.save
      flash[:notice] = "File Attached Successfully"
    else
      flash[:error] = "Failed to upload the attachment, Please try it again."
    end
    redirect_to :back
  end

  def get_attachment
    attachment = Attachment.find(params[:id])

    send_file attachment.attachment.path, :type => attachment.attachment_content_type, :disposition => 'inline'
  end
end
