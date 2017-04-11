class Program < ActiveRecord::Base
  has_many :program_items
  has_and_belongs_to_many :users

  def ordered_items
    program_items.order(:ordering)
  end

  def visible_items
    program_items.order(:ordering)
        .where(status: [ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED, ProgramItem::STATUS_REJECTED])
  end

  def label(idx)
    title.blank? ? "Programmation #{idx}" : title
  end

  def structure
    (users.any? && users.first.legal_entity) ? users.first.legal_entity.name : 'Inconnue'
  end
end
