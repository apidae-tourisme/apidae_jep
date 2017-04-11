Rails.application.config.middleware.use OmniAuth::Builder do
  provider :apidae, Rails.application.config.omniauth_config[:client_id],
           Rails.application.config.omniauth_config[:client_secret]
  provider :apidae_admin, Rails.application.config.omniauth_config[:client_id],
           Rails.application.config.omniauth_config[:client_secret]

  configure do |config|
    config.path_prefix = '/oauth/auth'
  end

  on_failure do |env|
    if env['omniauth.params'].present
      env['devise.mapping'] = Devise.mappings[:user] || Devise.mappings[:moderator]
    end
    Devise::OmniauthCallbacksController.action(:failure).call(env)
  end
end