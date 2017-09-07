class AttachedFile < ActiveRecord::Base
  belongs_to :program_item, touch: true

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

  before_post_process :transliterate_file_name
  validates :credits, presence: true, unless: 'picture_file_name.nil?'

  def transliterate_file_name
    extension = File.extname(picture_file_name).gsub(/^\.+/, '')
    filename = picture_file_name.gsub(/\.#{extension}$/, '')
    self.picture.instance_write(:file_name, "#{transliterate(filename)}.#{transliterate(extension)}")
  end

  def transliterate(str)
    str.parameterize
  end

  def picture_url
    picture.url
  end

  def info
    "#{picture_url} - Crédits : #{credits} - Taille : #{picture_file_size / 1024} Ko"
  end

  private

  # Sidenote : better not mix ref & timestamps in paths generation, makes it hard to maintain files path between parent instance versions
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
