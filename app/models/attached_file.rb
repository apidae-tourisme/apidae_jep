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
                        path: 'public/pictures/:timestamp/:ref/:style/:basename.:extension',
                        url: '/pictures/:timestamp/:ref/:style/:basename.:extension'
                    }

  validates_attachment :picture, content_type: { content_type: /\Aimage\/.*\Z/ }

  store :data, accessors: [:credits], code: JSON

  validates :credits, presence: true, unless: 'picture_file_name.nil?'

  private

  Paperclip.interpolates :timestamp do |attachment, style|
    if attachment.instance.created_at
      "#{attachment.instance.created_at.year}/#{attachment.instance.created_at.month}"
    else
      "#{Time.current.year}/#{Time.current.month}"
    end
  end

  Paperclip.interpolates :ref do |attachment, style|
    if attachment.instance.program_item
      attachment.instance.program_item.reference || attachment.instance.program_item.id
    else
      'undefined'
    end
  end
end
