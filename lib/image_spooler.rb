require File.join(Dir.pwd, 'lib/classes.rb')
require 'open-uri'
require 'fileutils'
require 'mini_magick'
require 'aws/s3'
require File.join(Dir.pwd, 'lib/config.rb')
#require File.join(Dir.pwd, 'app.rb')

ActiveRecord::Base.logger = Logger.new(ResizedImages::Config.log_file)

class ResizedImagesApplication

  attr_accessor :images

  def initialize
    ResizedImages::Config.setup_environment
    @images = Image.unresized.limit(ResizedImages::Config.bulk_count)
  end

  def batch_process(file_name_prefix = nil)
    resized  = batch_resize(file_name_prefix)
    uploaded = batch_upload_to_s3(resized)
    completed = set_flag_for_completed_records(uploaded)
    ResizedImages::Config.cleanup(completed)
  end

  def batch_resize(file_name_prefix = nil)
    records = @images.map do |image|
      file_name = file_name_prefix == nil ? image.id : "#{file_name_prefix}_#{image.id}"
      [image.id, resize(file_name, image.url)]
    end
  end

  def resize(id, url)
    begin
      ResizedImages::Config.sizes.each do |suffix, size| 
        img = MiniMagick::Image.open(url)
        img.resize size
        img.format "jpg"
        if options = ResizedImages::Config.convert_options[suffix] 
          img.combine_options do |c_opts|
            options.each { |k,v| c_opts.send(k,v) }
          end
        end
        img.write File.join(ResizedImages::Config.image_path, "#{id}_#{suffix.to_s}.jpg")
      end
      "OK"
    rescue Exception => e
      "ER"
    end
  end
  def batch_upload_to_s3(resized_records)
    resized_records.map do |imageid, status|
      if status == "ER"
        [imageid, "ER"]
      else
        [imageid, upload_to_s3(imageid)]
      end
    end
  end

  def upload_to_s3(imageid)
      response = "OK"
      begin
        ResizedImages::Config.sizes.each do |suffix, size|
          file    = File.join(Dir.pwd, "images", "#{imageid}_#{suffix.to_s}.jpg")
          s3_path = ResizedImages::Config.generate_s3_path(imageid) 
          code = AWS::S3::S3Object.store("#{s3_path}/#{suffix.to_s}.jpg", open(file), ResizedImages::Config.s3_bucket_name, :access => :public_read).response.code
          response = 'ER' if code != '200'
        end
      rescue Exception => e
        response = 'ER'
      end
      response
  end

  def next
    @images.shift
  end

  def set_flag_for_completed_records(records)
    records.map do |id, status|
      begin
        image = Image.find(id)
      rescue
        image = Image.new
      end

      if status == "ER"
        image.create_resized_image(:failures => 1)
        [id, "ER"]
      else
        image.create_resized_image
        [id, status]
      end
    end
  end

  def download(id, url)
    ext = url[/\w{3}$/]    
    begin
      open(url) do |downloaded_data|
        File.open(File.join(ResizedImages::Config.image_path, "#{id}.#{ext}"), "wb") do |file|
          file.puts downloaded_data.read
        end
      end
      "OK"
    rescue Exception => e
      "ER"
    end
  end
end
