class AsyncIndexScrapePageJob < ApplicationJob
  queue_as :index

  def perform(scrape_page_id)
    scrape_page = ScrapePage.find scrape_page_id
    scrape_page.index_started_at = DateTime.now.utc
    scrape_page.index_active!

    command = Cache::CacheScrapePage.new scrape_page
    command.run_with_gc # TODO: need a better convention here.  We catch all errors without the `!`

    if command.success?
      scrape_page.index_success!
      scrape_page.index_finished_at = DateTime.now.utc
    else
      scrape_page.index_failure!
      scrape_page.index_finished_at = DateTime.now.utc
    end

    scrape_page.save!
  end

end