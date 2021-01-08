class ClockJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Clock Tick started"

    if Page.by_meta(crawl_status: :active).count > 1
      Rails.logger.error "We can currently only crawl 1 page at a time"
    end

    page_crawling = Page.includes(:meta).by_meta(crawl_status: :active).first
    if page_crawling && page_crawling.meta.crawl_started_at && (page_crawling.meta.crawl_started_at < 2.hour.ago)
      Rails.logger.warn "Page(#{page_crawling.id}) has been crawling for more than 2 hours"
      page_crawling.meta.update!(crawl_status: :failure)
    end

    # Update all pages for active Sites that have crawl_status: :ready, which means they have already been fetched
    page_to_crawl = Page.by_meta(crawl_status: :ready).first
    # Queue crawl job
    if page_to_crawl
      Rails.logger.info "Queueing for crawl: #{page_to_crawl.id}"
      CrawlPageJob.perform_later(page_to_crawl.id)
    else
      Rails.logger.info "No pages are crawl_ready"
    end
    # When a page has finished being crawled, it's callback will mark it as rank_ready

    # Fetch 1 page for SCRAPE_ACTIVE sites that are index_ready
    page_to_index = Page.by_meta(index_status: :ready).first
    # Queue index job
    if page_to_index
      Rails.logger.info "Queueing for index: #{page_to_crawl.id}"
      IndexPageJob.perform_later(page_to_index.id)
    else
      Rails.logger.info "No pages are index_ready"
    end

    # Fetch 1 page for SCRAPE_ACTIVE sites that are rank_ready
    page_to_rank = Page.by_meta(rank_status: :ready).first
    # Queue rank job
    if page_to_rank
      Rails.logger.info "Queueing for rank: #{page_to_crawl.id}"
      RankPageJob.perform_later(page_to_rank.id)
    else
      Rails.logger.info "No pages are rank_ready"
    end


    Rails.logger.info "Clock Tick finished"
  end
end
