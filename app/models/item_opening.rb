class ItemOpening < ActiveRecord::Base
  include I18n::Base

  belongs_to :program_item

  FULL = '%A %-e %B %Y à %H:%M'
  DATE_ONLY = '%A %-e %B %Y'
  TIME_ONLY = '%H:%M'

  validates_presence_of :starts_at

  before_save :update_description

  def as_text
    description.blank? ? compute_description : description
  end

  def compute_description
    desc = 'Non renseignée'
    if starts_at
      start_str = l(starts_at, format: FULL)
      if ends_at
        if ends_at.to_date == starts_at.to_date
          if frequency
            desc = "#{l(starts_at, format: DATE_ONLY).titleize}, toutes les #{frequency_as_text(frequency)} entre #{l(starts_at, format: TIME_ONLY)} et #{l(ends_at, format: TIME_ONLY)}"
          else
            desc = "#{l(starts_at, format: DATE_ONLY).titleize} de #{l(starts_at, format: TIME_ONLY)} à #{l(ends_at, format: TIME_ONLY)}"
          end
        elsif ends_at > starts_at
          if frequency
            desc = "Du #{l(starts_at, format: DATE_ONLY)} au #{l(ends_at, format: DATE_ONLY)}, toutes les #{frequency_as_text(frequency)} entre #{l(starts_at, format: TIME_ONLY)} et #{l(ends_at, format: TIME_ONLY)}"
          else
            desc = "Du #{start_str} au #{l(ends_at, format: FULL)}"
          end
        end
      else
        if frequency
          desc = "#{l(starts_at, format: DATE_ONLY).titleize}, toutes les #{frequency_as_text(frequency)} à partir de #{l(starts_at, format: TIME_ONLY)}"
        else
          desc = duration ? start_str.titleize : start_str.titleize.gsub('à', 'à partir de')
        end
      end
      desc += " - Durée : #{duration_as_text(duration)}" if duration
    end
    desc
  end

  private

  def update_description
    self.description = compute_description
  end

  def duration_as_text(d)
    unless d.blank?
      mins = d / 60
      if mins < 60
        mins  > 1 ? "#{mins} minutes" : 'minutes'
      else
        hour_fraction = mins % 60
        hours = (mins - hour_fraction) / 60
        if hour_fraction == 0
          hours > 1 ? "#{hours} heures": '1 heure'
        else
          "#{hours} heure#{'s' if hours > 1} et #{hour_fraction} minute#{'s' if hour_fraction > 1}"
        end
      end
    end
  end

  def frequency_as_text(d)
    unless d.blank?
      mins = d / 60
      if mins < 60
        mins  > 1 ? "#{mins} minutes" : 'minutes'
      else
        hour_fraction = mins % 60
        hours = (mins - hour_fraction) / 60
        if hour_fraction == 0
          hours > 1 ? "#{hours} heures": 'heures'
        else
          "#{hours} heure#{'s' if hours > 1} et #{hour_fraction} minute#{'s' if hour_fraction > 1}"
        end
      end
    end
  end
end
