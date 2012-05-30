require 'spec_helper'


DATA = 1.upto(100).map { |x| [x, "http://www.test_url.com/file_#{x}.jpg", rand(2)] }



module ImageSpooler
  def self.fetch
    DATA.select { |record| record.last == 1 }
  end
end

describe ImageSpooler do
	
	describe "#fetch" do
    it "Fetches only records that are marked as not completed." do
      records = ImageSpooler.fetch
      records.select { |record| record.last == 0 }.should be_empty
    end
	end

end
