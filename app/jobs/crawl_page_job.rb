class CrawlPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :crawl

  def perform(page_id, depth)
    page = Page.find(page_id)

    FetchService::Client.soft_fetch(page)
    return unless depth > 0

    links = FetchService::Client.links_for_page(page)

    batch.open do
      links.each do |link|
        RankPageJob.perform_later(link.to_id, depth - 1)
      end
    end

    # index_batch = JobBatch::Batch.create
    batch.open do
      IndexPageFragmentJob.perform_later(page_id, 'title')

      if depth > 2
        IndexPageFragmentJob.perform_later(page_id, 'links')
      end

      if depth > 4
        IndexPageFragmentJob.perform_later(page_id, 'headers')
      end
    end
  end
end
