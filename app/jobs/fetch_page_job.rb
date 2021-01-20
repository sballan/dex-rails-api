class FetchPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :fetch

  # If we can't get the lock, retry at random time between now and 5 minutes from now
  rescue_from(ActiveLock::Errors::FailedToLockError) do
    retry_job(wait: rand(2.minutes))
  end

  def perform(page_id)
    page = Page.includes(:meta).find(page_id)

    FetchService::Client.fetch(page)
  end
end
