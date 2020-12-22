class RefreshNextPageForSiteJob < ApplicationJob
  queue_as :refresh

  def perform(site_id)
    site = Site.find(site_id)

    # Our cheap version of a lock on this page.
    page = nil
    Page.transaction do
      page = Page.lock.refresh_ready_by_site(site).first
      page.refresh_status = :active
      page.refresh_started_at = DateTime.now.utc
      page.save!
    end

    RefreshService::Client.refresh_page(page)

    if Page.refresh_ready_by_site(site).any?
      RefreshNextPageForSiteJob.perform_later(site.id)
    end
  end
end
