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

ActiveRecord::Schema.define(version: 2020_11_08_211805) do

  create_table "links", force: :cascade do |t|
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.index ["from_id"], name: "index_links_on_from_id"
    t.index ["to_id"], name: "index_links_on_to_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "url"
    t.index ["url"], name: "index_pages_on_url", unique: true
  end

  add_foreign_key "links", "pages", column: "from_id"
  add_foreign_key "links", "pages", column: "to_id"
end
