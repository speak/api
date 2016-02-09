module Speak
  module AuthHelpers
    def current_user
      @current_user ||= current_user_from_oauth
    end
    
    def authenticate!
      unless current_user && current_user.record_activity!(request)
        raise Speak::AuthenticationError.new
      end
    end
    
    private
    
    def current_user_from_oauth
      authorization = Songkick::OAuth2::Provider.access_token(:implicit, [], env)
      if authorization.valid?
        authorization.owner
      else
        nil
      end
    end
  end
end
