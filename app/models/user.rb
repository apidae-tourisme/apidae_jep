class User < ActiveRecord::Base
  belongs_to :legal_entity
  has_and_belongs_to_many :programs

  devise :database_authenticatable, :registerable, :timeoutable, :rememberable,
         :recoverable, :trackable, :validatable

  store :apidae_data, accessors: [:nomEntite], coder: JSON

  def self.from_omniauth(auth)
    user = User.where(provider: auth.provider, email: auth.info.email).first_or_create do |u|
      u.password = Devise.friendly_token[0,20]
    end
    user.first_name = auth.info.first_name
    user.last_name = auth.info.last_name
    user.uid = auth.uid
    user.apidae_data = auth.info.apidae_hash
    user.save!
    user
  end

  def entity_address
    legal_entity.address.values.join("\n")
  end
end
