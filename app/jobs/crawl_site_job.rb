class CrawlSiteJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :default

  def perform(site_id, depth)
    site = Site.find(site_id)
    page_ids = Page.by_site(site).pluck(:id)

    batch.open do
      page_ids.each do |page_id|
        FetchPageJob.perform_later(page_id, depth)
      end
    end
  end
end
