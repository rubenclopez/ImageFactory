#!/usr/bin/env ruby
#
#
require File.join(Dir.pwd, 'lib/image_spooler.rb')

ResizedImages::Config.set do |conf|
  conf.bulk_count  = 30
  conf.host        = '127.0.0.1'
  conf.database    = 'foo'
  conf.credentials = { :username => "foo", :password => "bar" }
  conf.image_path  = File.join(Dir.pwd, "images/")
  conf.log_file    = File.join(Dir.pwd, "log/status.log")
  conf.sizes = { 
    :small    => "100x66>", 
    :medium   => "150x100>",
    :large    => "300x200>",
    :small_sq => "66x66^"
  }
  conf.convert_options = {
    :small_sq => {
      :gravity => 'center', 
      :extent  => '66x66'
    }
  }
  conf.s3_bucket_name          = "baz"
  conf.s3_bucket_size          = 10000
  conf.s3_access_key_id     = "INVALIDID"
  conf.s3_secret_access_key = "INVALIDKEY"
end


offers = ResizedImagesApplication.new

offers.batch_process



