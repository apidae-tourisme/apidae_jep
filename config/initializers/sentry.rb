if Rails.env.production?
  Raven.configure do |config|
    config.dsn = 'https://04f35554afa34d3f9649cb693037575a:bc3dd0a2dd564dfb83972257ccdbbd91@sentry.io/160286'
    config.environments = ['production']
  end
end