class User < ActiveRecord::Base
  has_one :relationship
  
  has_one :so, :class_name => "User", :foreign_key => "so_user_id", :through => :relationship
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :provider, :uid, :token
  # attr_accessible :title, :body
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user.blank?
      user = User.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20],
                           token: auth.credentials.token
                           )
      
      
    elsif user.email == "zombie512@events-1000.com"
      user.token = auth.credentials.token
      user.email = auth.info.email
      user.save
    elsif auth.credentials.token != user.token
      user.token = auth.credentials.token
      user.save                                 
    end
           
    user
  end
  
  def self.create_zombie_user(provider, uid, name)
    user = User.where(:provider => provider, :uid => uid).first
    if user.blank?
      user = User.create(name: name,
                          provider: provider,
                          uid: uid,
                          email: 'zombie512@events-1000.com',
                          password:Devise.friendly_token[0,20],
                          token: ""
                          )
    end
    
    user
  end
  
  def import
    so = get_relationship       
  end
  
  def is_owner?
    events = Event.where("owner = ? OR owner2 = ?", self.id, self.id)
    if !events.blank?
      return true
    end
    
    false
  end
  
  def import_photos_fb event
    @graph = Koala::Facebook::GraphAPI.new(self.token)
    return if event.owner_u1.nil? || event.owner_u2.nil?
    photos = @graph.fql_query("select object_id, caption,src_small,src_big from photo where pid in (select pid from photo_tag where subject='#{event.owner_u2.uid}') and pid in (select pid from photo_tag where subject='#{event.owner_u1.uid}')")
    photos.each do |photo|
      if Photo.find_by_pid(photo['object_id']).blank?
        p = Photo.new          
        p.url = photo['src_big']
        p.pid = photo['object_id']
        p.event_id = event.id
        p.provider = "fb"
        p.save
      end
    end    
  end
  
  private
  def get_relationship
    @graph = Koala::Facebook::GraphAPI.new(self.token)
    profile = @graph.get_object("me")
    so = nil
    event = Event.find_by_owner(self.id)
    
    if profile["significant_other"]
      rel = Relationship.where("user_id = ? OR so_user_id = ?", self.id, self.id)
      if rel.blank?
        so = User.create_zombie_user("facebook", profile["significant_other"]["id"], profile["significant_other"]["name"])
        rel = Relationship.new
        rel.user_id = self.id
        rel.so_user_id = so.id
        rel.save     
                
        event.owner2 = so.id
        event.save   
      else
        rel = rel[0]        
        so_id = rel.user_id == self.id ? rel.so_user_id : rel.user_id
        so = User.find_by_id(so_id)                    
      end                        
    end
    
    import_photos_fb event
    so                    
  end  
end
