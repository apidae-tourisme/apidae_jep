class Moderator < ActiveRecord::Base
  devise :database_authenticatable, :trackable, :timeoutable

  def self.from_omniauth(auth)
    moderator = Moderator.where(provider: auth.provider, email: auth.info.email).first_or_create do |m|
      m.password = Devise.friendly_token[0,20]
    end
    moderator.first_name = auth.info.first_name
    moderator.last_name = auth.info.last_name
    moderator.uid = auth.uid
    moderator.notification_email = auth.info.email
    moderator.member_ref = compute_member_ref(auth.info.postal_code)
    moderator.apidae_data = auth.info.apidae_hash
    moderator.save!
    moderator
  end

  private

  def self.compute_member_ref(postal_code)
    ref = 'grandlyon'
    if postal_code
      if postal_code.start_with?('69')
        ref = 'grandlyon'
      elsif postal_code.start_with?('38')
        ref = 'isere'
      end
    end
    ref
  end
end
