class SiteScraper::Linker
  class LinkerError < StandardError
  end

  class PermanentFailure < LinkerError
  end

  class TemporaryFailure < LinkerError
  end

  private attr_reader :parser

  def initialize(page, parser)
    @page = page
    @parser = parser
    @links_by_url = nil
  end

  def link
    insert_link_pages(insert_link_pages_attributes)
    update_links_by_url_with_to_ids
    insert_links(links_by_url.values)
  end

  def insert_links(attributes)
    Link.insert_all(attributes, unique_by: :index_links_on_to_id_and_from_id_and_text)
  end

  def insert_link_pages(attributes)
    Page.insert_all(attributes, unique_by: :url)
  end

  def insert_link_pages_attributes
    links_by_url.map do |url, link|
      host = begin
        URI(url).host
      rescue
        nil
      end

      {url: url, host: host}
    end
  end

  def update_links_by_url_with_to_ids
    # Once pages have been inserted, we can get all the ids and urls we need in a single query
    Page.where(url: links_by_url.keys).in_batches do |pages|
      pages.pluck(:id, :url).each do |page|
        @links_by_url[page.second][:to_id] = page.first
      end
    end
  end

  def links_by_url
    return links_by_url unless links_by_url.nil?

    @links_by_url = {}

    parser.parsed_page[:links].each do |link|
      @links_by_url[link[:url]] = link
    end

    @links_by_url.each do |url, link|
      link.delete(:url)
      link[:text] = link[:text] || ""
      link[:from_id] = @page.id
    end
  end
end
