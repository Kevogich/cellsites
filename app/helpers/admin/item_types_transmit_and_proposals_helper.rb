module Admin::ItemTypesTransmitAndProposalsHelper
  def item_tag_status(item_tag)
    @latest_status =
    @latest_status.status.humanize
  end
end
