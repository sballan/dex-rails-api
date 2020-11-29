class CreateScrapePage < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_pages do |t|
      t.references :page, null: false, foreign_key: true
      t.datetime :refresh_start
      t.datetime :refresh_finish
      t.integer :refresh_status, default: 0 # For enum
    end

    add_index :scrape_pages, :refresh_status
  end
end
