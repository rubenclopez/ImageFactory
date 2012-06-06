require 'classes.rb'
require 'open-uri'
require 'fileutils'
require 'mini_magick'
require 'aws/s3'

ActiveRecord::Base.logger = Logger.new("#{Dir.pwd}/log/db.log")

module ResizedOffers
  module Config

    class << self
      attr_accessor :bulk_count, :database, :sizes, :image_path, :s3_bucket_name, :s3_access_key_id, :s3_secret_access_key
    end

    def self.set
      return unless block_given?
      yield( self ) 
      db_establish_connection
      s3_establish_connection
      
    end

    def self.db_establish_connection
      ActiveRecord::Base.establish_connection(
        :adapter  => "mysql",
        :database => @database,
        :username => "lon",
        :password => "lon_password"
      )
    end

    def self.s3_establish_connection
      AWS::S3::Base.establish_connection!(
        :access_key_id     => @s3_access_key_id,
        :secret_access_key => @s3_secret_access_key
      )
    end

    def self.setup_environment
      FileUtils.mkdir_p( @image_path )
    end
  end
end

class ResizedOffersApplication

  attr_accessor :offers

  def initialize
    ResizedOffers::Config.set do |conf|
      conf.bulk_count = 5
      conf.database   = 'lon_qa'
      conf.image_path = File.join(Dir.pwd, "images/")
      conf.sizes = { :small   => "100x200", 
        :medium  => "300x300",
        :large   => "500x500"
      }

      conf.s3_access_key_id     = 'AKIAJTGQEDLIIRNGUA4A'
      conf.s3_secret_access_key = '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'
      conf.s3_bucket_name       = 'offer_images'
    end
    ResizedOffers::Config.setup_environment
    @offers = Offer.fetch
  end

  def batch_process(file_name_prefix = nil)
    resized  = batch_resize(file_name_prefix)
    uploaded = batch_upload_to_s3(resized)
    puts uploaded.inspect
    set_flag_for_completed_records(uploaded)
  end

  def batch_resize(file_name_prefix = nil)
    records = @offers.map do |offer|
      file_name = file_name_prefix == nil ? offer.id : "#{file_name_prefix}_#{offer.id}"
      [offer.id, resize(file_name, offer.image_url)]
    end
  end

  def batch_upload_to_s3(resized_records)
    resized_records.map do |offerid, status|
      next if status == "ER"
      [offerid, upload_to_s3(offerid)]
    end
  end

  def upload_to_s3(offerid)
      begin
        ResizedOffers::Config.sizes.each do |suffix, size|
          file = File.join(Dir.pwd, "images", "#{offerid}_#{suffix.to_s}.jpg")
          code = AWS::S3::S3Object.store(file, open(file), ResizedOffers::Config.s3_bucket_name).response.code
          response = code ==  "200" ? "OK" : "ER"
          return response
        end
      rescue Exception => e
        "ER"
      end
  end

  def next
    @offers.shift
  end

  def set_flag_for_completed_records(records)
    records.each do |id, status|
      next if status == "ER"
      Offer.find(id).create_resized_offer
    end
  end

  def resize(id, url)
    begin
      ResizedOffers::Config.sizes.each do |suffix, size| 
        img = MiniMagick::Image.open(url)
        img.resize size
        img.format "jpg"
        img.write File.join(ResizedOffers::Config.image_path, "#{id}_#{suffix.to_s}.jpg")
      end
      "OK"
    rescue Exception => e
      "ER"
    end
  end

  def download(id, url)
    ext = url[/\w{3}$/]    
    begin
      open(url) do |downloaded_data|
        File.open(File.join(ResizedOffers::Config.image_path, "#{id}.#{ext}"), "wb") do |file|
          file.puts downloaded_data.read
        end
      end
      "OK"
    rescue Exception => e
      "ER"
    end
  end
end
