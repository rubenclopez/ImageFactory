module ResizedImages
  module Config

    class << self
      attr_accessor :bulk_count,      :database,         :sizes,                :image_path,   :s3_bucket_name
      attr_accessor :convert_options, :s3_access_key_id, :s3_secret_access_key, :log_file,     :s3_bucket_size
      attr_accessor :host,            :credentials
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
        :host     => @host,
        :database => @database,
        :username => @credentials[:username],
        :password => @credentials[:password]
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

    def self.generate_s3_path(imageid)
      File.join("offers", "images", "#{imageid / ResizedImages::Config.s3_bucket_size}", imageid.to_s)
    end

    def self.cleanup(records)
      records.each do |imageid, status|
        Dir.glob(File.join(ResizedImages::Config.image_path, "#{imageid}*.jpg")).each do |file|
          File.delete(file)
        end
      end
    end

  end
end
