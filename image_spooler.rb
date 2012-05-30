require 'lib/classes.rb'

## I also want to be able to easily create the tables from scratch

# ActiveRecord::Schema.define do
#   create_table :cropped_images do |t|
#    t.column   :s3_file_path,   :string
#   t.column   :completed,      :boolean
#   end
# end
#
#
ActiveRecord::Base.logger = Logger.new('db.log')

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
