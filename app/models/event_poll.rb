class EventPoll < ActiveRecord::Base
  store :event_data, accessors: [:general_comments, :theme_comments], coder: JSON
  store :offers_data, accessors: [:offers_feedback], coder: JSON

  belongs_to :user

  def offer_count(date, offer_id)
    unless offers_feedback.nil?
      offers_feedback[offer_id.to_s] && offers_feedback[offer_id.to_s]['count'] ? offers_feedback[offer_id.to_s]['count'][date] : nil
    end
  end

  def closed(date, offer_id)
    unless offers_feedback.nil?
      offers_feedback[offer_id.to_s] && offers_feedback[offer_id.to_s]['closed'] ? offers_feedback[offer_id.to_s]['closed'][date] : nil
    end
  end

  def comments(offer_id)
    unless offers_feedback.nil?
      offers_feedback[offer_id.to_s]['comments']
    end
  end
end
