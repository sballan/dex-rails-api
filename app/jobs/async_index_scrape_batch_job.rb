class AsyncIndexScrapeBatchJob < ApplicationJob
  queue_as :index

  def perform(scrape_page_id)
    scrape_page = ScrapeBatch.find scrape_page_id
    scrape_page.index_started_at = DateTime.now.utc
    scrape_page.index_active!

    command = Index::IndexScrapeBatch.new scrape_page
    command.run_with_gc # TODO: need a better convention here.  We catch all errors without the `!`

    scrape_page.save!
  end

end