class BatchOperations
  def self.decorate_isere_events(apidae_ids = [])
    items = ProgramItem.in_status(ISERE, 2022, ProgramItem::STATUS_VALIDATED)
    items = items.where(external_id: apidae_ids) unless apidae_ids.blank?

    items.each do |item|
      decorate_item(item)
    end
  end

  def self.decorate_item(item)
    Rails.logger.info "Decorating item #{item.id} - #{item.external_id}"
    item.attached_files << AttachedFile.new(picture: URI.parse('https://jep.apidae-tourisme.com/affiche-jep-isere-2022.jpg'),
                                            credits: "Département de l'Isère")

  end
end