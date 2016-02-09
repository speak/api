class CreateArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.string :name
      t.belongs_to :channel, index: true
      t.belongs_to :created_by, index: true
      t.belongs_to :stopped_by, index: true
      t.string :state
      t.string :opentok_id
      t.timestamps null: false
    end

    add_column :channels, :current_archive_id, :integer
    add_index :channels, :current_archive_id
  end
end
