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
    end

    add_index :scrape_pages, :status
    add_index :scrape_pages, :refresh_status
  end
end
