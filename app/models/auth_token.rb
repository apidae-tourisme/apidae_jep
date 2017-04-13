class AuthToken < ActiveRecord::Base
  validates_presence_of :expiration_date, :token

  def self.active_token(member)
    AuthToken.where('expiration_date > ? AND member_ref = ?', Time.now, member).first
  end

  def expires_in=(expires_in)
    self.expiration_date = expires_in.seconds.from_now
  end
end
