require 'spec_helper.rb'

describe "Channels" do
  let(:channel) { Speak::Channel.create }
  let(:user) { Speak::User.create }
  let(:other_user) { Speak::User.create }

  before do
    OpenTok::OpenTok = double()
    allow(OpenTok::OpenTok).to receive(:new) {
      o = double()
      allow(o).to receive(:create_session) {
        s = double()
        allow(s).to receive(:session_id) { "opentok-session-123" }
        s
      }
      allow(o).to receive(:generate_token) {
        "opentok-token-123"
      }
      o
    }
  end
  
  describe "create" do
    context "unauthenticated" do
      it "should respond with unauthorized" do
        post "/channels"
        expect(last_response.status).to eql(401)
        expect(last_json.ok).to eql(false)
      end
    end
    
    context "authenticated" do
      context "with no data" do
        it "should respond with created channel and auth" do
          authed :post, user, "/channels"
          expect(last_response.status).to eql(201)
          expect(last_json.ok).to eql(true)
          expect(last_json.channel.id).to be_a(Integer)
          expect(last_json.channel.path).to be_a(String)
          expect(last_json.channel_auth.token).to eql("opentok-token-123")
        end
      end
      context "with name" do
        it "should respond with created channel and auth" do
          authed :post, user, "/channels", {name: "Meeting"}
          expect(last_response.status).to eql(201)
          expect(last_json.ok).to eql(true)
          expect(last_json.channel.id).to be_a(Integer)
          expect(last_json.channel.name).to eql("Meeting")
          expect(last_json.channel_auth.token).to eql("opentok-token-123")
        end
      end
      context "with path" do
        it "should respond with created channel and auth" do
          authed :post, user, "/channels", {path: "blah"}
          expect(last_response.status).to eql(201)
          expect(last_json.ok).to eql(true)
          expect(last_json.channel.id).to be_a(Integer)
          expect(last_json.channel.path).to eql("blah")
          expect(last_json.channel_auth.token).to eql("opentok-token-123")
        end
        
        it "should slugify bad characters" do
          authed :post, user, "/channels", {path: "%*@teSt^!"}
          expect(last_response.status).to eql(201)
          expect(last_json.ok).to eql(true)
          expect(last_json.channel.id).to be_a(Integer)
          expect(last_json.channel.path).to eql("test")
          expect(last_json.channel_auth.token).to eql("opentok-token-123")
        end
      end
    end
  end
  
  describe "show" do
    context "with unknown id" do
      it "should respond with a 404" do
        get "/channels/1000"
        expect(last_response.status).to eql(404)
        expect(last_json.ok).to eql(false)
      end
    end
    context "unauthenticated" do
      it "should respond with channel when found by id" do
        get "/channels/#{channel.id}"
        expect(last_response.status).to eql(200)
        expect(last_json.ok).to eql(true)
        expect(last_json.channel.id).to eql(channel.id)
        expect(last_json.channel.path).to eql(channel.path)
      end
    
      it "should respond with channel when found by path" do
        get "/channels/#{channel.path}"
        expect(last_response.status).to eql(200)
        expect(last_json.ok).to eql(true)
        expect(last_json.channel.id).to eql(channel.id)
        expect(last_json.channel.path).to eql(channel.path)
      end
    end
    context "authenticated" do
      it "should respond with channel when found by id" do
        authed :get, user, "/channels/#{channel.id}"
        expect(last_response.status).to eql(200)
        expect(last_json.ok).to eql(true)
        expect(last_json.channel.id).to eql(channel.id)
        expect(last_json.channel.path).to eql(channel.path)
      end
    
      it "should respond with channel when found by path" do
        authed :get, user, "/channels/#{channel.path}"
        expect(last_response.status).to eql(200)
        expect(last_json.ok).to eql(true)
        expect(last_json.channel.id).to eql(channel.id)
        expect(last_json.channel.path).to eql(channel.path)
      end
    end
  end
  
  describe "lock" do
    context "unauthenticated" do
      it "should respond with unauthorized" do
        post "/channels/#{channel.id}/lock"
        expect(last_response.status).to eql(401)
        expect(last_json.ok).to eql(false)
      end
    end
    
    context "authenticated" do
      context "not in channel" do
        it "should respond with unauthorized" do
          authed :post, user, "/channels/#{channel.id}/lock"
          expect(last_response.status).to eql(403)
          expect(last_json.ok).to eql(false)
        end
      end
      
      context "in channel" do
        before do
          user.update_attribute(:channel_id, channel.id)
        end
        
        context "not locked" do
          it "should respond with locked channel" do
            authed :post, user, "/channels/#{channel.id}/lock", {password: "secret"}
            expect(last_response.status).to eql(200)
            expect(last_json.ok).to eql(true)
            expect(last_json.channel.locked).to eql(true)
          end
        end
      end
    end
  end
  
  describe "unlock" do
    context "unauthenticated" do
      it "should respond with unauthorized" do
        post "/channels/#{channel.id}/unlock"
        expect(last_response.status).to eql(401)
        expect(last_json.ok).to eql(false)
      end
    end
    
    context "authenticated" do
      context "not in channel" do
        it "should respond with unauthorized" do
          authed :post, user, "/channels/#{channel.id}/unlock"
          expect(last_response.status).to eql(403)
          expect(last_json.ok).to eql(false)
        end
      end
      
      context "in channel" do
        before do
          user.update_attribute(:channel_id, channel.id)
        end
        
        context "locked by us" do
          before do
            channel.lock!(user, "pass123")
          end
          
          it "should respond with unlocked channel when password provided" do
            authed :post, user, "/channels/#{channel.id}/unlock", {password: "pass123"}
            expect(last_response.status).to eql(200)
            expect(last_json.ok).to eql(true)
            expect(last_json.channel.locked).to eql(false)
          end
          
          it "should respond with error when incorrect password" do
            authed :post, user, "/channels/#{channel.id}/unlock", {password: "456pass"}
            expect(last_response.status).to eql(403)
            expect(last_json.ok).to eql(false)
          end
        end
        
        context "locked by someone else" do
          before do
            channel.lock!(other_user, "pass123")
          end
          
          it "should respond with updated channel" do
            authed :post, user, "/channels/#{channel.id}/unlock"
            expect(last_response.status).to eql(403)
            expect(last_json.ok).to eql(false)
          end
        end
      end
    end
  end
  
  describe "auth" do
    context "unauthenticated" do
      it "should respond with unauthorized" do
        post "/channels/#{channel.id}/auth"
        expect(last_response.status).to eql(401)
        expect(last_json.ok).to eql(false)
      end
    end
    
    context "authenticated" do
      context "unlocked channel" do
        it "should respond with token" do
          authed :post, user, "/channels/#{channel.id}/auth"
          expect(last_response.status).to eql(201)
          expect(last_json.ok).to eql(true)
        end
      end
      
      context "locked channel" do
        before do
          channel.lock!(other_user, "secret")
        end
        
        it "should respond unauthenticated without password" do
          authed :post, user, "/channels/#{channel.id}/auth"
          expect(last_response.status).to eql(401)
          expect(last_json.ok).to eql(false)
        end
        
        it "should respond with token with password" do
          authed :post, user, "/channels/#{channel.id}/auth", {password: "secret"}
          expect(last_response.status).to eql(201)
          expect(last_json.ok).to eql(true)
        end
      end
    end
  end
    
  describe "update" do
    context "unauthenticated" do
      it "should respond with unauthorized" do
        put "/channels/#{channel.id}"
        expect(last_response.status).to eql(401)
        expect(last_json.ok).to eql(false)
      end
    end
    
    context "authenticated" do
      context "not in channel" do
        it "should respond with unauthorized" do
          authed :put, user, "/channels/#{channel.id}"
          expect(last_response.status).to eql(403)
          expect(last_json.ok).to eql(false)
        end
      end
      
      context "in channel" do
        before do
          user.channel_id = channel.id
          user.save!
        end
        
        it "should respond with updated channel" do
          authed :put, user, "/channels/#{channel.id}", {name: "Standup"}
          expect(last_response.status).to eql(200)
          expect(last_json.ok).to eql(true)
          expect(last_json.channel.name).to eql("Standup")
        end
      end
    end
  end
end