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

ActiveRecord::Schema[7.1].define(version: 2024_05_18_232519) do
  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "links", force: :cascade do |t|
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.string "text"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_page_matches_on_page_id"
    t.index ["query_id", "page_id", "kind", "full", "distance", "length"], name: "index_page_matches_on_query_page_kind_full_distance_length", unique: true
    t.index ["query_id"], name: "index_page_matches_on_query_id"
  end

  create_table "page_meta", force: :cascade do |t|
    t.integer "page_id", null: false
    t.datetime "fetch_started_at", precision: nil
    t.datetime "fetch_finished_at", precision: nil
    t.datetime "index_started_at", precision: nil
    t.datetime "index_finished_at", precision: nil
    t.datetime "rank_started_at", precision: nil
    t.datetime "rank_finished_at", precision: nil
    t.integer "fetch_status", default: 0
    t.integer "index_status", default: 0
    t.integer "rank_status", default: 0
    t.integer "crawl_status", default: 0
    t.datetime "crawl_started_at", precision: nil
    t.datetime "crawl_finished_at", precision: nil
    t.boolean "indexed_title", default: false
    t.boolean "indexed_links", default: false
    t.boolean "indexed_headers", default: false
    t.index ["crawl_status"], name: "index_page_meta_on_crawl_status"
    t.index ["fetch_status"], name: "index_page_meta_on_fetch_status"
    t.index ["index_status"], name: "index_page_meta_on_index_status"
    t.index ["page_id"], name: "index_page_meta_on_page_id", unique: true
    t.index ["rank_status"], name: "index_page_meta_on_rank_status"
  end

  create_table "pages", force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.decimal "rank"
    t.string "host"
    t.integer "document_id"
    t.index ["document_id"], name: "index_pages_on_document_id"
    t.index ["rank"], name: "index_pages_on_rank"
    t.index ["url"], name: "index_pages_on_url", unique: true
  end

  create_table "postings", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "document_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_postings_on_document_id"
    t.index ["term_id", "document_id", "position"], name: "index_postings_on_term_id_and_document_id_and_position", unique: true
    t.index ["term_id"], name: "index_postings_on_term_id"
  end

  create_table "queries", force: :cascade do |t|
    t.string "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cached_at", precision: nil, default: "0000-01-01 00:00:00"
    t.index ["text"], name: "index_queries_on_text", unique: true
  end

  create_table "sites", force: :cascade do |t|
    t.string "home_url", null: false
    t.string "host", null: false
    t.boolean "scrape_active", default: false
    t.string "refresh_job_id"
    t.datetime "refresh_job_started_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["home_url"], name: "index_sites_on_home_url", unique: true
    t.index ["host"], name: "index_sites_on_host", unique: true
  end

  create_table "terms", force: :cascade do |t|
    t.string "term", null: false
    t.index ["term"], name: "index_terms_on_term", unique: true
  end

  add_foreign_key "links", "pages", column: "from_id"
  add_foreign_key "links", "pages", column: "to_id"
  add_foreign_key "page_matches", "pages"
  add_foreign_key "page_matches", "queries"
  add_foreign_key "pages", "documents"
  add_foreign_key "postings", "documents", on_delete: :cascade
  add_foreign_key "postings", "terms", on_delete: :cascade
end
