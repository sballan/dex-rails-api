class CrawlPageCallbackJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :crawl

  def perform(page_id, depth)
    # Count pages successfully fetched, and determine whether the crawl was a success

    page_crawled = Page.includes(:meta).find(page_id)

    links_crawled_count = page_crawled.pages_linked_to.by_meta(fetch_status: :success).count.to_f
    links_total_count = page_crawled.pages_linked_to.count.to_f
    success_ratio = links_crawled_count / links_total_count

    if success_ratio > 0.5
      Rails.logger.info "Crawl success ratio for Page(#{page_id}) is #{success_ratio}, which is successful"
      page_crawled.meta.update(crawl_status: :success, rank_status: :ready)
    else
      Rails.logger.info "Crawl success ratio for Page(#{page_id}) is #{success_ratio}, which is unsuccessful"
      page_crawled.meta.update(crawl_status: :failure)
    end
  end
end
