require 'spec_helper'
require 'active_record'
require 'logger'
require 'image_spooler.rb'

class Offer < ActiveRecord::Base
  has_one :resized_offer

  def self.fetch
    Offer.find_by_sql("
                SELECT offers.id, offers.image_url FROM offers
                LEFT OUTER JOIN resized_offers ON offers.id = resized_offers.offer_id 
                WHERE resized_offers.id IS NULL
                LIMIT #{ResizedOffers::Config.bulk_count}")
  end
end

class ResizedOffer < ActiveRecord::Base
  belongs_to :offer
end
