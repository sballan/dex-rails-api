class CrawlPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :crawl

  def perform(page_id, depth)
    page = Page.find(page_id)

    batch.open do
      page.links_to.includes(:to).each do |link|
        next if link.to.meta.present? && (link.to.meta.fetch_success? || link.to.meta.fetch_dead?)

        FetchPageJob.perform_later(link.to_id, depth)
      end
    end
  end
end
