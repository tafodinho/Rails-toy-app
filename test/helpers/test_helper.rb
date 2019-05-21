ENV['RAILS_ENV'] ||= 'test'

class ActiveSupport::TestCase
    fixtures :all
  
    # Returns true if a test user is logged in.
    def is_logged_in?
      !session[:user_id].nil?
    end
end