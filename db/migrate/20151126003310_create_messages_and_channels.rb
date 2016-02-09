class CreateMessagesAndChannels < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      
      t.timestamps null: false
      t.belongs_to :channel, index: true
      t.belongs_to :user, index: true
    end
    
    create_table :channels do |t|
      t.string :name
      t.string :path
      t.string :password
      t.boolean :locked, default: false
      t.string :p2p_session_id
      t.string :relayed_session_id
      
      t.timestamps null: false
    end
  end
end
