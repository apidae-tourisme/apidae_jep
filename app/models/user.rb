class User < ActiveRecord::Base
  belongs_to :legal_entity
  accepts_nested_attributes_for :legal_entity
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

  def ordered_programs
    programs.order(:id)
  end

  def territory
    if legal_entity_id && legal_entity.town_insee_code
      if legal_entity.town_insee_code.start_with?('69')
        GRAND_LYON
      elsif legal_entity.town_insee_code.start_with?('38') || legal_entity.town_insee_code.start_with?('73') ||
          legal_entity.town_insee_code.start_with?('26')
        ISERE
      else
        raise Exception.new("Unsupported INSEE code : #{legal_entity.town_insee_code} - Cannot find corresponding JEP territory")
      end
    end
  end
end
