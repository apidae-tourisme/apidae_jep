class ItemOpening < ActiveRecord::Base
  belongs_to :program_item

  before_save :update_description

  def as_text
    description.blank? ? compute_description : description
  end

  def compute_description
    if starts_at
      start_str = I18n.l(starts_at, format: :full)
      (ends_at && ends_at > starts_at) ? "Du #{start_str} au #{I18n.l(end_at, format: :full)}" : start_str
    else
      'Non renseignée'
    end
  end

  private

  def update_description
    self.description = compute_description
  end
end
