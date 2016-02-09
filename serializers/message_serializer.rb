module Speak
  class MessageSerializer < ActiveModel::Serializer
    root false

    attributes *[
      :id,
      :text, 
      :user_id,
      :created_at,
      :updated_at,
      :user
    ]

    def user
      UserSerializer.new(object.user).as_json if object.user
    end
  end
end