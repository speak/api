require_relative "../models/message"
require_relative "../models/channel"

module Speak
  class App < Sinatra::Base
          
    post '/channels/:channel_id/messages' do
      authenticate!
      
      channel = Channel.find(params[:channel_id])
      message = Message.new(accessible_params(Message))
      message.channel = channel
      message.user = current_user
      
      authorize! :create, message
      message.save!
      
      status 201
      json :ok => true, :message => MessageSerializer.new(message)
    end
    
    get '/channels/:channel_id/messages' do
      authenticate!
      
      channel = Channel.find(params[:channel_id])
      authorize! :read, channel

      json :ok => true, :messages => channel.messages
    end
    
    get '/channels/:channel_id/messages/:id' do
      authenticate!
      
      message = Message.find(params[:id])
      authorize! :read, message
      
      json :ok => true, :message => MessageSerializer.new(message)
    end

    put '/channels/:channel_id/messages/:id' do
      authenticate!
      
      message = Message.find(params[:id])
      authorize! :update, message
      
      message.assign_attributes(accessible_params(Message))
      message.save!
      
      json :ok => true, :message => MessageSerializer.new(message)
    end
    
    delete '/channels/:channel_id/messages/:id' do
      authenticate!
      
      message = Message.find(params[:id])
      authorize! :delete, message
      
      message.delete!
      json :ok => true
    end
  end
end