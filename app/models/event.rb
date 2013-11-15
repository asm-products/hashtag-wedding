class Event < ActiveRecord::Base
  # attr_accessible :title, :body
  
  belongs_to :owner_u1, class_name: "User", foreign_key: "owner"
  belongs_to :owner_u2, class_name: "User", foreign_key: "owner2"
  has_many :photos
end
