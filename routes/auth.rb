module Speak
  class App < Sinatra::Base

    post '/token' do
      client = Songkick::OAuth2::Model::Client.find(1)
      original_auth = Songkick::OAuth2::Provider.handle_password(client, params[:email], params[:password], [])

      if original_auth
        user = original_auth.owner
        Songkick::OAuth2::Model::Authorization.where(client_id:client.client_id, oauth2_resource_owner_id:user.id).each(&:destroy!)
        attrs = client.attributes.merge({
          "response_type" => "token"
        })
        auth = Songkick::OAuth2::Provider::Authorization.new(
          user, 
          attrs
        )
        auth.grant_access!

        json({
          ok: true,
          auth: AuthSerializer.new(auth).as_json
        })
      else
        raise AuthenticationError
      end
    end

  end
end
