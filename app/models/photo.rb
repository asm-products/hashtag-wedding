class Photo < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :event
  attr_accessor :holders
  
  @holders = [
            {:name => "23349644_1aab77a154_o.jpg", :attr =>"http://www.flickr.com/photos/roblee"},
            {:name => "8025132149_fcffb9ee5d_b.jpg", :attr =>"http://www.flickr.com/photos/mackenziebrunson"},
            {:name => "4679496126_d9635e740b_b.jpg", :attr =>"http://www.flickr.com/photos/artbystevejohnson"},
            {:name => "109027157_0af0fe7cd4_b.jpg", :attr =>"http://www.flickr.com/photos/clearlyambiguous"},
            {:name => "2907378546_39c16e70f7_b.jpg", :attr =>"http://www.flickr.com/photos/barry1"},
            {:name => "4913283926_0207eb7da0_b.jpg", :attr =>"http://www.flickr.com/photos/thedimka"},
            {:name => "1101543277_4124d4b8d5_o.jpg", :attr =>"http://www.flickr.com/photos/28481088@N00"},
            {:name => "5579600298_6cbb9e4460_b.jpg", :attr =>"http://www.flickr.com/photos/thedimka"},
            {:name => "6242570854_f4b75d5663_b.jpg", :attr =>"http://www.flickr.com/photos/thedimka"},
            {:name => "5377230062_c1338264de_b.jpg", :attr =>"http://www.flickr.com/photos/thedimka"}
           ] 
  
  def self.get_image    
    @holders[rand(0..9)]
  end 
end
