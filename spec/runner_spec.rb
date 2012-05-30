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
  attr_accessor :id, :url

  def completed?
    rand(2)
  end

end

#class CroppedImage < ActiveRecord::Base
#  belongs_to :offers
#end

# Mockup of our Model
class CroppedImage
  attr_accessor :s3_location, :small, :medium, :large
end
  
#class CroppedImage < ActiveRecord::Base
#  belongs_to :offers
#end

# Mockup of our Model
class CroppedImage
  attr_accessor :id, :url

  def completed?
    rand(2)
  end
  
# belongs_to :offers
end


DATA = 1.upto(100).map { |x| [x, "http://www.test_url.com/file_#{x}.jpg", rand(2)] }



module ImageSpooler
  def self.fetch
    DATA.select { |record| record.last == 1 }
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


	describe "#fetch" do
    it "Fetches only records that are marked as not completed." do
      records = ImageSpooler.fetch
      records.select { |record| record.last == 0 }.should be_empty
    end
	end

end
