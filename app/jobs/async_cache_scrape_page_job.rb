class AsyncCacheScrapePageJob < ApplicationJob
  queue_as :cache

  def perform(scrape_page_id)
    scrape_page = ScrapePage.find scrape_page_id
    scrape_page.cache_started_at = DateTime.now.utc
    scrape_page.cache_active!

    command = Cache::CacheScrapePage.new scrape_page
    command.run_with_gc # TODO: need a better convention here.  We catch all errors without the `!`

    if command.success?
      scrape_page.cache_success!
      scrape_page.cache_finished_at = DateTime.now.utc
    else
      scrape_page.cache_failure!
      scrape_page.cache_finished_at = DateTime.now.utc
    end

    scrape_page.save!
  end

end