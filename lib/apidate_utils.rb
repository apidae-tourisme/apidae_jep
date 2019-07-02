class ApidateUtils

  # Usage example :
  # ProgramItem.in_status(GRAND_LYON, 2019, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
  #   if ApidateUtils.fix_apidate_openings(p.id)
  #     sleep(3)
  #   else
  #     sleep(0.5)
  #   end
  # end
  def self.fix_apidate_openings(item_id)
    p = ProgramItem.find(item_id)
    ops = p.apidate_openings
    total = 0
    current_ids = p.openings.values.select {|id| !id.blank?}.map {|id| id.to_s}
    if ops && (current_ids & ops.map {|op| op['externalId'].to_s}).blank?
      ids_by_date = ops.group_by {|op| op['startDate']}
                     .transform_values {|values| values.sort_by {|val| (1.0 / val["updatedAt"])}.first['externalId']}
      local_remote_ids = {}
      p.openings.each_pair do |date, opening_id|
        local_remote_ids[opening_id] = ids_by_date[date] unless (opening_id.blank? || ids_by_date[date].blank?)
      end
      p.update_remote_ids(local_remote_ids)
      total += local_remote_ids.keys.length
    end
    total
  end
end