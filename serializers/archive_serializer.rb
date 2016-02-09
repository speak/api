module Speak
  class ArchiveSerializer < ActiveModel::Serializer
    root false
    
    attributes(*[
      :id,
      :state,
      :download_url,
      :share_url,
      :channel,
      :created_at,
      :updated_at
    ])
    
    def channel
      {
        name: object.channel.name,
        public_url: object.channel.public_url,
        participated: object.channel.users.map { |u| UserSerializer.new(u).as_json } 
      }
    end
    
    def share_url
      # TODO
    end

    def download_url
      "#{ENV.fetch("API_URL")}/recordings/#{object.id}/download"
    end
  end
end
