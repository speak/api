require 'spec_helper.rb'

describe "User show me" do
  context "unauthenticated" do
    it "should respond with an authentication error" do
      get '/users/me'
      expect(last_response.status).to eql(401)
      expect(last_json.ok).to eql(false)
    end
  end
  
  context "authenticated" do
    let(:user) { Speak::User.create(first_name: "Jane") }

    it "should respond with user" do
      authed :get, user, "/users/me"
      expect(last_response.status).to eql(200)
      expect(last_json.ok).to eql(true)
      expect(last_json.user.id).to eql(user.id)
      expect(last_json.user.first_name).to eql(user.first_name)
    end
  end
end