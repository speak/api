module Speak
  class Archive < ActiveRecord::Base
    default_scope -> { order(created_at: :desc) }
    
    belongs_to :created_by, class_name:"User"
    belongs_to :channel
    
    def url
      channel.send(:opentok).archives.find(opentok_id).url
    end
  end
end
