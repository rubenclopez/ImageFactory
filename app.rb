#!/usr/bin/env ruby
#
#
require File.join(Dir.pwd, 'lib/image_spooler.rb')

ResizedImages::Config.set do |conf|
  conf.bulk_count  = 30
  conf.host        = '173.45.225.93'
  conf.database    = 'lon'
  conf.credentials = { :username => "remote", :password => "lonch1cag0" }
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
  conf.s3_bucket_name          = "LON"
  conf.s3_bucket_size          = 10000
  conf.s3_access_key_id     = "AKIAJ3POCSWLIPFANUXQ"
  conf.s3_secret_access_key = "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"
end


offers = ResizedImagesApplication.new

offers.batch_process



