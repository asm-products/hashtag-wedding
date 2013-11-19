class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :show, :search, :get_tag]
  
  def search
   @events = Event.search(params[:term])
   
   respond_to do |format|
     format.js { render :json => @events.to_json}
   end 
  end
  
  def get_tag
    @event = Event.search(params[:hashtag]).first
    if !@event.nil?
      redirect_to event_path(@event)
    else 
      render 'new'      
    end
  end
   
  def create
    @event = Event.where("owner =? OR owner2 = ?", current_user.id, current_user.id)
    if @event.blank?
      @event = Event.new
      @event.owner = current_user.id
      @event.tag = params[:event][:tag].delete "#"
      if @event.save
        current_user.import
        redirect_to event_path(@event)
      else        
        render 'error'        
      end
    else
      redirect_to event_path(@event.first)          
    end        
  end
  
  def new
    @event = Event.new
    if !current_user.nil?
      event = Event.where("owner =? OR owner2 = ?", current_user.id, current_user.id)
      if !event.blank?
        redirect_to event_path(event.first)
      end     
    end
  end
  
  def show
    if !@event.nil? || !params[:id].nil?
      @event ||= Event.find_by_id(params[:id])
    end    
                          
    @page = params[:page] || 0
    if @page == 0
      params[:in_max_id] = nil
      params[:in_min_id] = nil
      params[:tw_max_id] = nil
      params[:tw_min_id] = nil
    end
    
    @result = Array.new
    if user_signed_in?
      current_user.import_photos_fb @event
      fb_result = get_tag_info @event.tag, "fb"
    end
    
    @photos = @event.photos
        
    in_result = Array.new
    if !params[:in_max_id].nil?
      in_result = get_tag_instagram @event.tag, :max_id => params[:in_max_id]
    elsif !params[:in_min_id].nil?
      in_result = get_tag_instagram @event.tag, :min_id => params[:in_min_id]
    else
      if params[:tw_max_id].nil?
        in_result = get_tag_instagram @event.tag, {}
      end   
    end    
    
    in_result.each do |r|
      entry = Media.new
      entry.user = r.user.username
      entry.profile_img = r.user.profile_picture
      entry.created_at = Time.at(r.created_time.to_i)
      if r.type == "image"
        entry.media = r.images.standard_resolution.url
        entry.type = 1
      elsif r.type == "video"
        entry.media = r.videos.standard_resolution.url
        entry.thumb = r.images.standard_resolution.url
        entry.type = 0
      end
            
      @result << entry
    end
    
    if in_result.length > 0
      if !params[:in_max_id].nil?
        @in_min_id = in_result.pagination.min_tag_id
      end
      
      @in_max_id = in_result.pagination.next_max_tag_id
    end        
    
    if !params[:tw_max_id].nil?
      tw_result = get_tag_twitter @event.tag, :max_id => params[:tw_max_id].to_i, :result_type => "mixed"
    elsif !params[:tw_min_id].nil?
       tw_result = get_tag_twitter @event.tag, :max_id => params[:tw_min_id].to_i, :result_type => "mixed"
    else
      if params[:in_max_id].nil?
        tw_result = get_tag_twitter @event.tag, {}
      end  
    end
    
    if tw_result.length > 0
      if !params[:tw_max_id].nil?
        @tw_min_id = tw_result[0].id
      end
       
      @tw_max_id = tw_result[tw_result.length - 1].id + 1 
    end
    
    tw_result.each do |r|
      entry = Media.new
      entry.oid = r.id
      entry.user = r.user.screen_name
      entry.profile_img = r.user.profile_image_url
      entry.created_at = r.created_at 
      entry.media = r.text
      entry.type = 2
      @result << entry
    end 
    
    @result = @result.sort_by { |x| x.created_at }.reverse   
  end
  
  def tag
    event = Event.where("id = ? and (owner = ? OR owner2 = ?)", params[:id], current_user.id, current_user.id).first
    if !event.blank?
      debugger
      event.tag = params[:tag]
      event.save
      
      render :nothing => true
    end
  end
  
  def tag_details
    @result = Array.new
    fb_result = get_tag_info params[:tag], "fb"
    
    in_result = get_tag_info params[:tag], "instagram"
    in_result.each do |r|
      entry = Media.new
      entry.user = r.user.username
      entry.profile_img = r.user.profile_picture
      entry.created_at = Time.at(r.caption.created_time.to_i)
      if r.type == "image"
        entry.media = r.images.standard_resolution
      elsif r.type == "video"
        entry.media = r.videos.standard_resolution
      end
      
      entry.type = 1
      @result << entry
    end
    
    tw_result = get_tag_info params[:tag], "twitter"
    tw_result.each do |r|
      entry = Media.new
      entry.user = r.user.name
      entry.profile_img = r.user.profile_image_url
      entry.created_at = r.created_at 
      entry.media = r.text
      entry.type = 2
      @result << entry
    end
    
    respond_to do |format|
      format.js { render :json => @result.to_json }
    end                    
  end
  
  private
  def get_tag_info tag, provider
    result = ''
    
    if provider == "instagram"
      result = get_tag_instagram tag      
    elsif provider == "twitter"      
      @twitter_client ||= Twitter::Client.new(
        :consumer_key =>  'ROZrWFKHxJeBPnLmWyz4g',
        :consumer_secret => '8K7WY88iDffc8lEqyQsF9Qrw9iCEwoXAdZUz5WvGws'
       )    
            
      result = get_tag_twitter tag
    elsif provider == "fb"
      result = get_tag_fb tag
    end
    
    return result    
  end
    
  def get_tag_instagram tag, options = {}
    Instagram.tag_recent_media(tag, options)
  end
  
  def get_tag_twitter tag, options = {}
    tweets = Array.new    
    @twitter_client ||= Twitter::Client.new(
      :consumer_key =>  'ROZrWFKHxJeBPnLmWyz4g',
      :consumer_secret => '8K7WY88iDffc8lEqyQsF9Qrw9iCEwoXAdZUz5WvGws'
     )
    
    t_result = @twitter_client.search(tag, options)    
    t_result.results.map do |tweet|     
      tweets << tweet
    end
    
    return tweets
  end
  
  def get_tag_fb tag
    @graph = Koala::Facebook::GraphAPI.new(current_user.token)
    news = @graph.fql_query("SELECT post_id, actor_id, target_id, message FROM stream where filter_key IN (SELECT filter_key FROM stream_filter WHERE uid='#{current_user.uid}' AND type='newsfeed')")
    related_news = Array.new
    
    news.each do |item|
      if item.include? tag
        related_news << item
      end
    end
    
    news
  end  
end
