module Api::ProgramItemsHelper
  def item_town(insee_code)
    Town.find_by_insee_code(insee_code)
  end

  def normalize_list(list)
    list.select {|v| !v.blank?}.map {|v| ALL_REFS[v] || v} if list
  end

  def openings_values(item)
    values = []
    item.openings_details.sort_by {|d| d['startDate']}.each do |op|
      op['timePeriods'].each do |tp|
        (tp['timeFrames'] || []).each do |tf|
          values << {
              starts_at: "#{op['startDate']}T#{tf['startTime']}:00.000+02:00",
              ends_at: tf['endTime'] ? "#{op['startDate']}T#{tf['endTime']}:00.000+02:00" : nil,
              frequency: tf['recurrence']
          }
        end
      end
    end
    values
  end
end