class ProgramItem < ActiveRecord::Base
  belongs_to :program
  has_many :item_openings
  has_many :attached_files

  accepts_nested_attributes_for :item_openings, allow_destroy: true
  accepts_nested_attributes_for :attached_files, allow_destroy: true, reject_if: proc {|attrs| attrs['picture'].blank?}

  STATUS_DRAFT = 'draft'
  STATUS_PENDING = 'pending'
  STATUS_VALIDATED = 'validated'
  STATUS_REJECTED = 'rejected'

  store :desc_data, accessors: [:place_desc, :event_planners, :building_ages, :building_types, :accessibility,
                                :audience, :criteria, :themes], code: JSON
  store :location_data, accessors: [:main_place, :main_lat, :main_lng, :main_address, :main_town,
                                    :main_postal_code, :main_transports, :alt_place, :alt_lat, :alt_lng, :alt_address,
                                    :alt_town, :alt_postal_code, :alt_transports], code: JSON
  store :rates_data, accessors: [:free, :rates_desc, :booking, :booking_details]
  store :opening_data, accessors: [:openings]
  store :contact_data, accessors: [:telephone, :email, :website]

  def pending?
    status == STATUS_PENDING
  end

  def validated?
    status == STATUS_VALIDATED
  end

  def draft?
    status == STATUS_DRAFT
  end
end
