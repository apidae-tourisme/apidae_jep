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
  def self.fix_apidate_openings(item_id, dry_run = false)
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
      p.update_remote_ids(local_remote_ids, dry_run)
      total += local_remote_ids.keys.length
    end
    total
  end

  def self.sync_openings(item_id, force_sync, dry_run = false)
    synced_openings = {}
    p = ProgramItem.find(item_id)
    if force_sync || p.updated_at > (Time.current - 1.hour)
      p.set_openings(!dry_run)
      apidate_openings = p.apidate_openings || []
      local_ids = p.openings.values.select {|id| !id.blank?}.map {|id| id.to_s}
      remote_ids = apidate_openings.map {|op| op['externalId'].to_s}
      ids_to_sync = local_ids - remote_ids
      unless ids_to_sync.blank?
        ids_by_date = apidate_openings.group_by {|op| op['startDate']}
                          .transform_values {|values| values.sort_by {|val| (1.0 / val["updatedAt"])}.first['externalId']}
        local_remote_ids = {}
        p.openings.each_pair do |date, opening_id|
          local_remote_ids[opening_id] = ids_by_date[date] unless (opening_id.blank? || ids_by_date[date].blank?)
        end
        p.update_remote_ids(local_remote_ids, dry_run)
        synced_openings.merge! local_remote_ids
      end
    end
    synced_openings
  end

  def self.duplicate_apidate_entry(source_id, target_id, user_id)
    kafka = Kafka.new([Rails.application.config.kafka_host], client_id: "jep_openings")
    kafka.deliver_message('{"operation":"DUPLICATE_PERIOD","sourceObjectId":"' + source_id.to_s + '",' +
                          '"duplicatedObjectId":"' + target_id.to_s + '","userId":"' + user_id.to_s + '"}',
                          topic: 'apidae_period')
  end
end
