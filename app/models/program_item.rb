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

  DIRECTION_UP = 'up'
  DIRECTION_DOWN = 'down'

  store :desc_data, accessors: [:place_desc, :event_planners, :building_ages, :building_types, :accessibility,
                                :audience, :criteria, :themes], coder: JSON
  store :location_data, accessors: [:main_place, :main_lat, :main_lng, :main_address, :main_town,
                                    :main_postal_code, :main_transports, :alt_place, :alt_lat, :alt_lng, :alt_address,
                                    :alt_town, :alt_postal_code, :alt_transports], coder: JSON
  store :rates_data, accessors: [:free, :rates_desc, :booking, :booking_details], coder: JSON
  store :opening_data, accessors: [:openings], coder: JSON
  store :contact_data, accessors: [:telephone, :email, :website], coder: JSON

  def self.change_order(item, direction)
    ordered_items = item.program.ordered_items
    item_index = ordered_items.index(item)
    if direction == DIRECTION_UP && item != ordered_items.first
      ordered_items.each do |itm|
        itm.update(ordering:  itm.ordering + 1) if (ordered_items.index(item) >= item_index - 1 && itm != item)
      end
      item.update(ordering: item.ordering - 1)
    elsif direction == DIRECTION_DOWN && item != ordered_items.last
      ordered_items.each do |itm|
        itm.update(ordering:  itm.ordering - 1) if (ordered_items.index(item) >= item_index - 1 && itm != item)
      end
      item.update(ordering: item.ordering + 1)
    end
  end

  def picture
    attached_files.first.picture.url if attached_files.any?
  end

  def pending?
    status == STATUS_PENDING
  end

  def validated?
    status == STATUS_VALIDATED
  end

  def draft?
    status == STATUS_DRAFT
  end

  def self.pending(program_id = nil)
    items = where(status: STATUS_PENDING)
    program_id ? items.where(program_id: program_id) : items
  end

  def self.validated(program_id = nil)
    items = where(status: STATUS_VALIDATED)
    program_id ? items.where(program_id: program_id) : items
  end

  def self.draft(program_id = nil)
    items = where(status: STATUS_DRAFT)
    program_id ? items.where(program_id: program_id) : items
  end

  def self.rejected(program_id = nil)
    items = where(status: STATUS_REJECTED)
    program_id ? items.where(program_id: program_id) : items
  end
end
