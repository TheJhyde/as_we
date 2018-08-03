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

ActiveRecord::Schema.define(version: 2018_08_01_170908) do

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations_players", force: :cascade do |t|
    t.integer "player_id"
    t.integer "conversation_id"
    t.index ["conversation_id"], name: "index_conversations_players_on_conversation_id"
    t.index ["player_id"], name: "index_conversations_players_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "code"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "from_id"
    t.integer "conversation_id"
    t.string "extra", default: "{}"
  end

  create_table "players", force: :cascade do |t|
    t.string "number"
    t.boolean "host", default: false
    t.boolean "left", default: false
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

end
