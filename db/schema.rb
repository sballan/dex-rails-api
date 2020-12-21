# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_20_023121) do

  create_table "links", force: :cascade do |t|
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["from_id"], name: "index_links_on_from_id"
    t.index ["to_id", "from_id", "text"], name: "index_links_on_to_id_and_from_id_and_text", unique: true
    t.index ["to_id"], name: "index_links_on_to_id"
  end

  create_table "page_matches", force: :cascade do |t|
    t.integer "query_id", null: false
    t.integer "page_id", null: false
    t.string "kind"
    t.boolean "full"
    t.integer "distance"
    t.integer "length"
    t.index ["page_id"], name: "index_page_matches_on_page_id"
    t.index ["query_id", "page_id", "kind", "full", "distance", "length"], name: "index_page_matches_on_query_page_kind_full_distance_length", unique: true
    t.index ["query_id"], name: "index_page_matches_on_query_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "refresh_status", default: 0
    t.integer "parse_status", default: 0
    t.integer "index_status", default: 0
    t.integer "cache_status", default: 0
    t.datetime "refresh_started_at"
    t.datetime "refresh_finished_at"
    t.datetime "parse_started_at"
    t.datetime "parse_finished_at"
    t.datetime "index_started_at"
    t.datetime "index_finished_at"
    t.datetime "cache_started_at"
    t.datetime "cache_finished_at"
    t.index ["cache_status"], name: "index_pages_on_cache_status"
    t.index ["index_status"], name: "index_pages_on_index_status"
    t.index ["parse_status"], name: "index_pages_on_parse_status"
    t.index ["refresh_status"], name: "index_pages_on_refresh_status"
    t.index ["url"], name: "index_pages_on_url", unique: true
  end

  create_table "queries", force: :cascade do |t|
    t.string "text", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "cached_at"
    t.index ["text"], name: "index_queries_on_text", unique: true
  end

  create_table "results", force: :cascade do |t|
    t.string "kind"
    t.integer "query_id", null: false
    t.integer "page_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["page_id"], name: "index_results_on_page_id"
    t.index ["query_id", "page_id", "kind"], name: "index_results_on_query_id_and_page_id_and_kind", unique: true
    t.index ["query_id"], name: "index_results_on_query_id"
  end

  create_table "scrape_batches", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "status", default: 0
    t.datetime "cache_started_at"
    t.datetime "cache_finished_at"
    t.integer "cache_status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cache_status"], name: "index_scrape_batches_on_cache_status"
    t.index ["status"], name: "index_scrape_batches_on_status"
  end

  create_table "scrape_pages", force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "scrape_batch_id", null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "status", default: 0
    t.datetime "refresh_started_at"
    t.datetime "refresh_finished_at"
    t.integer "refresh_status", default: 0
    t.datetime "parse_started_at"
    t.datetime "parse_finished_at"
    t.integer "parse_status", default: 0
    t.datetime "index_started_at"
    t.datetime "index_finished_at"
    t.integer "index_status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index_status"], name: "index_scrape_pages_on_index_status"
    t.index ["page_id"], name: "index_scrape_pages_on_page_id"
    t.index ["parse_status"], name: "index_scrape_pages_on_parse_status"
    t.index ["refresh_status"], name: "index_scrape_pages_on_refresh_status"
    t.index ["scrape_batch_id", "page_id"], name: "index_scrape_pages_on_scrape_batch_id_and_page_id", unique: true
    t.index ["scrape_batch_id"], name: "index_scrape_pages_on_scrape_batch_id"
    t.index ["status"], name: "index_scrape_pages_on_status"
  end

  add_foreign_key "links", "pages", column: "from_id"
  add_foreign_key "links", "pages", column: "to_id"
  add_foreign_key "page_matches", "pages"
  add_foreign_key "page_matches", "queries"
  add_foreign_key "results", "pages"
  add_foreign_key "results", "queries"
  add_foreign_key "scrape_pages", "pages"
  add_foreign_key "scrape_pages", "scrape_batches"
end
