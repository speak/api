# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160116221714) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archives", force: :cascade do |t|
    t.string   "name"
    t.integer  "channel_id"
    t.integer  "created_by_id"
    t.integer  "stopped_by_id"
    t.string   "state"
    t.string   "url"
    t.string   "opentok_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "archives", ["channel_id"], name: "index_archives_on_channel_id", using: :btree
  add_index "archives", ["created_by_id"], name: "index_archives_on_created_by_id", using: :btree
  add_index "archives", ["stopped_by_id"], name: "index_archives_on_stopped_by_id", using: :btree

  create_table "channels", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.string   "password"
    t.boolean  "locked"
    t.string   "p2p_session_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "users_count",          default: 0
    t.integer  "users_max_concurrent", default: 0
    t.integer  "participated_users",   default: [],              array: true
    t.string   "routed_session_id"
    t.integer  "current_archive_id"
    t.integer  "locked_by"
    t.datetime "locked_at"
    t.text     "password_hash"
  end

  add_index "channels", ["current_archive_id"], name: "index_channels_on_current_archive_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "channel_id"
    t.integer  "user_id"
  end

  add_index "messages", ["channel_id"], name: "index_messages_on_channel_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "oauth2_authorizations", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth2_resource_owner_type"
    t.integer  "oauth2_resource_owner_id"
    t.integer  "client_id"
    t.string   "scope"
    t.string   "code",                       limit: 40
    t.string   "access_token_hash",          limit: 40
    t.string   "refresh_token_hash",         limit: 40
    t.datetime "expires_at"
  end

  add_index "oauth2_authorizations", ["access_token_hash"], name: "index_oauth2_authorizations_on_access_token_hash", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "code"], name: "index_oauth2_authorizations_on_client_id_and_code", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "oauth2_resource_owner_type", "oauth2_resource_owner_id"], name: "index_owner_client_pairs", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "refresh_token_hash"], name: "index_oauth2_authorizations_on_client_id_and_refresh_token_hash", unique: true, using: :btree

  create_table "oauth2_clients", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth2_client_owner_type"
    t.integer  "oauth2_client_owner_id"
    t.string   "name"
    t.string   "client_id"
    t.string   "client_secret_hash"
    t.string   "redirect_uri"
  end

  add_index "oauth2_clients", ["client_id"], name: "index_oauth2_clients_on_client_id", unique: true, using: :btree
  add_index "oauth2_clients", ["name"], name: "index_oauth2_clients_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "confirmed_at"
    t.datetime "last_active_at"
    t.integer  "channel_id"
    t.integer  "channels_count",    default: 0
    t.integer  "default_avatar_id"
    t.string   "avatar_small"
    t.string   "avatar_medium"
    t.string   "avatar_large"
    t.string   "last_ip"
    t.text     "password_hash"
  end

end
