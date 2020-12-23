class SiteParseNextPageJob < ApplicationJob
  queue_as :refresh

  def perform(site_id)
    site = Site.find(site_id)
    # Our cheap version of a lock on this page.
    page = nil
    Page.transaction do
      page = Page.lock.by_site(site).parse_ready.first
      if page.nil?
        SiteParseNextPageJob.set(wait: 1.minute).perform_later(site.id)
        Rails.logger.info "No pages to parse.  Try again in 1 minute."
        return
      else
        page.parse_status = :active
        page.parse_started_at = DateTime.now.utc
        page.save!
      end
    end

    ParseService::Client.parse_page(page)

    page.index_ready!

    if Page.by_site(site).parse_ready.any?
      SiteParseNextPageJob.perform_later(site.id)
    else
      SiteParseNextPageJob.set(wait: 1.hour).perform_later(site.id)
    end
  end
end
