require 'spec_helper'
require "#{Dir.pwd}/lib/image_spooler.rb"


describe ResizedOffers::Config do

  describe "Setting up configurations" do
    

    it "Allows me to configure the spooler" do
      ResizedOffers::Config.set do |conf|
        conf.bulk_count = 10
        conf.database   = 'lon_qa_test'
        conf.sizes = { :small   => "100x200", 
                       :medium  => "300x300",
                       :large   => "500x500"
                     }
        conf.image_path = File.join(Dir.pwd, "images")
      end.should be_true
    end

    it "Allows me to pull out class instance variables" do
      ResizedOffers::Config.database.should eq('lon_qa_test')
      ResizedOffers::Config.bulk_count.should be_equal(10)
      ResizedOffers::Config.sizes.class.should be_eql(Hash)
      ResizedOffers::Config.image_path.should match("images")
    end

    it "Creates needed folders" do
      path = ResizedOffers::Config.image_path
      exists = lambda { File.exists?(path) }

      expect{ResizedOffers::Config.setup_environment}.to change{exists.call}.from(false).to(true)
      Dir.rmdir(path)
    end

  end

  describe "Establishing connection our data" do
   it "Establishes connection with the db" do
     ActiveRecord::Base.connection.should_not raise_error(ActiveRecord::ConnectionNotEstablished)
   end

   it "Maps our joined table to an object" do
      eval("ResizedOffer").should be_eql(ResizedOffer)
    end

    it "Maps our 'offers' table to an object" do
      eval("Offer").should be_eql(Offer)
    end

    it "Checks association Offer.resized_offer" do
      Offer.new.respond_to?(:resized_offer).should be_true
    end
  end

  describe "Returns correct objects" do
    it "Returns an Offer object" do
      Offer.find(1).id.should be_eql(1)
    end
  end

	describe "#fetch" do
    it "Fetches only records that do not have a ResizedOffer record" do
      offers = Offer.fetch
      offers.select { |offer| offer.resized_offer != nil }.should be_empty
    end
	end
#
#  describe "#pop" do
#    before do
#      @records = OfferImages.init
#    end
#
#    it "Returns the next record needed to be processed" do
#      current_record = @records.next
#      current_record.class.should be_eql(Offer)
#    end
#
#    it "Returns the connect data for an offer record" do
#      current_record = @records.next
#      current_record.url.should include(".jpg")
#    end
#
#    it "Changes our fetched data by shifting our data in the array" do
#      expect { @records.next }.to change{ @records.offers.count }.by(-1)
#    end
#
#    #it "Sets the recddddord on the db to complete"
#  end

end

describe ResizedOffersApplication do

  before do
    @offers = ResizedOffersApplication.new
  end

  it "Initializes a new instance properly" do
    @offers.should be_true
  end

  it "Make sure that we have fetched records." do
    @offers.offers.should be_present   
  end

  it "Returns the next record needed to be processed" do
    current_record = @offers.next
    current_record.class.should be_eql(Offer)
  end

  it "Returns the connect data for an offer record" do
    current_record = @offers.next
    current_record.image_url.should include(".jpg")
  end

  it "Changes our fetched data by shifting our data in the array" do
    expect { @offers.next }.to change{ @offers.offers.count }.by(-1)
  end

  it "Downloads an image" do
    current_record = @offers.next
    @offers.download(current_record.id, current_record.image_url)
  end

  it "Gracefully exits when the image cannot be downloaded." do
    @offers.download(99999999999, "http://www.notfound.com/image.jpg")
  end

  it "Downloads the current batch" do
    #@offers.process
  end

end

describe Offer do

  it "Returns only the records that do not have a joined resized_offer entry." do
    offers = Offer.fetch
    offers.inspect
  end

end
