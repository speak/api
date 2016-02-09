module Speak
  class App < Sinatra::Base

    post '/users' do
      user  = User.new(accessible_params(User))
      user.password = params["password"] if params["email"] && params["password"]
      user.save!

      client = Songkick::OAuth2::Model::Client.find(1)

      attrs = client.attributes.merge({
        "response_type" => "token"
      })

      auth = Songkick::OAuth2::Provider::Authorization.new(
        user, 
        attrs
      )
      auth.grant_access!

      status 201
      json({
        ok: true,
        user: UserSerializer.new(user).as_json,
        auth: AuthSerializer.new(auth).as_json
      })
    end
    
    put '/users/:id' do
      authenticate!
      
      user = User.find(params[:id])
      authorize! :update, user
      
      puts accessible_params(User).inspect
      user.assign_attributes(accessible_params(User))
      user.save!
      
      if current_user.id == user.id
        json :ok => true, :user => MeSerializer.new(user).as_json
      else
        json :ok => true, :user => UserSerializer.new(user).as_json
      end
    end
    
    get '/users/me' do
      authenticate!
      json :ok => true, :user => MeSerializer.new(current_user).as_json
    end
  end
end
