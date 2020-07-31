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
    moderator.member_ref ||= compute_member_ref(auth.info.postal_code, auth.info.email)
    moderator.apidae_data = auth.info.apidae_hash
    moderator.save!
    moderator
  end

  def full_name
    "#{first_name} #{last_name.upcase if last_name}"
  end

  private

  def self.compute_member_ref(postal_code, email)
    moderators = Rails.application.config.moderators
    if postal_code
      if postal_code.start_with?('69') || moderators[GRAND_LYON].include?(email)
        GRAND_LYON
      elsif postal_code.start_with?('38') || postal_code.start_with?('73') || postal_code.start_with?('26') || moderators[ISERE].include?(email)
        ISERE
      elsif postal_code.start_with?('49') || moderators[SAUMUR].include?(email)
        SAUMUR
      else
        GRAND_LYON
      end
    else
      GRAND_LYON
    end
  end
end
