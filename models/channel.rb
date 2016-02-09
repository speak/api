require "opentok"

module Speak
  class Channel < ActiveRecord::Base
    class AlreadyRecordingError < StandardError;end
    class NotRecordingError < StandardError;end
    include BCrypt

    attr_accessible :name

    has_many :users
    has_many :messages
    has_many :archives
    has_one :current_archive, class_name: "Archive"

    after_initialize :set_path
    after_initialize :set_session_id

    validates :path, length: { minimum: 3, maximum: 100 }
    validates :path, presence: true
    validates :path, uniqueness: true
  
    def add_user(user)
      participated_users << user.id
      
      if users_count+1 > users_max_concurrent
        users_max_concurrent = users_count+1
      end

      save!
    end
    
    def lock!(user, secret)
      update_attributes!({
        locked: true,
        locked_at: DateTime.now,
        locked_by: user.id,
        password: secret
      }, without_protection: true)
    end
    
    def unlock!
      update_attributes!({
        locked: false,
        locked_at: nil,
        locked_by: nil
      }, without_protection: true)
    end

    def password
      @password ||= Password.new(password_hash)
    end

    def password=(new_password)
      @password = Password.create(new_password)
      self.password_hash = @password
    end
    
    def users
      User.where(id: participated_users)
    end

    def start_recording!(user)
      raise AlreadyRecordingError unless self.current_archive_id.nil?
      archive = opentok.archives.create(p2p_session_id, {
        name: name,
        has_audio: true,
        has_video: true
      })

      archive = self.archives.create({
        state: :pending,
        created_by: user,
        opentok_id: archive.id
      })
      self.current_archive_id = archive.id
      self.save!
      archive
    end

    def stop_recording!(user)
      raise NotRecordingError if self.current_archive_id.nil?

      opentok.archives.stop_by_id(self.current_archive.opentok_id)
      self.current_archive.update({
        stopped_by_id: user.id
      })
      self.current_archive_id = nil
      self.save!
      true
    end
    
    def public_url
      "#{ENV.fetch("APP_URL")}/#{path}"
    end
    
    private
  
    def set_path
      return if self.path
      self.path = loop do
        random_token = SecureRandom.hex(3)
        break random_token unless self.class.where(path: random_token).exists?
      end
    end
  
    def set_session_id
      return if self.p2p_session_id
      session = opentok.create_session :media_mode => :routed
      self.p2p_session_id = session.session_id
    end

    def opentok
      OpenTok::OpenTok.new ENV.fetch('TOKBOX_API_KEY'), ENV.fetch('TOKBOX_SECRET')
    end
  end
end
