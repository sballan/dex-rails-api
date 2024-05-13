class OldSiteScraperJob < ApplicationJob
  queue_as :default

  def perform(site_id = nil, depth = 4)
    site_id ||= Site.first.id
    site = Site.find(site_id)

    scraper = OldSiteScraper.new(site)
    scraper.scrape_to_depth(depth)
  end
end
