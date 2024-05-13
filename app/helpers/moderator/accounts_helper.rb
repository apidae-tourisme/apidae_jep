module Moderator::AccountsHelper
  def render_com_kit(poll)
    poll.communication_data.collect {|com| "#{t('com_kit.format.' + com[0])} : #{com[1]}"}.join("\n")
  end

  def com_kit_columns
    ['last_update', 'ref_person', 'entity', 'full_address', 'delivery_comments', 'flyers', 'posters1', 'posters2', 'signs']
  end

  def com_kit_values(kit)
    com_kit_columns.collect {|col| kit.send(col)}
  end

  def user_columns
    ['full_name', 'email', 'telephone', 'entity_name', 'entity_town', 'entity_address', 'communication', 'creation_year'] +
      (2018..EDITION).to_a.map {|y| ['offers_by_year', y]} +
      ['offers_count', 'gdpr_status', 'auth_provider', 'entity_apidae_id']
  end

  def user_values(usr)
    user_columns.collect {|col| col.is_a?(Array) ? usr.send(col.first).dig(*col[1..-1]) : usr.send(col)}
  end
end
