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

ActiveRecord::Schema.define(version: 2018_10_30_190420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.integer "state", default: 0
  end

  create_table "messages", force: :cascade do |t|
    t.string "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conversation_id"
    t.string "extra", default: "{}"
    t.integer "player_id"
    t.index ["player_id"], name: "index_messages_on_player_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "conversation_id"
    t.integer "player_id"
    t.boolean "seen", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_notifications_on_conversation_id"
    t.index ["player_id"], name: "index_notifications_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "number"
    t.boolean "left", default: false
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fate"
    t.string "change"
    t.integer "role", default: 0
    t.index ["game_id"], name: "index_players_on_game_id"
  end

end
