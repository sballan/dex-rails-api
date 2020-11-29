class CreateScrapeBatch < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_batches do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :status, default: 0 # For enum

      t.datetime :refresh_started_at
      t.datetime :refresh_finished_at
      t.integer :refresh_status, default: 0 # For enum
    end

    add_index :scrape_batches, :status
    add_index :scrape_batches, :refresh_status
  end
end
