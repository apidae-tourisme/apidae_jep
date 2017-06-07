require 'fileutils'

class TransferPictures

  FOLDERS = ['large', 'medium', 'original', 'small', 'thumb', 'xlarge']

  def self.transfer(file, item_reference)
    Dir.chdir(Rails.root.join('public', 'pictures', '2017', '5'))
    unless Dir.exist?(item_reference.to_s)
      Dir.mkdir(item_reference.to_s)
      FOLDERS.each do |d|
        Dir.mkdir("#{item_reference}/#{d}")
      end
    end
    FOLDERS.each do |d|
      if d == 'thumb'
        file_name = file.split('.').first + '.png'
      elsif d != 'original'
        file_name = file.split('.').first + '.jpg'
      else
        file_name = file
      end
      FileUtils.cp("#{d}/#{file_name}", "#{item_reference}/#{d}/#{file_name}")
    end
  end
end