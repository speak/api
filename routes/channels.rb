require "slugify"
require_relative "../models/channel"

module Speak
  class App < Sinatra::Base
          
    post '/channels' do
      authenticate!
      
      channel = Channel.new(params)
      channel.path = params[:path].slugify if params[:path].present?
      
      authorize! :create, channel
      channel.save!
      token = current_user.generate_token(channel)
      
      status 201
      json :ok => true, :channel_auth => {token: token}, :channel => ChannelSerializer.new(channel)
    end
    
    get '/channels' do
      authenticate!

      channels = Channel.where(user_id: current_user.id)
      json :ok => true, :channels => channels
    end
    
    get '/channels/:finder' do
      channel = Channel.find_by_id(params[:finder]) || Channel.find_by_path(params[:finder])
      halt(404) unless channel
      authorize! :read, channel
      
      json :ok => true, :channel => ChannelSerializer.new(channel)
    end
    
    put '/channels/:id' do
      authenticate!
      
      channel = Channel.find(params[:id])
      authorize! :update, channel
      
      channel.assign_attributes(accessible_params(Channel))
      channel.save!
      
      json :ok => true, :channel => ChannelSerializer.new(channel)
    end
    
    post '/channels/:id/auth' do
      authenticate!
      
      channel = Channel.find(params[:id])
      
      if !channel.locked? || channel.locked_by == current_user.id || channel.password == params[:password]
        token = current_user.generate_token(channel)
        current_user.update_attribute(:channel_id, channel.id)
        
        status 201
        json :ok => true, :channel_auth => {token: token}, :channel => ChannelSerializer.new(channel)
      else
        status 401
        json :ok => false
      end
    end
    
    get '/channels/:id/ping' do
      authenticate!
      # NOTE: this simply updates the last_active_at attribute on the user
      
      json :ok => true
    end

    post '/channels/:id/recording' do
      authenticate!
      channel = Channel.find(params[:id])
      authorize! :join, channel
      archive = channel.start_recording!(current_user)
      status 201
      json :ok => true, recording: ArchiveSerializer.new(archive)
    end

    post '/channels/:channel_id/recording/:id/stop' do
      authenticate!
      channel = Channel.find(params["channel_id"])
      authorize! :join, channel
      return 404 if channel.current_archive_id != params[:id].to_i
      archive = channel.current_archive
      channel.stop_recording!(current_user)
      json :ok => true, recording: ArchiveSerializer.new(archive)
    end

    post '/channels/:id/lock' do
      authenticate!
      
      channel = Channel.find(params[:id])
      authorize! :lock, channel
      channel.lock!(current_user, params[:password])
      
      status 200
      json :ok => true, :channel => ChannelSerializer.new(channel)
    end
    
    post '/channels/:id/unlock' do
      authenticate!
      
      channel = Channel.find(params[:id])
      authorize! :unlock, channel

      if channel.password == params[:password]
        channel.unlock!
        status 200
        json :ok => true, :channel => ChannelSerializer.new(channel)
      else
        raise Speak::AuthorizationError.new("Incorrect Password")
      end
    end
  end
end
