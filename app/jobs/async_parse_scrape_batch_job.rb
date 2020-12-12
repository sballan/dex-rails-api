class AsyncParseScrapeBatchJob < ApplicationJob
  queue_as :parse

  def perform(scrape_batch_id, ttl=1.minute)
    scrape_batch = ScrapeBatch.find(scrape_batch_id)

    if scrape_batch.scrape_pages.refresh_success.parse_ready.count > 0
      Rails.logger.debug "[AsyncParseScrapeBatchJob] ScrapeBatch (#{scrape_batch.id}) has pages to parse"
      scrape_batch.parse_active!
      scrape_batch.parse_finished_at = nil
      scrape_batch.parse_active!
    else
      Rails.logger.info "[AsyncParseScrapeBatchJob] Nothing to parse!"
    end

    scrape_batch.save!
    scrape_batch.reload

    run_scrape_batch_command = Parse::ParseScrapeBatch.new(scrape_batch)
    run_scrape_batch_command.run_with_gc!

    scrape_batch.reload
    if scrape_batch.scrape_pages.refresh_ready.any?
      Rails.logger.debug "We just parsed, and have #{scrape_batch.scrape_pages.refresh_ready.count} to refresh"
      scrape_batch.refresh_active!
      scrape_batch.save!
      AsyncRefreshScrapeBatchJob.perform_later(scrape_batch_id, ttl)
    elsif scrape_batch.scrape_pages.refresh_success.parse_ready.any?
      Rails.logger.warn "We just parsed, but have more work to do! IMPLEMENT THIS"
    end

    if scrape_batch.scrape_pages.parse_success.index_ready.any?
      Rails.logger.info "We just parsed, and have #{scrape_batch.scrape_pages.parse_success.index_ready.count} to index"
      AsyncIndexScrapeBatchJob.perform_later(scrape_batch.id, ttl)
    elsif scrape_batch.started_at + ttl > Time.now
      Rails.logger.info "TTL has expired, let's do one last index"
      AsyncIndexScrapeBatchJob.perform_later(scrape_batch.id, ttl)
    else
      Rails.logger.warn "We just parsed, our ttl isn't over, but we have nothing to index...HELP"
    end
  end
end