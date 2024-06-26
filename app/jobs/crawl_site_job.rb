class CrawlSiteJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :crawl

  def perform(site_id, depth, limit = 100)
    site = Site.find(site_id)
    page_ids = Page.by_site(site).limit(limit).pluck(:id)

    crawl_batch = JobBatch::Batch.create(nil, {
      callback_klass: "BatchCacheQueriesJob",
      callback_args: []
    })

    crawl_batch.open do
      page_ids.each do |page_id|
        FetchPageJob.perform_later(page_id, depth)
      end
    end
  end
end
