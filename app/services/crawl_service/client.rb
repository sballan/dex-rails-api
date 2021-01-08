module CrawlService
  module Client
    extend self

    def tick(&block)
      # TODO: Remove this statement, which is useful in testing.
      if Page.by_meta(crawl_status: :active).count > 1
        Rails.logger.error "We can currently only crawl 1 page at a time"
      end

      # Mark pages as failure if they've been crawling for more than 2 hours
      page_crawling = Page.includes(:meta).by_meta(crawl_status: :active).first
      if page_crawling && page_crawling.meta.crawl_started_at && (page_crawling.meta.crawl_started_at < 2.hour.ago)
        Rails.logger.warn "Page(#{page_crawling.id}) has been crawling for more than 2 hours"
        page_crawling.meta.update!(crawl_status: :failure)
      end

      page_ids = []


      # Update all pages for active Sites that have crawl_status: :ready, which means they have already been fetched
      # We limit to 5, since we can't ever possibly crawl 5 pages in less than 10 minutes...right? With other jobs
      # happening too? Maybe we'll raise it one day.
      page_ids.concat Page.by_meta(crawl_status: :ready).limit(5).pluck(:id)

      Rails.logger.info "Collected Page ids for tick"
      block.call(page_ids)
    end
  end
end