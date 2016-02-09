require_relative './policy'

module Speak
  class MessagePolicy < Policy
    def create?
      return false unless user.channel_id
      user.channel_id == record.channel_id
    end
  
    def read?
      user.channel_id == record.channel_id
    end
  
    def update?
      record.user_id == user.id
    end
  
    def delete?
      record.user_id == user.id
    end
  end
end
