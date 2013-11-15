task :twitter => :environment do
  desc "Run Twitter Scraper"
  require 'tweetstream'
  
  TweetStream.configure do |config|
    config.consumer_key       = 'ROZrWFKHxJeBPnLmWyz4g'
    config.consumer_secret    = '8K7WY88iDffc8lEqyQsF9Qrw9iCEwoXAdZUz5WvGws'
    config.oauth_token        = '590156688-x53i0nj3n4385u5cwSJWdoIcEv2yiNycS4ZBBlG2'
    config.oauth_token_secret = 'aXQPJQhIIlmNvL4m8mzaywjxXK2ZoglyHm01uM9ePUBTk'
    config.auth_method        = :oauth    
  end
    
  TweetStream::Client.new.on_reconnect do |timeout, retries|
    
  end.track('AHSCoven') do |status|
    #Tweet.create(:user_id  => status.user.id, :user_screen_name => status.user.screen_name, :user_profile_image_url => status.user.profile_image_url, :status_text => status.text, :status_id => status.id)
    puts "[#{status.user.screen_name}] #{status.text}"
  end
end