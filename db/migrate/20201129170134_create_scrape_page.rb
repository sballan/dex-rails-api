class CreateScrapePage < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_pages do |t|
      t.references :page, null: false, foreign_key: true
      t.references :scrape_batch, null: false, foreign_key: true

      t.datetime :started_at
      t.datetime :finished_at
      t.integer :status, default: 0 # For enum

      t.datetime :refresh_started_at
      t.datetime :refresh_finished_at
      t.integer :refresh_status, default: 0 # For enum

      t.datetime :parse_started_at
      t.datetime :parse_finished_at
      t.integer :parse_status, default: 0 # For enum

      t.datetime :index_started_at
      t.datetime :index_finished_at
      t.integer :index_status, default: 0 # For enum

      t.timestamps
    end

    add_index :scrape_pages, :status
    add_index :scrape_pages, :refresh_status
    add_index :scrape_pages, :parse_status
    add_index :scrape_pages, :index_status
    add_index :scrape_pages, %i[scrape_batch_id page_id], unique: true
  end
end
