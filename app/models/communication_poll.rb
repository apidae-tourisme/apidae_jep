class CommunicationPoll < ActiveRecord::Base
  store :communication_data, accessors: [:flyers, :posters1, :posters2, :signs], coder: JSON

  belongs_to :town, foreign_key: :town_insee_code, primary_key: :insee_code
  belongs_to :delivery_town, class_name: 'Town', foreign_key: :delivery_insee_code, primary_key: :insee_code

  belongs_to :user
end
