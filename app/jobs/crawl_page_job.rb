class CrawlPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :crawl

  def perform(page_id)
    page_to_crawl = Page.includes(:meta).find(page_id)

    # Cannot crawl unless we have meta
    unless page_to_crawl.meta.present?
      raise "No metadata for Page(#{page_id}); cannot crawl this page"
    end

    # Mark any existing but not successful/dead PageMeta for these links as active
    PageMeta.where(
      fetch_status: %i[new ready failed],
      page_id: page_to_crawl.pages_linked_to.pluck(:id)
    ).update_all(
      fetch_status: :active
    )

    crawl_batch = JobBatch::Batch.create(
      nil,
      callback_klass: 'CrawlPageCallbackJob',
      callback_args: [page_to_crawl.id]
    )

    crawl_batch.open do
      page_to_crawl.pages_linked_to.includes(:meta).find_each do |page|
        # Skip if we already got it or it's not valid.
        # TODO: Do this with a join
        next if page.meta.present? && (page.meta.fetch_success? || page.meta.fetch_dead?)

        FetchPageJob.perform_later(page.id)
      end
    end
  end
end
