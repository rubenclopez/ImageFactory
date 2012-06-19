#require 'spec_helper'
require 'active_record'
require 'logger'
require File.join(Dir.pwd, 'lib/image_spooler.rb')

class Image < ActiveRecord::Base
  has_one  :resized_image
  scope :unresized, includes(:resized_image).where("resized_images.id" => nil).where("resized_images.failures" => nil).where("images.id > 500000")

end

class ResizedImage < ActiveRecord::Base
  belongs_to :image
end
