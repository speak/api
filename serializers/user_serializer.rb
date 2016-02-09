module Speak
  class UserSerializer < ActiveModel::Serializer
    root false
    
    attributes *[
      :id, 
      :first_name, 
      :last_name,
      :avatars 
    ]

  end
end
