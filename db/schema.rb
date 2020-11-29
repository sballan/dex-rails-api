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

ActiveRecord::Schema.define(version: 2020_11_29_170134) do

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

  create_table "pages", force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.datetime "download_success"
    t.datetime "download_failure"
    t.datetime "download_invalid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.datetime "start"
    t.datetime "finish"
    t.integer "status", default: 0
    t.datetime "refresh_start"
    t.datetime "refresh_finish"
    t.integer "refresh_status", default: 0
    t.index ["refresh_status"], name: "index_scrape_batches_on_refresh_status"
    t.index ["status"], name: "index_scrape_batches_on_status"
  end

  create_table "scrape_pages", force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "scrape_batch_id", null: false
    t.datetime "start"
    t.datetime "finish"
    t.integer "status", default: 0
    t.datetime "refresh_start"
    t.datetime "refresh_finish"
    t.integer "refresh_status", default: 0
    t.index ["page_id"], name: "index_scrape_pages_on_page_id"
    t.index ["refresh_status"], name: "index_scrape_pages_on_refresh_status"
    t.index ["scrape_batch_id"], name: "index_scrape_pages_on_scrape_batch_id"
    t.index ["status"], name: "index_scrape_pages_on_status"
  end

  add_foreign_key "links", "pages", column: "from_id"
  add_foreign_key "links", "pages", column: "to_id"
  add_foreign_key "results", "pages"
  add_foreign_key "results", "queries"
  add_foreign_key "scrape_pages", "pages"
  add_foreign_key "scrape_pages", "scrape_batches"
end
