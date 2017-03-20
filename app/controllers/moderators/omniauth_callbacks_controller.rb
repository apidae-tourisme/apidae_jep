class Moderators::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def apidae
    logger.info("omniauth.auth : #{request.env['omniauth.auth']}")
    @moderator = Moderator.from_omniauth(request.env['omniauth.auth'])

    if @moderator.persisted?
      sign_in_and_redirect @moderator
      set_flash_message(:notice, :success, :kind => 'Apidae') if is_navigational_format?
    else
      session['devise.apidae_data'] = request.env['omniauth.auth']
      redirect_to new_moderator_registration_url
    end
  end

  def failure
    logger.info('Moderator oauth login failure')
  end
end