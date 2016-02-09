module Speak
  module RouteHelpers
    
    def accessible_params(klass)
      keys = klass.accessible_attributes
      params.select { |k,v| keys.include?(k) }
    end
    
    def authorize!(action, record, user=nil)
      record_class = (record.class.name == "Class" ? record.to_s : record.class.name) + "Policy"
      require_relative "../policies/#{record_class.underscore.gsub("speak/","")}"
      policy_class = Object.const_get(record_class)
      
      unless policy_class.new(user || current_user, record).send(:"#{action}?")
        raise Speak::AuthorizationError.new("Unauthorized Error")
      end
    end
  end
end