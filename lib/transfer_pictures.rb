require 'fileutils'

class TransferPictures

  FOLDERS = ['large', 'medium', 'original', 'small', 'thumb', 'xlarge']

  def self.transfer(file, item_reference)
    Dir.chdir('./public/pictures/2017/5')
    unless Dir.exist?(item_reference.to_s)
      Dir.mkdir(item_reference.to_s)
      FOLDERS.each do |d|
        Dir.mkdir("#{item_reference}/#{d}")
        file_name = d == 'thumb' ? file.gsub('.jpg', '.png') : file
        FileUtils.cp("#{d}/#{file_name}", "#{item_reference}/#{d}/#{file_name}")
      end
    end
  end
end