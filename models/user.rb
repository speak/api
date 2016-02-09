require "opentok"

module Speak
  class User < ActiveRecord::Base
    include ActiveModel::MassAssignmentSecurity
    include Songkick::OAuth2::Model::ResourceOwner
    include BCrypt
    
    attr_accessible :first_name, :last_name, :email, :password
    
    belongs_to :channel, :counter_cache => true
    before_validation :set_default_avatar_id
    
    validates :password, presence: true, if: :auth_attributes?
    validates :email, presence: true, if: :auth_attributes?
    validates :email, uniqueness: true, if: :auth_attributes?
    validates :first_name, presence: true
    
    def avatars
      default_avatar_url = "https://s3.amazonaws.com/speak-assets/avatars/avatar-#{default_avatar_id || 1}.png"
      hash = Digest::MD5.hexdigest(email || "")
      base = "https://www.gravatar.com/avatar/#{hash}?d=#{CGI.escape(default_avatar_url)}"
      
      {
        default: default_avatar_url,
        small: avatar_small || "#{base}&s=30",
        medium: avatar_medium || "#{base}&s=100",
        large: avatar_large || "#{base}&s=200"
      }
    end
    
    def generate_token(channel)
      # TODO: generate token based on p2p or routed session
      token = opentok.generate_token(channel.p2p_session_id, {data: UserSerializer.new(self).to_json})
      
      if self.channel != channel
        self.channel_id = channel.id
        self.channels_count = self.channels_count+1
        self.save!
      end
      
      token
    end

    def auth_attributes?
      password_hash || email
    end

    def password
      @password ||= Password.new(password_hash)
    end

    def password=(new_password)
      @password = Password.create(new_password)
      self.password_hash = @password
    end

    def record_activity!(request)
      if !self.last_active_at || self.last_active_at < 30.seconds.ago
        self.last_active_at = DateTime.now
        self.last_ip = request.ip
        self.save!
      else
        true
      end
    end
    
    def channel_id=(a)
      # suggested https://github.com/rails/rails/issues/586#issuecomment-3667085
      super
      channel_id_assigned
    end

    private

    def channel_id_assigned
      self.channel.add_user(self) if self.channel_id
    end
    
    def set_default_avatar_id
      return if self.default_avatar_id
      self.default_avatar_id = Random.new.rand(0..10)
    end

    def opentok
      OpenTok::OpenTok.new ENV.fetch('TOKBOX_API_KEY'), ENV.fetch('TOKBOX_SECRET')
    end
  end
end
