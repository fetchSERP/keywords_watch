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

ActiveRecord::Schema[8.0].define(version: 2025_05_29_162834) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "backlinks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "domain_id", null: false
    t.string "source_url"
    t.string "target_url"
    t.string "anchor_text"
    t.boolean "nofollow"
    t.string "rel_attributes", default: [], array: true
    t.string "context_text"
    t.string "source_domain"
    t.string "target_domain"
    t.string "page_title"
    t.string "meta_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_backlinks_on_domain_id"
    t.index ["user_id"], name: "index_backlinks_on_user_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id", null: false
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "domains", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_domains_on_user_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "name"
    t.integer "avg_monthly_searches"
    t.string "competition"
    t.integer "competition_index"
    t.integer "low_top_of_page_bid_micros"
    t.integer "high_top_of_page_bid_micros"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "domain_id", null: false
    t.boolean "indexed", default: false
    t.string "urls", default: [], array: true
    t.index ["domain_id"], name: "index_keywords_on_domain_id"
    t.index ["user_id"], name: "index_keywords_on_user_id"
  end

  create_table "rankings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "domain_id", null: false
    t.bigint "keyword_id", null: false
    t.integer "rank"
    t.string "search_engine"
    t.string "url"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_rankings_on_domain_id"
    t.index ["keyword_id"], name: "index_rankings_on_keyword_id"
    t.index ["user_id"], name: "index_rankings_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "backlinks", "domains"
  add_foreign_key "backlinks", "users"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "domains", "users"
  add_foreign_key "keywords", "domains"
  add_foreign_key "keywords", "users"
  add_foreign_key "rankings", "domains"
  add_foreign_key "rankings", "keywords"
  add_foreign_key "rankings", "users"
  add_foreign_key "sessions", "users"
end
