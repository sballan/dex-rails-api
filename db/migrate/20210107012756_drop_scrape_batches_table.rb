class DropScrapeBatchesTable < ActiveRecord::Migration[6.0]
  def change
    remove_index :scrape_batches, :status
    remove_index :scrape_batches, :cache_status

    drop_table :scrape_batches do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :status, default: 0 # For enum

      t.datetime :cache_started_at
      t.datetime :cache_finished_at
      t.integer :cache_status, default: 0 # For enum

      t.timestamps
    end
  end
end
