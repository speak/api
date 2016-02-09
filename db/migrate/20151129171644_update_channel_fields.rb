require_relative "../../models/channel"

class UpdateChannelFields < ActiveRecord::Migration
  def up
    add_column :channels, :users_count, :integer, :default => 0
    add_column :channels, :users_max_concurrent, :integer, :default => 0
    add_column :channels, :participated_users, :integer, array: true, default: []
    add_column :channels, :routed_session_id, :string
    remove_column :channels, :relayed_session_id
    
    Speak::Channel.reset_column_information
    Speak::Channel.all.each do |c|
      Speak::Channel.update_counters c.id, :users_count => c.users.length
    end
  end
  
  def down
    remove_column :channels, :users_count
    remove_column :channels, :users_max_concurrent
    remove_column :channels, :routed_session_id
    remove_column :channels, :participated_users
    add_column :channels, :relayed_session_id, :string
  end
end