class SiteIndexNextPageJob < ApplicationJob
  queue_as :index

  def perform(site_id)
    site = Site.find(site_id)

    unless site.scrape_active
      Rails.logger.info "Site(#{site.id}) is not scrape_active. Not indexing."
      return
    end

    # Our cheap version of a lock on this page.
    page = nil
    Page.transaction do
      page = Page.lock.by_site(site).index_ready.first
      if page.nil?
        SiteIndexNextPageJob.set(wait: 10.seconds).perform_later(site.id)
        Rails.logger.info "No pages to index. Trying again in 10 seconds."
        return
      else
        page.index_status = :active
        page.index_started_at = DateTime.now.utc
        page.save!
      end
    end

    IndexService::Client.index_page(page, 3)

    page.cache_ready!

    if Page.by_site(site).index_ready.any?
      SiteIndexNextPageJob.perform_later(site.id)
    else
      SiteIndexNextPageJob.set(wait: 5.minutes).perform_later(site.id)
    end
  end
end
