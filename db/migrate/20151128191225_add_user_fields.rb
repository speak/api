class AddUserFields < ActiveRecord::Migration
  def change
    add_column :users, :confirmed_at, :datetime
    add_column :users, :last_active_at, :datetime
    add_column :users, :channel_id, :integer
    add_column :users, :channels_count, :integer, default: 0
    add_column :users, :default_avatar_id, :integer
    add_column :users, :avatar_small, :string
    add_column :users, :avatar_medium, :string
    add_column :users, :avatar_large, :string
    add_column :users, :last_ip, :string
  end
end
