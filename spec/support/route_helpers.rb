module RouteHelpers
  def last_json
    @last_json ||= JSON.parse(last_response.body, object_class: OpenStruct)
  end
  
  def client
    @client ||= Songkick::OAuth2::Model::Client.create!(name: 'default', redirect_uri: 'http://example.com')
  end
  
  def authed(method, user, path, data=nil)
    attrs = client.attributes.merge({"response_type" => "token"})
    auth = Songkick::OAuth2::Provider::Authorization.new(user, attrs)
    auth.grant_access!

    header "Authorization", "Bearer #{auth.access_token}"
    self.send method, path, data
  end
end