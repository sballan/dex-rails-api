class IndexPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :index

  def perform(page_id)
    page_to_index = Page.includes(:meta).find(page_id)

    # Cannot index unless we have meta
    unless page_to_index.meta.present?
      raise "No metadata for Page(#{page_id}); cannot index this page"
    end

    # We can only index pages if they are ready or failed
    unless page_to_index.meta.index_ready? || !page.meta.index_failure?
      Rails.logger.warn "Not indexing Page(#{page_id}), since index status is #{page_to_index.meta.index_status}"
      return
    end

    # If we're scraping this Site, do next deepest indexing
    matching_host = Site.for_page(page).where(scrape_active: true)
    if matching_host.present?
      IndexPageFragmentJob.perform_later(page_id, 'headers')
    end


    linked_to_hosts = page_to_index.pages_linked_to.pluck(:url).map {|url| URI(url).host }
    linked_from_hosts = page_to_index.pages_linked_from.pluck(:url).map {|url| URI(url).host }


  end
end
