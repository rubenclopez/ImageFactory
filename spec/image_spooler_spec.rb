require 'spec_helper'
require 'image_spooler.rb'

describe ImageSpooler do
	
  describe "Establishing connection our data" do
#   it "Establishes connection with the db" do
#     ImageSpooler.establish_connection
#     ActiveRecord::Base.connection.should_not raise_error(ActiveRecord::ConnectionNotEstablished)
#   end

   it "Maps our joined table to an object" do
      eval("CroppedImage").should be_eql(CroppedImage)
    end

    it "Maps our 'offers' table to an object" do
      eval("Offer").should be_eql(Offer)
    end
  end

  describe "Returns correct objects" do
    it "Returns an Offer object" do
      Offer.find(1).id.should be_eql(1)
    end

    it "Returns a CroppedImage object" do
      CroppedImage.find(1).id.should be_eql(1)
    end
  end

	describe "#fetch" do
    it "Fetches only records that are marked as not completed." do
      records = ImageSpooler.fetch
      records.select { |record| record.complete == 0 }.should be_empty
    end
	end
end
