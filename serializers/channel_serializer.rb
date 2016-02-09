module Speak
  class ChannelSerializer < ActiveModel::Serializer
    root false
    
    attributes(*[
      :id,
      :name,
      :path,
      :locked,
      :locked_by,
      :public_url,
      :created_at,
      :updated_at,
      :p2p_session_id,
      :recording
    ])

    def recording
      return {} unless object.current_archive.present?
      {
        id: object.current_archive.id,
        url: object.current_archive.url
      }
    end
  end
end
