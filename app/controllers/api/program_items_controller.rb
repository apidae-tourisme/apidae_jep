class Api::ProgramItemsController < Api::ApiController
  def index
    @items = []
    @member_ref = params[:ref]
    unless @member_ref.blank?
      @items = ProgramItem.in_status(@member_ref, ProgramItem::STATUS_VALIDATED)
    end
  end

  def json_example
    render inline: '<div style="white-space: pre; font-family: Courier;">' + File.read("#{Rails.root}/public/item_export.json") + '</div>'
  end
end