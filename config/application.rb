require 'uri'
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApidaeJep
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :fr

    # Do not include all helpers in all controllers
    config.action_controller.include_all_helpers = false

    # Cache store
    config.cache_store = :file_store, 'cache', {expires_in: 48.hours}

    # Mailer config
    config.action_mailer.smtp_settings = {
        address: '',
        port: 587,
        domain: '',
        user_name: '',
        password: '',
        authentication: 'plain',
        enable_starttls_auto: true
    }
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true

    # Notification email config
    config.notification_title = "ApidaeJEP 2022 - Nouvelle saisie"
    config.rejection_title = "ApidaeJEP 2022 - Offre rejetée"
    config.publication_title = "ApidaeJEP 2022 - Offre validée"
    config.notify_poll_title = "Questionnaire bilan JEP 2022 – Métropole de Lyon"
    config.notify_com_title = "Supports de communication JEP 2022"
    config.notify_com_summary_title = "Votre commande de supports de communication JEP 2022"

    config.signature = {
        'grand_lyon' => {label: "L’équipe JEP pour la Métropole de Lyon", contact: "jep.metropole@grandlyon.com"},
        'isere' => {label: "La Direction de la culture et du patrimoine, service du patrimoine culturel", contact: "dcp.pac@isere.fr"},
        'saumur' => {label: "L’équipe JEP pour la Communauté d'agglomération Saumur Val de Loire", contact: "jep@ot-saumur.fr"},
        'dlva' => {label: "L’équipe JEP pour l'Agglomération Durance Luberon Verdon", contact: "v.marcuello@tourisme-dlva.fr"}
    }
    
    # setup bower components folder for lookup
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
    # fonts
    config.assets.precompile << /\.(?:svg|eot|woff|woff2|ttf)$/
    # images
    config.assets.precompile << /\.(?:png|jpg)$/
    # precompile vendor assets
    config.assets.precompile += %w( base.js )
    config.assets.precompile += %w( base.css )
  end
end


