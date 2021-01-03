class FetchPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :crawl

  def perform(page_id, depth)
    page = Page.find(page_id)

    FetchService::Client.soft_fetch(page)

    return unless depth > 0

    batch.open do
      page.links_to.each do |link|
        FetchPageJob.perform_later(link.to_id, depth - 1)
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

    batch.open do
      RankPageJob.perform_later(page.id, 1000)
    end
  end
end
