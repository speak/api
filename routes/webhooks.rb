module Speak
  class App < Sinatra::Base

    post '/webhooks/clear-channel-users' do
      output = []
      users = User.where("last_active_at < ? AND channel_id IS NOT NULL", 1.minute.ago)
      users.each do |user|
        old_channel_id = user.channel_id
        user.channel_id = nil
        user.save!
        output << "User #{user.id} (#{user.first_name}) left channel #{old_channel_id} due to inactivity"
      end

      json :ok => true, :output => output
    end

    post '/webhooks/slack/slash-command' do
      #TODO
    end
    
    post '/webhooks/hipchat/slash-command' do
      #TODO
    end

    post  '/webhooks/archives' do
      Archive.where(opentok_id:params[:id]).update_all({
        state: params[:status],
        url: params[:url]
      })
      200
    end
  end
end
