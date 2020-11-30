module Scrape
  class CreateScrapeBatch < Command::Base::Abstract
    def initialize(seed_urls, size=100, ttl=1.minute)
      super()
      @seed_urls = seed_urls
      @size = size
      @ttl = ttl
    end

    def run_proc
      scrape_batch = ScrapeBatch.create

      page_attributes = @seed_urls.map do |url|
        {
          url: url,
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        }
      end

      Page.insert_all(page_attributes, unique_by: :url)
      page_ids = Page.where(url: @seed_urls).pluck(:id)

      scrape_page_attributes = page_ids.map do |page_id|
        {
          scrape_batch_id: scrape_batch.id,
          page_id: page_id
        }
      end
      ScrapePage.insert_all!(scrape_page_attributes)

      scrape_batch.reload
      result.succeed!(scrape_batch)
    end
  end
end