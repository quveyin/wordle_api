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

ActiveRecord::Schema[7.1].define(version: 2025_07_30_122224) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_words", force: :cascade do |t|
    t.string "word"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_daily_words_on_date", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.string "secret_word"
    t.integer "attempts_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "token"
    t.date "game_date"
    t.index ["token"], name: "index_games_on_token", unique: true
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "guesses", force: :cascade do |t|
    t.string "word"
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_guesses_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "games", "users"
  add_foreign_key "guesses", "games"
end