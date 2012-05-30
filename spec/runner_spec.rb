require 'spec_helper'
require 'active_record'
require 'logger'

ActiveRecord::Base.logger = Logger.new('db.log')

## I also want to be able to easily create the tables from scratch

# ActiveRecord::Schema.define do
#   create_table :cropped_images do |t|
#    t.column   :s3_file_path,   :string
#   t.column   :completed,      :boolean
#   end
# end

# Model setup
#class Offer < ActiveRecord::Base
#  has_many :cropped_images
#end

# Mockup of our Offer table model
class Offer
  attr_accessor :id, :url, :complete
  
  DATA = 0.upto(100).map { |x| [x, "http://www.test_url.com/file_#{x}.jpg", rand(2)] }

  def initialize(id, url, completed)
    @id, @url, @complete = id, url, completed
  end

  def self.find(id = 1)
    Offer.new(DATA[id][0], DATA[id][1], DATA[id][2])  
  end

  def completed?
    rand(2)
  end
end

#class CroppedImage < ActiveRecord::Base
#  belongs_to :offers
#end

# Mockup of our Model
class CroppedImage
  attr_accessor :id, :s3_path, :file_name, :extension

  def self.find(id = 1)
    CroppedImage.new(1, "http://w3.amazon.com/dir1/90283/", "test_image", "jpg")
  end

  def initialize(id, s3_path, file_name, extension)
    @id, @s3_path, @file_name, @extension = id, s3_path, file_name, extension
  end
end

module ImageSpooler
  def self.fetch
    0.upto(100).map { |offer| Offer.find(offer) }.select { |record| record.complete == 1 }
  end
  
  def self.establish_connection
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => "db/dev.sqlite3"
    )
  end
end

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
