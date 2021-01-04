class FetchPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :fetch

  def perform(page_id, depth)
    page = Page.includes(:meta).find(page_id)

    unless page.meta.present?
      Rails.logger.info "No metadata for Page(#{page_id}); inserting metadata record"
      page.update(meta_attributes: {})
    end

    if page.meta.fetch_success? || page.meta.fetch_dead?
      Rails.logger.info "Not fetching Page(#{page_id}), since fetch status is #{page.meta.fetch_status}"
      return
    end

    FetchService::Client.fetch(page)

    return unless depth > 0

    batch.open do
      CrawlPageJob.perform_later(link.to_id, depth - 1)
    end

    # index_batch = JobBatch::Batch.create
    batch.open do
      IndexPageFragmentJob.perform_later(page_id, 'title')

      if depth > 1
        IndexPageFragmentJob.perform_later(page_id, 'links')
      end

      if depth > 2
        IndexPageFragmentJob.perform_later(page_id, 'headers')
      end
    end

    batch.open do
      RankPageJob.perform_later(page.id, 2500)
    end
  end
end
