require_relative './policy'

module Speak
  class UserPolicy < Policy
    def create?
      true
    end

    def read?
      user.channel_id == record.channel_id
    end

    def update?
      user.id == record.id
    end

    def delete?
      false
    end
  end
end