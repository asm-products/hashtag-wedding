class CallbacksController < Devise::OmniauthCallbacksController
  def facebook
    
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    
    if @user.persisted?      
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_event_path
    end
  end
  
  def failure
    @event = Event.new
    @event.errors.add(:owner, "user_denied") if params[:error_reason] == "user_denied"
    p @event.errors
    
    render "events/new"
  end  
end
