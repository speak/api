require_relative './policy'

module Speak
  class ArchivePolicy < Policy
    def read?
      return true if record.created_by_id == user.id
      record.channel.participated_ids.include?(user.id)
    end
  end
end

