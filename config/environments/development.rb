Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Auth mailer environment-specific config
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  config.sitra_config = {
      base_url: 'http://api.sitra2-vm-preprod.accelance.net/api/v002',
      api_key: 'BPPKiFmZ',
      site_identifier: '1525'
  }
  config.oauth_config = {
      auth_site: 'http://api.sitra2-vm-preprod.accelance.net',
      token_path: '/oauth/token',
      api_url: 'http://api.sitra2-vm-preprod.accelance.net/api/v002/ecriture/',
      criteria_url: 'http://api.sitra2-vm-preprod.accelance.net/api/v002/criteres-internes/',
      grandlyon: {
          client_id: '260e54c7-8767-4b02-9ab6-994d5b5274d5',
          client_secret: 'APAOqE7W1b9sz2p'
      },
      isere: {
          client_id: 'e71e900f-ef0b-4dae-aac3-f0ff5331677a',
          client_secret: 'foZt1g8lIRr4wlY',
      }
  }

  config.omniauth_config = {
      :authorize_site => 'http://sitra2-vm-preprod.accelance.net',
      :auth_site => 'http://api.sitra2-vm-preprod.accelance.net',
      :client_id => '8d96b6c5-93ef-464e-a3be-34bb1da888c3',
      :client_secret => '7MjOmvNcwCMWDiW',
      :profile_url => '/api/v002/sso/utilisateur/profil'
  }
end
