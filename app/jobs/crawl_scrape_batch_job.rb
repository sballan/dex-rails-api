class CrawlScrapeBatchJob < ApplicationJob
  queue_as :scrape

  def perform(seed_urls, ttl=5.minutes)
    create_scrape_batch_command = Scrape::CreateScrapeBatch.new(seed_urls, ttl)

    create_scrape_batch_command.run!
    scrape_batch = create_scrape_batch_command.payload

    run_scrape_batch_command = Scrape::CrawlScrapeBatch.new(scrape_batch, ttl)
    run_scrape_batch_command.run_with_gc!
  end
end
