ActiveRecord::Schema[7.1].define(version: 2025_07_23_124800) do
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "secret_word"
    t.integer "attempts_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
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
