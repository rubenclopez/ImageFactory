require 'spec_helper'
require 'active_record'
require 'logger'
require 'image_spooler.rb'

class Offer < ActiveRecord::Base
  has_one :resized_offer

  def self.fetch
    find(:all, :limit => ResizedOffers::Config::bulk_count).select { |o| o.resized_offer == nil }
  end
end

class ResizedOffer < ActiveRecord::Base
  belongs_to :offer
end
