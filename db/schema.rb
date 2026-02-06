# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_02_05_023740) do
  create_table "participants", force: :cascade do |t|
    t.integer "session_id", null: false
    t.string "name"
    t.string "token"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_participants_on_session_id"
    t.index ["token"], name: "index_participants_on_token", unique: true
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name"
    t.string "cuisine"
    t.decimal "rating"
    t.integer "price_level"
    t.string "distance"
    t.text "description"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "code"
    t.integer "status", default: 0
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_sessions_on_code", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "participant_id", null: false
    t.integer "restaurant_id", null: false
    t.boolean "liked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id", "restaurant_id"], name: "index_votes_on_participant_id_and_restaurant_id", unique: true
    t.index ["participant_id"], name: "index_votes_on_participant_id"
    t.index ["restaurant_id"], name: "index_votes_on_restaurant_id"
  end

end
