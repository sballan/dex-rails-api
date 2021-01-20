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

    pages_to_fetch = []
    page_to_crawl.pages_linked_to.includes(:meta).find_each do |page|
      # Skip if we already got it or it's not valid.
      # TODO: Do this with a join
      next if page.meta.present? && (page.meta.fetch_success? || page.meta.fetch_dead? || page.meta.fetch_active?)

      page.update!(meta_attributes: {
        fetch_status: :active,
        fetch_started_at: DateTime.now.utc,
        fetch_finished_at: nil
      })

      pages_to_fetch << page
    end

    return if pages_to_fetch.blank?

    # Sort so that hosts are spread out
    pages_by_host = pages_to_fetch.group_by(&:host).values
    pages_by_host = pages_by_host[0].zip(*pages_by_host[1..]).flatten.compact.reverse

    crawl_batch.open do
      pages_by_host.each do |page|
        FetchPageJob.perform_later(page.id)
      end
    end
  end
end
