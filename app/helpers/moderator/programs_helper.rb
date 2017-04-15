module Moderator::ProgramsHelper
  def default_opening(opening)
    opening.starts_at = DateTime.new(2017, 9, 16, 10, 0, 0)
    opening
  end

  def ellipsis(text)
    text.length > 255 ? (text[0, 255] + '...') : text
  end

  def render_items(items)
    rendered = []
    items.each do |item|
      rendered << link_to(item.title, edit_moderator_program_program_item_path(item.program_id, item),
                          class: "label text-lg text-normal label-#{item_color(item.status)} inline")
    end
    rendered.join('<br/>').html_safe
  end
end
