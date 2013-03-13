require 'spec_helper'
require "#{Dir.pwd}/lib/image_spooler.rb"


describe ResizedImages::Config do

  before do
    ResizedImages::Config.set do |conf|
      conf.bulk_count   = 10
      conf.host         = 'localhost'
      conf.database     = 'lon_qa_test'
      conf.credentials  = { :username => "lon", :password => "lon_password" } 
      conf.image_path   = File.join(Dir.pwd, "images_test")
      conf.log_file     = File.join(Dir.pwd, "log/status.log")
      conf.sizes      = { 
        :small   => "100x200", 
        :medium  => "300x300",
        :large   => "500x500",
        :small_sq => "100x100^",
        :large_sq => "500x500^"
      }
      conf.convert_options = {
        :small_sq => {
          :gravity => 'center', 
          :extent  => '100x100'
        }, 
        :large_sq => {
          :gravity => 'center', 
          :extent  => '500x500'
        } 
      }
      conf.s3_bucket_name       = 'offer_images'
      conf.s3_bucket_size       = 10000
      conf.s3_access_key_id     = 'AKIAJTGQEDLIIRNGUA4AINVALID'
      conf.s3_secret_access_key = '3LiaipCYayEfcwrq+2doAm25Pd7521+IECFKvRT8INVALID'
    end
  end

  it "Allows me to pull out class instance variables" do
    ResizedImages::Config.database.should eq('lon_qa_test')
    ResizedImages::Config.bulk_count.should be_equal(10)
    ResizedImages::Config.sizes.class.should be_eql(Hash)
    ResizedImages::Config.image_path.should match("images")
    ResizedImages::Config.s3_access_key_id.should eq('AKIAJTGQEDLIIRNGUA4AINVALID')
    ResizedImages::Config.s3_secret_access_key.should eq('3LiaipCYayEfcwrq+2doAm25Pd7521+IECFKvRT8INVALID')
    # TODO: Add validation for the new variables.
  end


  describe "Establishing connection our data" do
   it "Establishes connection with the db" do
     ActiveRecord::Base.connection.should_not raise_error(ActiveRecord::ConnectionNotEstablished)
   end

   it "Establishes connection with the Amazon S3 servers" do
     AWS::S3::Base.should be_connected
   end
   
   it "Finds our bucket" do
     AWS::S3::Bucket.find("offer_images").should_not raise_error(AWS::S3::NoSuchBucket)
   end

   it "Uploads to S3 successfully" do
     upload = AWS::S3::S3Object.store(File.join(ResizedImages::Config.image_path, "test.jpg"), open(File.join(Dir.pwd, 'images_test/test.jpg')), 'offer_images')
     upload.response.code.should eql('200')
   end

   it "Maps our joined table to an object" do
      eval("ResizedImage").should be_eql(ResizedImage)
    end

    it "Maps our 'images' table to an object" do
      eval("Image").should be_eql(Image)
    end

    it "Checks association Image.resized_image" do
      Image.new.respond_to?(:resized_image).should be_true
    end
  end

  describe "Returns correct objects" do
    it "Returns an Image object" do
      Image.find(1).id.should be_eql(1)
    end
  end

	describe "#fetch" do
    it "Returns returns that have not been resized" do
      images = Image.unresized.limit(ResizedImages::Config.bulk_count)
      images.select { |image| image.resized_image != nil }.should be_empty
    end
	end
end

describe ResizedImagesApplication do

  before do
    @images = ResizedImagesApplication.new
    dummy_images = [[1, 1], [2, 2], [3, 3]]
    @images.stub(:images) { dummy_images.map { |id, image_id| Image.new(:id => image_id) } }
  end


  it "Initializes a new instance properly" do
    @images.should be_true
  end

  it "Make sure that we have fetched records." do
    @images.images.should be_present   
  end

  it "Returns the next record needed to be processed" do
    current_record = @images.next
    current_record.class.should be_eql(Image)
  end

  it "Resizes an image" do
    current_record = Image.find(Image.unresized.first.id)
    @images.resize("dummy_resized_test", current_record.url)
  end

  it "Gracefully exits from the resizing method if image cannot be resized." do
    @images.resize("image_will_not_be_found", "http://www.blahdotdot.com/notfound.jpg")
  end

  it "Batch resizes images in the images variable." do
    #@images.batch_resize("resized_test")
    @images.batch_process
  end

  it "Downloads an image" do
    current_record = @images.next
    @images.download("dummy_download_test", current_record.url)
  end

  it "Gracefully exits when the image cannot be downloaded." do
    @images.download(99999999999, "http://www.notfound.com/image.jpg")
  end

  it "Downloads the current batch" do
    #@images.process
  end


end

describe Image do

  it "Returns only the records that do not have a joined resized_image entry." do
      images = Image.unresized.limit(50)
      images.inspect
  end

  it "Returns the URl of those records that are not done." do
    Image.find(Image.unresized.first.id).url
  end


end
