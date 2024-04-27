class SiteScraper
  attr_reader :site

  def initialize(site)
    @site = site
    @home_page = site.fetch_home_page
  end

  def scrape_to_depth(max_depth = 3)
    total_pages_scraped = 0
    current_depth = 0
    current_pages = [@home_page]

    while current_depth < max_depth
      begin
        current_depth += 1
        next_pages = []

        current_pages.each do |page|
          Rails.logger.info "Scraping Page(#{page.url}) at depth #{current_depth}"

          fetch_result = fetch_page(page)
          if fetch_result.nil?
            Rails.logger.error "Failed to fetch Page(#{page.id})"
            next
          end
          next_pages += page.reload.pages_linked_to

          index_page(page)

          rank_page(page)
        end
      rescue => e
        Rails.logger.error "Error scraping depth #{current_depth}: #{e}"
      end
      total_pages_scraped += 1
      current_pages = next_pages
    end

    Rails.logger.info "Scraped #{total_pages_scraped} pages to depth #{max_depth}"
  end

  def fetch_page(page)
    Rails.logger.info "Fetching Page(#{page.url})"

    if page.meta.fetch_finished_at > 10.minutes.ago
      Rails.logger.info "Skipping fetch of Page(#{page.id}) as it was fetched recently"
      return nil
    end

    FetchService::Client.fetch(page)
  end

  def index_page(page)
    Rails.logger.info "Indexing Page(#{page.url})"

    Rails.logger.info "Indexing Page(#{page.url}): Title"
    IndexService::Client.index_page_title(page)
    Rails.logger.info "Indexing Page(#{page.url}): Links"
    IndexService::Client.index_page_links(page)
    Rails.logger.info "Indexing Page(#{page.url}): Headers"
    IndexService::Client.index_page_headers(page)

    page.reload

    success = page.meta.indexed_title && page.meta.indexed_links && page.meta.indexed_headers
    page.meta.index_status = success ? :success : :failure
    page.meta.index_finished_at = DateTime.now.utc
    page.save!
  end

  def rank_page(page)
    Rails.logger.info "Ranking Page(#{page.url})"

    RankService::Client.rank_from_start_page(page, 1000)
  end
end
