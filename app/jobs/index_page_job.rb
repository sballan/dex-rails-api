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
    unless page_to_index.meta.index_ready? || !page_to_index.meta.index_failure?
      Rails.logger.warn "Not indexing Page(#{page_id}), since index status is #{page_to_index.meta.index_status}"
      return
    end

    fields_to_index = {
      title: false,
      links: false,
      headers: false
    }

    # If we're scraping this Site, do next deepest indexing
    matching_site = Site.find_by_host(URI(page_to_index.url).host)
    if matching_site.present? && matching_site.scrape_active?
      # If we're scraping this Site, we get title and links
      fields_to_index[:title] = true
      fields_to_index[:links] = true

      # If home page links to us, also grab headers
      home_page = Page.includes(:links_to, :links_from).find_by_url(matching_site.home_url)
      if home_page.links_to.include?(page_to_index.id) || home_page.links_from.include?(page_to_index.id)
        fields_to_index[:headers] = true
      end
    else
      # Otherwise, see if we're 1 link away from an active Site, and if so grab the title
      linked_to_hosts = page_to_index.pages_linked_to.pluck(:url).map {|url| URI(url).host }
      linked_from_hosts = page_to_index.pages_linked_from.pluck(:url).map {|url| URI(url).host }
      connected_sites = Site.where(scrape_active: true, host: [linked_to_hosts, linked_from_hosts].flatten)

      if connected_sites.any?
        fields_to_index[:title] = true
      end
    end

    index_batch = JobBatch::Batch.create(
      nil,
      callback_klass: 'IndexPageCallbackJob',
      callback_args: [page_to_index.id, fields_to_index]
    )

    index_batch.open do
      fields_to_index.each do |key, _value|
        IndexPageFragmentJob.perform_later(page_to_index.id, key.to_s) if fields_to_index[key]
      end
    end
  end
end
