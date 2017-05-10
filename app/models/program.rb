class Program < ActiveRecord::Base
  has_many :program_items
  has_and_belongs_to_many :users

  def ordered_items
    program_items.order(:ordering)
  end

  def visible_items
    active_items
        .where(status: [ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED, ProgramItem::STATUS_REJECTED])
  end

  def active_items
    active_ids = program_items.select("MAX(id) AS id").group(:reference)
    program_items.where(id: active_ids).order(:ordering)
  end


  def label(idx)
    title.blank? ? "Programmation #{idx}" : title
  end

  def structure
    (users.any? && users.first.legal_entity) ? users.first.legal_entity.label : 'Inconnue'
  end
end
