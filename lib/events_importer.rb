require 'sitra_client'

class EventsImporter

  LEGACY_PROGRAM = "Offres saisies au cours de l'édition 2016 des JEP"

  def self.import_events(json_exports_file, user_email = nil)
    events = load_apidae_events(40989)
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

  def self.load_apidae_events(selection)
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

end