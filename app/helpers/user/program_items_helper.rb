module User::ProgramItemsHelper
  include ::ItemConcern

  #   Nothing to show on user side for now
  def render_previous(attr, rows = 1)
  end

  def render_previous_assoc(prev_objects, new_objects, attr, rows = 1)
  end
end
