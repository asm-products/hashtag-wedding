class PhotosController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    event_id = params[:id]
    photos = JSON.parse(params[:photos])
    prov = params[:provider]
    
    event = Event.where("id = ? and (owner = ? OR owner2 = ?)", event_id, current_user.id, current_user.id)
    
    if !event.blank?
      photos.each_with_index do |photo, index|
        if Photo.find_by_pid(photo['object_id']).blank?
          p = Photo.new          
          p.url = photo['src_big']
          p.pid = photo['object_id']
          p.event_id = event_id
          p.provider = prov
          p.save
        end
      end
      
      render nothing: true      
    end
  end
  
end
