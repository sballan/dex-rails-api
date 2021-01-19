class FetchPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :fetch

  # If we can't get the lock, retry at random time between now and 5 minutes from now
  rescue_from(ActiveLock::Errors::FailedToLockError) do
    retry_job(wait: rand(5.minutes))
  end

  def perform(page_id)
    page = Page.includes(:meta).find(page_id)

    Rails.logger.debug "Inserting metadata record for Page(#{page_id}" unless page.meta.present?

    # Will create the meta if it doesn't exist
    page.update(meta_attributes: { fetch_status: :active })

    FetchService::Client.fetch(page)
  end
end
