class StatsController < ApplicationController
   
  def home   
    if !current_user.nil?
      event = Event.where("owner =? OR owner2 = ?", current_user.id, current_user.id)
        
      if !event.blank?
        redirect_to event_path(event.first)
      end     
    end
  end
end
