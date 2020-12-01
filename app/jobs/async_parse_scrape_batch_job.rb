class AsyncParseScrapeBatchJob < ApplicationJob
  queue_as :parse

  def perform(scrape_batch_id)
    scrape_batch = ScrapeBatch.find(scrape_batch_id)
    scrape_batch.parse_active! if scrape_batch.parse_ready?

    run_scrape_batch_command = Parse::ParseScrapeBatch.new(scrape_batch)
    run_scrape_batch_command.run_with_gc!
  end
end