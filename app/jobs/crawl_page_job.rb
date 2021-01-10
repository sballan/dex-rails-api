class CrawlPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :crawl

  def perform(page_id)
    page_to_crawl = Page.includes(:meta).find(page_id)

    # Cannot crawl unless we have meta
    unless page_to_crawl.meta.present?
      raise "No metadata for Page(#{page_id}); cannot crawl this page"
    end

    # We can only crawl pages if they are ready or failed
    unless page_to_crawl.meta.crawl_ready? || page_to_crawl.meta.crawl_failure?
      Rails.logger.warn "Not crawling Page(#{page_id}), since crawl status is #{page_to_crawl.meta.crawl_status}"
      return
    end

    # Mark crawl as active
    page_to_crawl.meta.update!(
      crawl_started_at: DateTime.now.utc,
      crawl_status: :active
    )

    # Mark any new PageMeta for these links as ready
    PageMeta.where(
      fetch_status: :new,
      page_id: page_to_crawl.pages_linked_to.pluck(:id)
    ).update_all(
      fetch_status: :ready
    )

    crawl_batch = JobBatch::Batch.create(
      nil,
      callback_klass: 'CrawlPageCallbackJob',
      callback_args: [page_to_crawl.id]
    )

    crawl_batch.open do
      page_to_crawl.pages_linked_to.includes(:meta).find_each do |page|
        # Skip if we already got it or it's not valid
        next if page.meta.present? && (page.meta.fetch_success? || page.meta.fetch_dead?)

        FetchPageJob.perform_later(page.id)
      end
    end
  end
end
