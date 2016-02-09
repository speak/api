module Speak
  class MeSerializer < ActiveModel::Serializer
    root false
    
    attributes *[
      :id, 
      :first_name, 
      :last_name,
      :avatars,
      :email,
      :has_password
    ]

    def has_password
      !!object.password_hash
    end
  end
end
