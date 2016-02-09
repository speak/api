require_relative './policy'

module Speak
  class ChannelPolicy < Policy
    def create?
      true
    end

    def read?
      true
    end

    def update?
      user.channel_id == record.id
    end

    def delete?
      false
    end

    def lock?
      #TODO: check that user has a paid account
      !record.locked? && user.channel_id == record.id
    end

    def unlock?
      record.locked_by == user.id
    end

    def join?
      !record.locked?
    end
  end
end