class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :store_location
  include Devise::Controllers::Rememberable
                  
  def after_sign_in_path_for(resource)
    remember_me resource
    session[:return_to]      
  end
 
  def store_location
    if !request.fullpath.include?('/user')
      session[:return_to] = request.fullpath
    end
  end
     
end
