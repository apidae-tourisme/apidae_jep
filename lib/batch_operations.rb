class BatchOperations
  POSTER_FILE_NAME = 'affiche-jep-isere-2024.jpg'

  def self.decorate_isere_events(apidae_ids = [])
    items = ProgramItem.in_status(ISERE, 2024, ProgramItem::STATUS_VALIDATED)
    items = items.where(external_id: apidae_ids) unless apidae_ids.blank?

    items.each do |item|
      decorate_item(item)
      sleep(1)
    end
  end

  def self.decorate_item(item)
    item_files = item.attached_files.map {|af| af.picture_file_name}

    unless item_files.include?(POSTER_FILE_NAME)
      begin
        Rails.logger.info "Decorating item #{item.id} - #{item.external_id}"
        previous_posters = item.attached_files.select {|af| ['affiche-jep-isere-2022.jpg', 'affiche-jep-isere-2023.jpg'].include?(af.picture_file_name)}
        if previous_posters.any?
          previous_posters.each {|p| item.attached_files.delete(p)}
        end
        af = AttachedFile.new(picture: open(URI.parse("https://jep.apidae-tourisme.com/#{POSTER_FILE_NAME}")),
                              credits: "Département de l'Isère")
        af.picture.instance_write(:file_name, POSTER_FILE_NAME)
        item.attached_files << af
        item.save!
        item.remote_save(true)
        Rails.logger.info "Finished decorating item #{item.id} - #{item.external_id}"
      rescue OAuth2::Error => e
        Rails.logger.error "OAuth2::Error for item #{item.id} - #{item.external_id}"
        Rails.logger.error e
      rescue Exception => e
        Rails.logger.error "Exception caught for item #{item.id} - #{item.external_id}"
        Rails.logger.error e
      end
    end
  end
end