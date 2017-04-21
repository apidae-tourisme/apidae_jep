class AddDeliveryCommentsToCommunicationPolls < ActiveRecord::Migration
  def change
    add_column :communication_polls, :delivery_comments, :text
  end
end
