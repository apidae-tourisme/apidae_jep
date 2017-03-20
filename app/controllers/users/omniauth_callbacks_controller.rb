class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def apidae
    logger.info("omniauth.auth : #{request.env['omniauth.auth']}")
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user
      set_flash_message(:notice, :success, :kind => 'Apidae') if is_navigational_format?
    else
      session['devise.apidae_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def failure
    logger.info('User oauth login failure')
  end
end