class AddDeliveryCommentsToCommunicationPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :communication_polls, :delivery_comments, :text
  end
end
