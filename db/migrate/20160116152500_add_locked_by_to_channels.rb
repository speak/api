class AddLockedByToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :locked_by, :integer
    add_column :channels, :locked_at, :datetime
    add_column :channels, :password_hash, :text
  end
end
