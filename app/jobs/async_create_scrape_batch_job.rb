class AsyncCreateScrapeBatchJob < ApplicationJob
  queue_as :default

  def perform(seed_urls, ttl=10.minutes)
    create_scrape_batch_command = Scrape::CreateScrapeBatch.new(seed_urls)

    create_scrape_batch_command.run!
    scrape_batch = create_scrape_batch_command.payload

    Rails.logger.info "Created new ScrapeBatch (#{scrape_batch.id})"

    AsyncRefreshScrapeBatchJob.perform_later scrape_batch.id, ttl
  end
end