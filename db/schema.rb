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

ActiveRecord::Schema.define(version: 2020_11_08_234615) do

  create_table "links", force: :cascade do |t|
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["from_id"], name: "index_links_on_from_id"
    t.index ["to_id"], name: "index_links_on_to_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["url"], name: "index_pages_on_url", unique: true
  end

  create_table "queries", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["text"], name: "index_queries_on_text", unique: true
  end

  create_table "results", force: :cascade do |t|
    t.string "kind"
    t.integer "query_id", null: false
    t.integer "page_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["page_id"], name: "index_results_on_page_id"
    t.index ["query_id"], name: "index_results_on_query_id"
  end

  add_foreign_key "links", "pages", column: "from_id"
  add_foreign_key "links", "pages", column: "to_id"
  add_foreign_key "results", "pages"
  add_foreign_key "results", "queries"
end
