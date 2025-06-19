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

ActiveRecord::Schema[8.0].define(version: 2025_06_04_154309) do
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

  create_table "competitors", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "domain_id", null: false
    t.string "domain_name"
    t.integer "serp_appearances_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_competitors_on_domain_id"
    t.index ["user_id"], name: "index_competitors_on_user_id"
  end

  create_table "domains", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country", default: "us"
    t.jsonb "infos", default: {}
    t.jsonb "analysis_status", default: {}
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
    t.integer "ranking"
    t.string "ranking_url"
    t.integer "search_intent"
    t.boolean "is_tracked", default: false
    t.integer "ai_score"
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

  create_table "search_engine_results", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "keyword_id", null: false
    t.string "site_name"
    t.string "url"
    t.string "title"
    t.text "description"
    t.integer "ranking"
    t.string "search_engine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "competitor_id", null: false
    t.index ["competitor_id"], name: "index_search_engine_results_on_competitor_id"
    t.index ["keyword_id"], name: "index_search_engine_results_on_keyword_id"
    t.index ["user_id"], name: "index_search_engine_results_on_user_id"
  end

  create_table "seo_keywords", force: :cascade do |t|
    t.string "name"
    t.boolean "is_long_tail", default: false
    t.bigint "seo_keyword_id"
    t.integer "search_intent", default: 0
    t.string "competition"
    t.string "search_volume"
    t.string "avg_monthly_searches"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_seo_keywords_on_name", unique: true
    t.index ["seo_keyword_id"], name: "index_seo_keywords_on_seo_keyword_id"
  end

  create_table "seo_pages", force: :cascade do |t|
    t.bigint "seo_keyword_id", null: false
    t.string "slug"
    t.string "title"
    t.text "meta_description"
    t.text "headline"
    t.text "subheading"
    t.text "content"
    t.bigint "seo_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["seo_keyword_id"], name: "index_seo_pages_on_seo_keyword_id"
    t.index ["seo_page_id"], name: "index_seo_pages_on_seo_page_id"
    t.index ["slug"], name: "index_seo_pages_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "technical_seo_reports", force: :cascade do |t|
    t.jsonb "analysis"
    t.bigint "user_id", null: false
    t.bigint "web_page_id", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_technical_seo_reports_on_user_id"
    t.index ["web_page_id"], name: "index_technical_seo_reports_on_web_page_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.integer "credit"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "web_pages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "domain_id", null: false
    t.string "url"
    t.string "title"
    t.string "meta_description"
    t.string "meta_keywords", default: [], array: true
    t.text "h1", default: [], array: true
    t.text "h2", default: [], array: true
    t.text "h3", default: [], array: true
    t.text "h4", default: [], array: true
    t.text "h5", default: [], array: true
    t.text "body"
    t.integer "word_count"
    t.string "internal_links", default: [], array: true
    t.string "external_links", default: [], array: true
    t.string "canonical_url"
    t.boolean "indexed"
    t.text "html"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_web_pages_on_domain_id"
    t.index ["user_id"], name: "index_web_pages_on_user_id"
  end

  add_foreign_key "backlinks", "domains"
  add_foreign_key "backlinks", "users"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "competitors", "domains"
  add_foreign_key "competitors", "users"
  add_foreign_key "domains", "users"
  add_foreign_key "keywords", "domains"
  add_foreign_key "keywords", "users"
  add_foreign_key "rankings", "domains"
  add_foreign_key "rankings", "keywords"
  add_foreign_key "rankings", "users"
  add_foreign_key "search_engine_results", "competitors"
  add_foreign_key "search_engine_results", "keywords"
  add_foreign_key "search_engine_results", "users"
  add_foreign_key "seo_keywords", "seo_keywords"
  add_foreign_key "seo_pages", "seo_keywords"
  add_foreign_key "seo_pages", "seo_pages"
  add_foreign_key "sessions", "users"
  add_foreign_key "technical_seo_reports", "users"
  add_foreign_key "technical_seo_reports", "web_pages"
  add_foreign_key "web_pages", "domains"
  add_foreign_key "web_pages", "users"
end
