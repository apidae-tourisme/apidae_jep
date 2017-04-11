module User::ProgramsHelper
  def default_opening(opening)
    opening.starts_at = DateTime.new(2017, 9, 16, 10, 0, 0)
    opening
  end

  def ellipsis(text)
    text.length > 255 ? (text[0, 255] + '...') : text
  end
end
