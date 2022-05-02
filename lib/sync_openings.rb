require './lib/apidate_utils.rb'

# Syncs recently updated offers for all territories (run hourly)

ProgramItem.in_status(GRAND_LYON, EDITION, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  synced = ApidateUtils.sync_openings(p.id, false, false)
  if !synced.blank?
    sleep(2)
  else
    sleep(0.5)
  end
end

ProgramItem.in_status(ISERE, EDITION, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  synced = ApidateUtils.sync_openings(p.id, false, false)
  if !synced.blank?
    sleep(2)
  else
    sleep(0.5)
  end
end

ProgramItem.in_status(SAUMUR, EDITION, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  synced = ApidateUtils.sync_openings(p.id, false, false)
  if !synced.blank?
    sleep(2)
  else
    sleep(0.5)
  end
end