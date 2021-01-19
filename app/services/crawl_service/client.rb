module CrawlService
  MAX_CRAWL_PAGES = ENV.fetch("MAX_CRAWL_PAGES", 1).to_i.seconds
  MAX_CRAWL_TIME = ENV.fetch("MAX_CRAWL_TIME", 6.hours).to_i.seconds

  module Client
    extend self

    def tick(&block)
      # Update old PageMeta to have failed status. The assumption is that pages crawling longer than
      # the MAX_CRAWL_TIME are actually not running.
      # TODO: consider tracking thread ids in a way that would let us kill long running crawls etc.
      PageMeta.where(crawl_status: :active, crawl_started_at: DateTime.new(0)..MAX_CRAWL_TIME.ago)
          .update_all(crawl_status: :failure, crawl_finished_at: DateTime.now.utc)

      # Now that we've marked failures, let's count real active pages
      num_active_pages = PageMeta.crawl_active.count

      # Now let's collect pages to pass to the block
      page_ids = []
      if num_active_pages >= MAX_CRAWL_PAGES
        Rails.logger.error "We're at crawl capacity with #{num_active_pages} pages being crawled"
      else
        # Update all pages for active Sites that have crawl_status: :ready, which means they have already been fetched
        num_additional_pages = MAX_CRAWL_PAGES - num_active_pages

        # can this be done in one query?
        meta = PageMeta.crawl_ready.limit(num_additional_pages)
        meta.update(crawl_status: :active, crawl_started_at: DateTime.now.utc)
        page_ids.concat(meta.pluck(:id))
      end

      Rails.logger.info "Collected Page ids for tick"
      block.call(page_ids)
    end
  end
end