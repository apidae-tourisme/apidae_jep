require 'sitra_client'

class EventsImporter

  def self.import_events
    events = load_apidae_events(40989)
    puts "Loaded #{events.count} events"
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