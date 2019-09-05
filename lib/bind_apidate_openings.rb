require './lib/apidate_utils.rb'

ProgramItem.in_status(GRAND_LYON, 2019, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  if ApidateUtils.fix_apidate_openings(p.id)
    sleep(2)
  else
    sleep(0.5)
  end
end

ProgramItem.in_status(ISERE, 2019, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  if ApidateUtils.fix_apidate_openings(p.id)
    sleep(2)
  else
    sleep(0.5)
  end
end