module Moderator::AccountsHelper
  def render_com_kit(poll)
    poll.communication_data.collect {|com| "#{t('com_kit.format.' + com[0])} : #{com[1]}"}.join("\n")
  end

  def com_kit_columns
    ['ref_person', 'entity', 'full_address', 'delivery_comments', 'flyers', 'posters1', 'posters2', 'signs']
  end

  def com_kit_values(kit)
    com_kit_columns.collect {|col| kit.send(col)}
  end

  def user_columns
    ['full_name', 'email', 'telephone', 'entity_name', 'entity_address', 'communication', 'offers_count', 'programs_count', 'entity_apidae_id']
  end

  def user_values(usr)
    user_columns.collect {|col| usr.send(col)}
  end
end
