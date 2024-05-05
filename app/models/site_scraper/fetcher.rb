class SiteScraper::Fetcher
  class FetcherError < StandardError
  end

  class PermanentFailure < FetcherError
  end

  class TemporaryFailure < FetcherError
  end

  DOWNLOAD_LOCK_TIME = 60.seconds

  attr_reader :page

  def initialize(page)
    @page = page
  end

  def fetch
    extract_html
  end

  def extract_html
    nokogiri_doc = mechanize_page.parser
    nokogiri_doc.xpath("//script").remove
    nokogiri_doc.xpath("//style").remove
    nokogiri_doc.to_html.force_encoding("UTF-8")
  end

  def mechanize_page
    mechanize_page = download_page

    raise FetcherError("Page is nil") if @mechanize_page.nil?
    raise FetcherError("Only html pages are supported") unless mechanize_page.is_a?(Mechanize::Page)

    mechanize_page
  rescue Mechanize::RobotsDisallowedError => e
    raise PermanentFailure("Robots cannot scrape this page", e)
  rescue Mechanize::ResponseCodeError => e
    raise TemporaryFailure("Bad response code", e)
  end

  def download_page
    mechanize_agent = Mechanize.new
    mechanize_agent.history.max_size = 1 # default is 50
    mechanize_agent.robots = true
    host = URI(@url).host
    page_file = nil

    ActiveLock::Lock.with_lock("Host/#{host}", nil, ttl: DOWNLOAD_LOCK_TIME) do
      page_file = mechanize_agent.get(@url)
      sleep 2 # does this give some extension time to finish releaseing memory or something?
    end

    page_file
  end
end
