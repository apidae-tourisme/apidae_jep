module Moderator::EventPollsHelper
  def poll_columns
    {
        program_item: ['town', 'title', 'item_type', 'criteria', 'themes'],
        event_poll: ['count_sat', 'count_sun', 'comments', 'poll_general_comments', 'poll_com_comments', 'poll_theme_comments'],
        user: ['full_name', 'email', 'telephone', 'entity_name']
    }
  end

  def poll_values(user, item)
    values = []
    poll_columns.each_pair do |obj, cols|
      case obj
        when :program_item
          values += cols.collect do |c|
            val = item.send(c)
            (val && val.is_a?(Array)) ? val.select {|v| !v.blank?}.map {|v| ALL_REFS[v] || v}.join(' | ') : val
          end
        when :event_poll
          values += (user.active_poll ? cols.collect {|c| user.active_poll.send(c, item.id)} : cols.map {|c| ''})
        else
          values += cols.collect {|c| user.send(c)}
      end
    end
    values
  end
end
