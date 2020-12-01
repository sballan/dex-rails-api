class AsyncCreateScrapeBatchJob < ApplicationJob
  queue_as :default

  def perform(seed_urls, ttl=10.minutes)
    start_time = Time.now.to_i
    end_time = start_time + ttl.to_i

    create_scrape_batch_command = Scrape::CreateScrapeBatch.new(seed_urls)

    create_scrape_batch_command.run!
    scrape_batch = create_scrape_batch_command.payload

    AsyncRefreshScrapeBatchJob.perform_later scrape_batch.id, ttl
  end
end