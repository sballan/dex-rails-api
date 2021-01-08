class ClockJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Clock Tick started"

    # To start off, we synchronously fetch all unsuccessful home pages for our sites
    FetchService::Client.tick do |page_ids|
      if page_ids.present?
        Page.where(id: page_ids).find_each do |page|
          FetchService::Client.fetch(page)
        end
      else
        Rails.logger.info "No Sites have a need for fetching"
      end
    end

    CrawlService::Client.tick do |page_ids|
      if page_ids.present?
        Rails.logger.info "Queueing for crawl: Page(#{page_ids.first})"
        CrawlPageJob.perform_later(page_ids.first)
      else
        Rails.logger.info "No pages are crawl_ready"
      end
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
