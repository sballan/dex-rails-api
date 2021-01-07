class AddCrawlStatusToPageMeta < ActiveRecord::Migration[6.0]
  def change
    add_column :page_meta, :crawl_status, :integer, default: 0
    add_column :page_meta, :crawl_started_at, :datetime
    add_column :page_meta, :crawl_finished_at, :datetime

    add_index :page_meta, :crawl_status
  end
end
