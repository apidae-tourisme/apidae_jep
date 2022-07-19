class BatchOperations
  POSTER_FILE_NAME = 'affiche-jep-isere-2022.jpg'

  def self.decorate_isere_events(apidae_ids = [])
    items = ProgramItem.in_status(ISERE, 2022, ProgramItem::STATUS_VALIDATED)
    items = items.where(external_id: apidae_ids) unless apidae_ids.blank?

    items.each do |item|
      decorate_item(item)
    end
  end

  def self.decorate_item(item)
    item_files = item.attached_files.map {|af| af.picture_file_name}

    unless item_files.include?(POSTER_FILE_NAME)
      Rails.logger.info "Decorating item #{item.id} - #{item.external_id}"
      item.attached_files << AttachedFile.new(picture: URI.parse("https://jep.apidae-tourisme.com/#{POSTER_FILE_NAME}"),
                                              credits: "Département de l'Isère")
      item.save!
      item.remote_save
      Rails.logger.info "Finished decorating item #{item.id} - #{item.external_id}"
    end
  end
end