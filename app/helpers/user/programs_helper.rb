module User::ProgramsHelper
  def default_opening(opening)
    opening.starts_at = DateTime.new(2017, 9, 16, 10, 0, 0)
    opening
  end

  def themes
    THEMES[GRAND_LYON].collect {|t| [t, t.parameterize]}
  end

  def criteria
    CRITERIA[GRAND_LYON].values.flatten.uniq.collect {|t| [t, t.parameterize]}
  end

  def accessibility
    ACCESSIBILITY[GRAND_LYON].collect {|t| [t, t.parameterize]}
  end
end
