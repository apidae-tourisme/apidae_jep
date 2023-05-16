class EventPoll < ActiveRecord::Base
  store :event_data, accessors: [:general_comments, :theme_comments, :com_comments], coder: JSON
  store :offers_data, accessors: [:offers_feedback], coder: JSON

  belongs_to :user

  def offer_count(date, offer_id)
    unless offers_feedback.nil?
      cnt = offers_feedback.dig(offer_id.to_s, 'count', date)
      cnt || (offers_feedback.dig(offer_id.to_s, 'unknown', date) == '1' ? 'non renseigné' : 'fermé(e)')
    end
  end

  def unknown(date, offer_id)
    unless offers_feedback.nil?
      offers_feedback[offer_id.to_s] && offers_feedback[offer_id.to_s]['unknown'] ? offers_feedback[offer_id.to_s]['unknown'][date] : nil
    end
  end

  def closed(date, offer_id)
    unless offers_feedback.nil?
      offers_feedback[offer_id.to_s] && offers_feedback[offer_id.to_s]['closed'] ? offers_feedback[offer_id.to_s]['closed'][date] : nil
    end
  end

  def comments(offer_id)
    unless offers_feedback.nil?
      offers_feedback[offer_id.to_s] && offers_feedback[offer_id.to_s]['comments'] ? offers_feedback[offer_id.to_s]['comments'] : nil
    end
  end

  def count_sat(offer_id)
    offer_count('2023-09-16', offer_id)
  end

  def count_sun(offer_id)
    offer_count('2023-09-17', offer_id)
  end

  def poll_general_comments(offer_id)
    general_comments
  end

  def poll_theme_comments(offer_id)
    theme_comments
  end

  def poll_com_comments(offer_id)
    com_comments
  end
end
