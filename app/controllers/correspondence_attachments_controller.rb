# External Correspondence Attachments
class CorrespondenceAttachmentsController < ApplicationController
  before_action :authenticate_user!, :ensure_correspondence

  respond_to :json

  def create
    attachment = @correspondence.attachments.create
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      correspondence_attachments_params[:src],
      current_user.id
    )
    render json: attachment, status: :ok
  end

  def update
    attachment = CorrespondenceAttachment.find(params[:id])
    attachment.update(status: 'processing')
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      correspondence_attachments_params[:src],
      current_user.id
    )
    head :no_content
  end

  def destroy
    CorrespondenceAttachment.find(params[:id]).delete
    head :no_content
  end

  def show
    attachment = CorrespondenceAttachment.find(params[:id])
    render json: attachment, status: :ok
  end

  private

  def ensure_correspondence
    correspondence_id = params[:correspondence_id]
    if correspondence_id
      @correspondence = Correspondence.find params[:correspondence_id]
      requires_user_can :manage_workflow, @correspondence.paper
    else
      render :not_found
    end
  end

  def correspondence_attachments_params
    params.require(:correspondence_attachment).permit(:src, :filename)
  end
end
