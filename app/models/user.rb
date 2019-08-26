  require 'csv'

class User < ActiveRecord::Base
  belongs_to :legal_entity, optional: true
  accepts_nested_attributes_for :legal_entity
  has_many :program_items
  has_one :communication_poll
  has_many :event_polls

  accepts_nested_attributes_for :communication_poll

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

  def self.with_items(user_territory)
    joins(:program_items).where(users: {territory: user_territory},
                                program_items: {
                                    status: [ProgramItem::STATUS_VALIDATED],
                                    created_at: (Date.new(EDITION, 1, 1)..Date.new(EDITION + 1, 1, 1))
                                }).distinct
  end

  def active_poll
    EventPoll.where("user_id = ? AND created_at >= ?", id, Date.new(EDITION, 1, 1)).first
  end

  def last_poll
    EventPoll.where(user_id: id).order(id: :desc).first
  end

  def entity_address
    legal_entity.address.values.join("\n")
  end

  def entity_name
    legal_entity.name
  end

  def entity_town
    legal_entity.town.label if legal_entity.town
  end

  def active_items(year)
    creation_year = year.blank? ? EDITION : year.to_i
    active_ids = program_items.select("MAX(id) AS id").group(:reference)
    program_items.where(id: active_ids)
        .where(created_at: (Date.new(creation_year, 1, 1)..Date.new(creation_year + 1, 1, 1))).order(:id)
  end

  def full_name
    "#{first_name} #{last_name.upcase if last_name}"
  end

  def offers_count
    program_items.count
  end

  def compute_territory
    if legal_entity_id && legal_entity.town_insee_code
      if legal_entity.town_insee_code.start_with?('69')
        GRAND_LYON
      elsif legal_entity.town_insee_code.start_with?('38') || legal_entity.town_insee_code.start_with?('73') ||
          legal_entity.town_insee_code.start_with?('26')
        ISERE
      else
        logger.info("Unsupported INSEE code : #{legal_entity.town_insee_code} - Cannot find corresponding JEP territory")
        GRAND_LYON
      end
    end
  end

  def entity_apidae_id
    legal_entity.external_id if legal_entity
  end

  def offers(year)
    legal_entity.active_items(year).group_by {|pi| pi.status}
  end

  def account_offers
    ProgramItem.active_versions.where(user_id: id, status: ProgramItem::STATUS_VALIDATED,
                                      created_at: (Date.new(EDITION, 1, 1)..Date.new(EDITION + 1, 1, 1)))
  end

  def self.matching(pattern)
    where("trim(unaccent(replace(first_name, '-', ' '))) ILIKE trim(unaccent(replace(?, '-', ' '))) " +
              " OR trim(unaccent(replace(last_name, '-', ' '))) ILIKE trim(unaccent(replace(?, '-', ' '))) " +
              " OR trim(unaccent(replace(email, '-', ' '))) ILIKE trim(unaccent(replace(?, '-', ' ')))",
          "%#{pattern}%", "%#{pattern}%", "%#{pattern}%").includes(:legal_entity)
  end

  def self.import_full(csv_file)
    csv = CSV.new(File.new(csv_file), col_sep: ',', headers: :first_row)
    csv.each do |row|
      user_fields = row.to_hash
      if user_fields.length == row.headers.length
        existing_user = User.find_by_email(user_fields['email'])
        if existing_user
          logger.info "Skipping existing user : #{existing_user.email}"
        else
          user = User.new(email: user_fields['email'], encrypted_password: user_fields['encrypted_password'],
                          first_name: user_fields['first_name'], last_name: user_fields['last_name'],
                          provider: user_fields['provider'], role: user_fields['role'],
                          telephone: user_fields['telephone'])
          unless user_fields['entity_id'].blank?
            entity = LegalEntity.find_by_external_id(user_fields['entity_id'])
            if entity
              user.legal_entity_id = entity.id
            else
              logger.info "Could not find legal entity with id #{user_fields['entity_id']}"
            end
          end
          user.save(validate: false)
        end
      else
        raise Exception.new('Invalid csv row : ' + user_fields)
      end
    end
  end

  def self.reassign_entities(csv_file)
    csv = CSV.new(File.new(csv_file), col_sep: ',', headers: :first_row)
    csv.each do |row|
      dup_fields = row.to_hash
      if dup_fields.length == row.headers.length
        if dup_fields['duplicate'] && dup_fields['duplicate'].strip == 'OUI'
          dup_id = dup_fields['duplicate_id'].gsub(' ', '')
          orig_id = dup_fields['original_id'].gsub(' ', '')
          dup_entity = LegalEntity.find_by_external_id(dup_id)
          if dup_entity && dup_entity.users.any?
            orig_entity = LegalEntity.find_by_external_id(orig_id)
            if orig_entity
              logger.info "Transfering #{dup_entity.users.count} user(s) from entity '#{dup_entity.name}' to entity '#{orig_entity.name}'"
              dup_entity.users.update_all(legal_entity_id: orig_entity.id)
            end
          else
            logger.info "Skipping duplicate entity with id : #{dup_id}"
          end
        end
      else
        raise Exception.new('Invalid csv row : ' + dup_fields)
      end
    end
  end
end
