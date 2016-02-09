module Speak
  class Message < ActiveRecord::Base
    attr_accessible :text
  
    belongs_to :channel
    belongs_to :user
  
    validates :text, length: { maximum: 1024 }
    validates :channel, presence: true
    #validates :user, presence: true
  end
end