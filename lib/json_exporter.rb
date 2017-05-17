class JsonExporter
  def self.export_items(json_file)
    published_items = ProgramItem.select(:id).where(status: ProgramItem::STATUS_VALIDATED)
    puts "Exporting #{published_items.count} items to JSON"
    File.open(Rails.root.join(json_file), 'w+') do |f|
      f.write('{"events":[')
      published_items.each_with_index do |pi, i|
        item = ProgramItem.find(pi.id)
        if item
          town = Town.find_by_insee_code(item.main_town_insee_code) || Town.last
          if town
            f.write(',') unless i == 0
            f.write(as_json(item, town))
          end
        end
      end
      f.write(']}')
    end
  end

  def self.as_json(item, town)
    item_data = {
        location: {placename: item.main_place,
                   address: [item.main_address, town.postal_code, town.name].collect {|a| a.strip}.join(' '),
                   latitude: item.main_lat.to_f, longitude: item.main_lng.to_f},
        event: {title: item.title[0..139], description: item.description[0..199], freeText: item.details,
                tags: (item.criteria + item.themes).select {|t| !t.blank?}.join(','),
                locations: {uid: '', pricingInfo: (item.free ? 'Gratuit' : item.rates_desc),
                            dates: item.item_openings.collect {|o| opening_hash(o)}
                }
        },
        image: item.picture
    }
    JSON.generate(item_data)
  end

  def self.opening_hash(opening)
    {
        date: I18n.l(opening.starts_at, format: :js),
        timeStart: I18n.l(opening.starts_at, format: :timeonly),
        timeEnd: I18n.l(opening.starts_at, format: :timeonly)
    }
  end
end