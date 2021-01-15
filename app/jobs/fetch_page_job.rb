class FetchPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :fetch

  # If we can't get the lock, retry at random time between now and 5 minutes from now
  rescue_from(ActiveLock::Errors::FailedToLockError) do
    retry_job(wait: rand(10.minutes))
  end

  def perform(page_id)
    page = Page.includes(:meta).find(page_id)

    unless page.meta.present?
      Rails.logger.info "No metadata for Page(#{page_id}); inserting metadata record"
      page.update(meta_attributes: { fetch_status: :ready })
    end

    # We can only fetch fetch pages if they are ready or failed
    if page.meta.fetch_ready? || page.meta.fetch_failure?
      FetchService::Client.fetch(page)
    else
      Rails.logger.warn "Not fetching Page(#{page_id}), since fetch status is #{page.meta.fetch_status}"
    end
  end
end
