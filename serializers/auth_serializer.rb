module Speak
  class AuthSerializer < ActiveModel::Serializer
    root false
    
    attributes *[
      :access_token,
      :refresh_token
    ]

  end
end
