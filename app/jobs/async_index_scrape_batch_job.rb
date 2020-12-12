class AsyncIndexScrapeBatchJob < ApplicationJob
  queue_as :index

  def perform(scrape_batch_id, ttl= 1.minute)
    scrape_batch = ScrapeBatch.find scrape_batch_id
    command = Index::IndexScrapeBatch.new scrape_batch
    command.run_with_gc!

    pages_to_parse = scrape_batch.scrape_pages.refresh_success.parse_ready.any?
    pages_to_index = scrape_batch.scrape_pages.parse_success.index_ready.any?

    if pages_to_parse || pages_to_index || (scrape_batch.started_at + ttl > Time.now)
      Rails.logger.info "We just indexed, but still have pages to parse or index, or ttl has not expired.   Not going to cache yet."
    else
      Rails.logger.info "We just indexed, and have nothing left to index, and ttl had expired. Let's cache."
      AsyncCacheScrapeBatchJob.perform_later(scrape_batch.id)
    end
  end

end