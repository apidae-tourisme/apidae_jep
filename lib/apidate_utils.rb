require 'kafka'

class ApidateUtils

  # Usage example :
  # ProgramItem.in_status(GRAND_LYON, 2020, ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED).each do |p|
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

  def self.duplicate_apidate_entry(source_id, target_id, user_id)
    kafka = Kafka.new([Rails.application.config.kafka_host], client_id: "jep_openings")
    kafka.deliver_message('{"operation":"DUPLICATE_PERIOD","sourceObjectId":"' + source_id.to_s + '",' +
                          '"duplicatedObjectId":"' + target_id.to_s + '","userId":"' + user_id.to_s + '"}',
                          topic: 'apidae_period')
  end
end

## "reference": 6993,
## "reference": 6358,
## "reference": 7208,
## "reference": 7310,
## "reference": 6730,
## "reference": 7423,
## "reference": 6998,
## "reference": 6440,
## "reference": 6670,
## "reference": 6675,
## "reference": 6273,
## "reference": 7390,
## "reference": 6572,
## "reference": 7012,
## "reference": 7003,
## "reference": 7133,
## "reference": 6852,
## "reference": 7001,
## "reference": 7272,
## "reference": 6618,
## "reference": 7422,
## "reference": 7062,
## "reference": 7002,
## "reference": 7304,
## "reference": 7004,
## "reference": 7312,
## "reference": 7242,
## "reference": 6990,
## "reference": 7081,
## "reference": 6316,
## "reference": 7311,
## "reference": 7095,
## "reference": 6289,
## "reference": 7056,
## "reference": 7023,
## "reference": 7267,
## "reference": 6483,
## "reference": 7313,
## "reference": 6278, (RAS)
## "reference": 7270,
## "reference": 6681,
## "reference": 7365,
# "reference": 6288

6993, 6358, 7208, 7310, 6730, 7423, 6998, 6440, 6670, 6675, 6273, 7390, 6572, 7012, 7003, 7133, 6852, 7001, 7272, 6618, 7422, 7062, 7002, 7304, 7004, 7312, 7242, 6990, 7081, 6316, 7311, 7095, 6289, 7056, 7023, 7267, 6483, 7313, 6278, 7270, 6681, 7365, 6288