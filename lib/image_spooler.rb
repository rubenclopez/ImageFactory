require 'classes.rb'
require 'open-uri'

ActiveRecord::Base.logger = Logger.new("#{Dir.pwd}/log/db.log")



module ResizedOffers
  module Config

    class << self
      attr_accessor :bulk_count, :database, :sizes, :image_path
    end

    def self.set
      return unless block_given?
      yield( self ) 
      establish_connection
    end

    def self.establish_connection
      ActiveRecord::Base.establish_connection(
        :adapter  => "mysql",
        :database => @database,
        :username => "lon",
        :password => "lon_password"
      )
    end
  end
end


class ResizedOffersApplication

  attr_accessor :offers


  def initialize
    ResizedOffers::Config.set do |conf|
      conf.bulk_count = 100
      conf.database   = 'lon_qa'
      conf.image_path = "#{Dir.pwd}/images/"
      conf.sizes = { :small   => "100x200", 
        :medium  => "300x300",
        :large   => "500x500"
      }
    end
    @offers = Offer.fetch
  end

  def next
    @offers.shift
  end

  def process
    @offers.map do |offer|
     [offer.id, download(offer.id, offer.image_url)]
    end
  end

  def download(id, url)
    ext = url[/\w{3}$/]    
    begin
      open(url) do |downloaded_data|
        File.open("#{id}.#{ext}", "wb") do |file|
          file.puts downloaded_data.read
        end
      end
      "OK"
    rescue Exception => e
      "ER"
    end
  end
end


