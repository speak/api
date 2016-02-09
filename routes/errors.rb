module Speak
  class App < Sinatra::Base
  
    not_found do
      status 404
      json :ok => false, :error => "The endpoint you requested does not exist. Check out our documentation at https://docs.speak.io for a full list of available endpoints and methods."
    end
    
    error OpenTok::OpenTokError do
      if env['sinatra.error'].message.include? "Failed to connect"
        status 504
      else
        status 500
      end
      
      json :ok => false, :error => "An error occurred communicating with a third-party service, try again."
    end
    
    error Speak::AuthenticationError do
      status 401
      json :ok => false, :error => "This endpoint requires authentication - make sure your oauth token is in the request headers."
    end
    
    error Speak::AuthorizationError do
      status 403
      json :ok => false, :error => "You are not authorized to access this resource."
    end
    
    error ActiveRecord::RecordInvalid do
      status 422
      
      params = {}
      env['sinatra.error'].record.errors.messages.each do |key, value|
        params[key] = "#{key.to_s.gsub('_', ' ').capitalize} #{value.first}"
      end
      
      json :ok => false, :error => "The record could not be saved.", :params => params
    end
  
    error ActiveRecord::RecordNotFound do
      status 404
      json :ok => false, :error => "The resource you requested does not exist. Perhaps it was recently deleted."
    end
  
    error do
      status 500
      json :ok => false, :error => "An unexpected error occurred, we've been alerted about the issue. Perhaps try the request again?"
    end
    
  end
end