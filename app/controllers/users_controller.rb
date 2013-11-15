class UsersController < ApplicationController
  before_filter :authenticate_user!
  

  def import
    rel = Relationship.where("user_id = ? OR so_user_id = ?", self.id, self.id)
    photos = ""
    if !rel.blank?
      rel = rel.first
      photos = @graph.fql_query("select object_id, caption,src_small,src_big from photo where pid in (select pid from photo_tag where subject='#{rel.so_user_id}') and pid in (select pid from photo_tag where subject='#{rel.user_id}')")                                   
    end
    
    respond_to do |format|
      format.js { render :json =>  photos.to_json }
    end    
  end
  
  def save_photos
    
  end
end
