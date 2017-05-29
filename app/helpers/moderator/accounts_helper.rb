module Moderator::AccountsHelper
  def render_com_kit(poll)
    poll.communication_data.collect {|com| "#{t('com_kit.format.' + com[0])} : #{com[1]}"}.join("\n")
  end
end
