class ScrapeBatchJob < ApplicationJob
  queue_as :scrape

  def perform(seed_urls, size=10, ttl=5.minutes)
    create_scrape_batch_command = Scrape::CreateScrapeBatch.new(seed_urls, size, ttl)

    create_scrape_batch_command.run!
    scrape_batch = create_scrape_batch_command.payload

    run_scrape_batch_command = Scrape::RunScrapeBatch.new(scrape_batch)
    run_scrape_batch_command.run_with_gc!
  end
end
