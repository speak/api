STDOUT.sync = true

require "rack"
require "rack/contrib"
require "sinatra/base"
require "sinatra/cross_origin"
require "sinatra/json"
require "sinatra/activerecord"
require "songkick/oauth2/provider"
require "protected_attributes"
require "sentry-raven"
require 'active_model_serializers'
require 'bcrypt'

Songkick::OAuth2::Provider.realm = "Speak"

require_relative "lib/authorization_error"
require_relative "lib/authentication_error"
require_relative "helpers/auth"
require_relative "helpers/routes"
require_relative "serializers/auth_serializer"
require_relative "serializers/archive_serializer"
require_relative "serializers/channel_serializer"
require_relative "serializers/message_serializer"
require_relative "serializers/me_serializer"
require_relative "serializers/user_serializer"
require_relative "policies/user_policy"
require_relative "policies/channel_policy"
require_relative "policies/message_policy"

class Songkick::OAuth2::Provider::Authorization
  include ActiveModel::Serialization
end

class Songkick::OAuth2::Router
  class << self
    def access_token_from_request(env)
      request = request_from(env)
      params  = request.params
      header  = request.env['HTTP_AUTHORIZATION']

      header && header =~ /^Bearer\s+/ ?
        header.gsub(/^Bearer\s+/, '') :
        (params["token"] || params["access_token"])
    end
  end
end

Songkick::OAuth2::Provider.handle_passwords do |client, email, password, scopes|
  user = Speak::User.find_by(email: email)
  if user.password == password
    user.grant_access!(client, :scopes => scopes, :duration => 2.months)
  else
    nil
  end
end

module Speak
  class App < Sinatra::Base

    configure do
      register Sinatra::CrossOrigin

      set :cross_origin, true
      set :allow_methods, [:get, :post, :put, :options]
      set :bind, '0.0.0.0'
      set :logging, true
      set :json_encoder, :to_json
      set :show_exceptions, false
      set :raise_errors, false
      set :method_override, true
    end

    configure :staging do
      set :allow_origin, 'https://staging-go.speak.io'
    end

    configure :production do
      set :allow_origin, 'https://go.speak.io'
    end

    helpers AuthHelpers
    helpers RouteHelpers

    use Rack::Deflater
    use Rack::PostBodyContentTypeParser
    use Raven::Rack

    options "*" do
      status 200
    end

    get '/' do
      json :ok => true, :message => "Looking good here! Check out our documentation at https://docs.speak.io"
    end
  end
end

# important to declare these below the App class definition as they extend it
require_relative "models/user"
require_relative "models/archive"
require_relative "models/channel"
require_relative "models/message"
require_relative "models/archive"
require_relative "routes/auth"
require_relative "routes/archives"
require_relative "routes/errors"
require_relative "routes/users"
require_relative "routes/channels"
require_relative "routes/messages"
require_relative "routes/webhooks"
