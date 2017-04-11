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
    config.cache_store = :file_store, 'cache', {expires_in: 10.minutes}

    # Mailer config
    config.action_mailer.smtp_settings = {
        address: 'smtp-jep.alwaysdata.net',
        port: 587,
        domain: 'jep.alwaysdata.net',
        user_name: 'jep@alwaysdata.net',
        password: 'jep_smtp',
        authentication: 'plain',
        enable_starttls_auto: true
    }
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    
    # setup bower components folder for lookup
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
    # fonts
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    # images
    config.assets.precompile << /\.(?:png|jpg)$/
    # precompile vendor assets
    config.assets.precompile += %w( base.js )
    config.assets.precompile += %w( base.css )
    # precompile themes
    config.assets.precompile += ['angle/themes/theme-a.css',
                                 'angle/themes/theme-b.css',
                                 'angle/themes/theme-c.css',
                                 'angle/themes/theme-d.css',
                                 'angle/themes/theme-e.css',
                                 'angle/themes/theme-f.css',
                                 'angle/themes/theme-g.css',
                                 'angle/themes/theme-h.css'
                                ]
    # Controller assets
    config.assets.precompile += [
                                 # Scripts
                                 'charts.js',
                                 'dashboard.js',
                                 'documentation.js',
                                 'elements.js',
                                 'extras.js',
                                 'forms.js',
                                 'maps.js',
                                 'multilevel.js',
                                 'pages.js',
                                 'tables.js',
                                 'widgets.js',
                                 'blog.js',
                                 'ecommerce.js',
                                 'forum.js',
                                 # Stylesheets
                                 'charts.css',
                                 'dashboard.css',
                                 'documentation.css',
                                 'elements.css',
                                 'extras.css',
                                 'forms.css',
                                 'maps.css',
                                 'multilevel.css',
                                 'pages.css',
                                 'tables.css',
                                 'widgets.css',
                                 'blog.css',
                                 'ecommerce.css',
                                 'forum.css'
                                ]


  end
end


