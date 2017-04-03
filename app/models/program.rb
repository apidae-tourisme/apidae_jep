class Program < ActiveRecord::Base
  has_many :program_items
  has_and_belongs_to_many :users

  def ordered_items
    program_items.order(:ordering)
  end

  def label(idx)
    title.blank? ? "Programmation #{idx}" : title
  end
end
