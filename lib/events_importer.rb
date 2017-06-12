require 'sitra_client'

class EventsImporter

  DEFAULT_PROGRAM = "Imports Apidae"
  LEGACY_PROGRAM = "Offres saisies au cours de l'édition 2016 des JEP"

  def self.import_events(json_exports_file, user_email = nil)
    events = load_apidae_selection(40989)
    events_json = File.read(json_exports_file)
    events_data = JSON.parse(events_json, symbolize_names: true)
    if user_email
      import_user_events(user_email, events_data[user_email], events)
    else
      events_data.each_pair do |email, evts|
        import_user_events(email, evts, events)
      end
    end
  end

  def self.import_user_events(email, evts, apidae_events)
    user = User.find_by_email(email)
    if user
      if user.programs.empty? || user.programs.where(title: LEGACY_PROGRAM).count == 0
        program = Program.new(title: LEGACY_PROGRAM)
        program.users << user
        program.save
      else
        program = user.programs.where(title: LEGACY_PROGRAM).first
      end
      evts.each do |evt|
        if evt[:external_id] && apidae_events.select {|e| e.id.to_s == evt[:external_id].to_s}.first
          obj = apidae_events.select {|e| e.id.to_s == evt[:external_id].to_s}.first
          item = obj.to_program_item
          item.alt_place = evt[:place_starting_point]
          item.place_desc = evt[:place_description]
          item.event_planners = evt[:event_planners]
          item.building_ages = evt[:building_ages]
          item.building_types = evt[:building_types]
          item.program_id = program.id
          item.user_id = user.id
          item.save(validate: false)
        end
      end
    end
  end

  def self.import_apidae_event(user_email, apidae_id)
    user = User.find_by_email(user_email)
    if user
      evt = load_apidae_event(apidae_id)
      if evt
        program = Program.new(title: DEFAULT_PROGRAM)
        program.users << user
        item = evt.to_program_item
        item.attached_files = event_pictures(evt)
        item.user_id = user.id
        item.save(validate: false)
      else
        puts "Could not load Apidae event #{apidae_id}"
      end
    else
      puts "Could not find user with email #{user_email}"
    end
  end

  def self.event_pictures(evt)
    evt_pictures = []
    pictures_array = evt[:illustrations]
    unless pictures_array.blank?
      pictures_array.select { |p| p.is_a?(Hash) && !p[:traductionFichiers].blank? }.each do |pic|
        begin
          evt_pictures << AttachedFile.new(name: node_value(pic, :nom),
                                      picture: URI.parse(pic[:traductionFichiers][0][:url]),
                                      credits: node_value(pic, :copyright))
        rescue OpenURI::HTTPError => e
          puts "Could not retrieve attached picture for object #{title} - Error is #{e.message}"
        end
      end
    end
    evt_pictures
  end

  def self.load_apidae_selection(selection)
    apidae_events = Rails.cache.read("apidae_#{selection}")
    unless apidae_events
      SitraClient.configure(Rails.application.config.sitra_config)
      query = SitraClient.query({
                                    selectionIds: [selection],
                                    responseFields: ['id', 'nom', 'gestion', 'presentation', 'illustrations', 'informations', 'ouverture',
                                                     '@informationsObjetTouristique', 'descriptionTarif', 'localisation',
                                                     'prestations', 'reservation', 'criteresInternes']
                                }, true)
      apidae_events = query[:results]
      Rails.cache.write("apidae_#{selection}", apidae_events)
    end
    apidae_events
  end

  def self.load_apidae_event(id)
    SitraClient.configure(Rails.application.config.sitra_config)
    query = SitraClient.query({
                                  identifiants: [id],
                                  responseFields: ['id', 'nom', 'gestion', 'presentation', 'illustrations', 'informations', 'ouverture',
                                                   '@informationsObjetTouristique', 'descriptionTarif', 'localisation',
                                                   'prestations', 'reservation', 'criteresInternes']
                              })
    query[:results].first
  end

  def self.node_value(node, key)
    if node && node[key]
      node[key][:libelleFr]
    else
      ''
    end
  end
end