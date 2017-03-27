class AttachedFile < ActiveRecord::Base
  belongs_to :program_item

  has_attached_file :picture,
                    {
                        :styles => {
                            :xlarge => ['1600x1200>', :jpg],
                            :large => ['1280x960>', :jpg],
                            :medium => ['800x600>', :jpg],
                            :small => ['320x240', :jpg],
                            :thumb => ['200x200>', :png]
                        },
                        path: 'public/pictures/:timestamp/:id/:style/:basename.:extension',
                        url: '/pictures/:timestamp/:id/:style/:basename.:extension'
                    }

  validates_attachment :picture, content_type: { content_type: /\Aimage\/.*\Z/ }

  store :data, accessors: [:credits], code: JSON

  validates :credits, presence: true, unless: 'picture_file_name.nil?'

  private

  Paperclip.interpolates :timestamp do |attachment, style|
    "#{attachment.instance.created_at.year}/#{attachment.instance.created_at.month}"
  end
end
