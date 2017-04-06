module User::ProgramsHelper
  def default_opening(opening)
    opening.starts_at = DateTime.new(2017, 9, 16, 10, 0, 0)
    opening
  end

  def item_icon(item_type)
    case item_type
      when ITEM_VISITE
        'fa-institution'
      when ITEM_PARCOURS
        'fa-map-signs'
      when ITEM_ANIMATION
        'fa-microphone'
      when ITEM_EXPOSITION
        'fa-photo'
      else
        'fa-institution'
    end
  end

  def ellipsis(text)
    text.length > 255 ? (text[0, 255] + '...') : text
  end
end
