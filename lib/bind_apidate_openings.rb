require './lib/apidate_utils.rb'

# Syncs all offers for all territories (run once a day)

ProgramItem.in_status(GRAND_LYON, 2022, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  synced = ApidateUtils.sync_openings(p.id, true, false)
  if !synced.blank?
    sleep(2)
  else
    sleep(0.5)
  end
end

ProgramItem.in_status(ISERE, 2022, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  synced = ApidateUtils.sync_openings(p.id, true, false)
  if !synced.blank?
    sleep(2)
  else
    sleep(0.5)
  end
end

ProgramItem.in_status(SAUMUR, 2022, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  synced = ApidateUtils.sync_openings(p.id, true, false)
  if !synced.blank?
    sleep(2)
  else
    sleep(0.5)
  end
end