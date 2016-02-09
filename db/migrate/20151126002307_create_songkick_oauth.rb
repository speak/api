class CreateSongkickOauth < ActiveRecord::Migration
  def up
    Songkick::OAuth2::Model::Schema.migrate
  end

  def down
    Songkick::OAuth2::Model::Schema.rollback
  end
end
