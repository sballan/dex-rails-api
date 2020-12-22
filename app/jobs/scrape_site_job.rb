class ScrapeSiteJob < ApplicationJob
  queue_as :default

  def perform(site_id)
    site = Site.find(site_id)
    # Our cheap version of a lock on this page.
    page = nil
    Page.transaction do
      page = Page.lock.refresh_ready_by_site(site).first
      if page.nil?
        Rails.logger.info "No pages to refresh"
        return
      end

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
