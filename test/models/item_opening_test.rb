require 'test_helper'

class ItemOpeningTest < ActiveSupport::TestCase

  test 'description with start date only' do
    opening = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 17, 20, 0))
    assert_equal 'Mercredi 5 Avril 2017 à partir de 17:20', opening.as_text
  end

  test 'description with two different dates' do
    opening = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 17, 20, 0), ends_at: DateTime.new(2017, 4, 6, 14, 0, 0))
    assert_equal 'Du mercredi 5 Avril 2017 à 17:20 au jeudi 6 Avril 2017 à 14:00', opening.as_text
  end

  test 'description with same date twice' do
    opening = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 5, 18, 0, 0))
    assert_equal 'Mercredi 5 Avril 2017 de 10:00 à 18:00', opening.as_text
  end

  test 'description with same date twice and a frequency' do
    opening_hour = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 5, 18, 0, 0), frequency: 1.hour)
    opening_hours = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 5, 18, 0, 0), frequency: 2.hours)
    opening_mins = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 5, 18, 0, 0), frequency: 600)
    opening_mixed = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 5, 18, 0, 0), frequency: 7800)
    assert_equal 'Mercredi 5 Avril 2017, toutes les heures entre 10:00 et 18:00', opening_hour.as_text
    assert_equal 'Mercredi 5 Avril 2017, toutes les 2 heures entre 10:00 et 18:00', opening_hours.as_text
    assert_equal 'Mercredi 5 Avril 2017, toutes les 10 minutes entre 10:00 et 18:00', opening_mins.as_text
    assert_equal 'Mercredi 5 Avril 2017, toutes les 2 heures et 10 minutes entre 10:00 et 18:00', opening_mixed.as_text
  end

  test 'description with different dates and a frequency' do
    opening_hour = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 6, 18, 0, 0), frequency: 1.hour)
    opening_hours = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 6, 18, 0, 0), frequency: 2.hours)
    opening_mins = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 6, 18, 0, 0), frequency: 600)
    opening_mixed = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 6, 18, 0, 0), frequency: 7800)
    assert_equal 'Du mercredi 5 Avril 2017 au jeudi 6 Avril 2017, toutes les heures entre 10:00 et 18:00', opening_hour.as_text
    assert_equal 'Du mercredi 5 Avril 2017 au jeudi 6 Avril 2017, toutes les 2 heures entre 10:00 et 18:00', opening_hours.as_text
    assert_equal 'Du mercredi 5 Avril 2017 au jeudi 6 Avril 2017, toutes les 10 minutes entre 10:00 et 18:00', opening_mins.as_text
    assert_equal 'Du mercredi 5 Avril 2017 au jeudi 6 Avril 2017, toutes les 2 heures et 10 minutes entre 10:00 et 18:00', opening_mixed.as_text
  end

  test 'description with frequency and duration' do
    opening_hour = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), ends_at: DateTime.new(2017, 4, 5, 18, 0, 0),
                                   frequency: 1.hour, duration: 10.minutes)
    assert_equal 'Mercredi 5 Avril 2017, toutes les heures entre 10:00 et 18:00 - Durée : 10 minutes', opening_hour.as_text
  end

  test 'description with start date and frequency' do
    opening_hour = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), frequency: 10.minutes)
    assert_equal 'Mercredi 5 Avril 2017, toutes les 10 minutes à partir de 10:00', opening_hour.as_text
  end

  test 'description with start date and duration' do
    opening_hour = ItemOpening.new(starts_at: DateTime.new(2017, 4, 5, 10, 0, 0), duration: 1.hour)
    assert_equal 'Mercredi 5 Avril 2017 à 10:00 - Durée : 1 heure', opening_hour.as_text
  end

end
