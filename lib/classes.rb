require 'spec_helper'
require 'active_record'
require 'logger'
require 'image_spooler.rb'

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

class CroppedImage
  attr_accessor :id, :s3_path, :file_name, :extension

  def self.find(id = 1)
    CroppedImage.new(1, "http://w3.amazon.com/dir1/90283/", "test_image", "jpg")
  end

  def initialize(id, s3_path, file_name, extension)
    @id, @s3_path, @file_name, @extension = id, s3_path, file_name, extension
  end
end

