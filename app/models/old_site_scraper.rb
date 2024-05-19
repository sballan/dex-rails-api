class OldSiteScraper
  SITE_SCRAPER_RANK_PAGES = ENV.fetch("SITE_SCRAPER_RANK_PAGES", 1000).to_i
  SITE_SCRAPER_RANK_REFRESH_SECCONDS = ENV.fetch("SITE_SCRAPER_RANK_REFRESH_SECCONDS", 1.day.to_i).to_i
  SITE_SCRAPER_FETCH_REFRESH_SECONDS = ENV.fetch("SITE_SCRAPER_FETCH_REFRESH_SECONDS", 1.week.to_i).to_i

  attr_reader :site, :current_page

  def initialize(site)
    @site = site
    @home_page = site.fetch_home_page
    @current_page = nil
  end

  def scrape_to_depth(max_depth = 3)
    total_pages_scraped = 0
    current_depth = 0
    current_pages = [@home_page]

    processed_pages = Set.new

    while current_depth < max_depth
      current_depth += 1
      next_pages = []

      current_pages.each do |page|
        @current_page = page

        next if processed_pages.include?(page.id)
        processed_pages << page.id

        log_info "Scraping at depth #{current_depth}"

        fetch_result = fetch_page(page)
        if fetch_result.nil?
          log_error "Failed to fetch"
          next
        end
        next_pages += page.reload.pages_linked_to

        insert_document(page)
        # index_page(page)
        rank_page(page)

        total_pages_scraped += 1
      rescue => e
        log_error "Error scraping depth #{current_depth}: #{e}"
      end

      current_pages = next_pages
    end

    log_info "Scraped #{total_pages_scraped} pages to depth #{max_depth}"
  end

  def fetch_page(page)
    if page.meta&.fetch_dead?
      log_info "Skipping fetch because its status is dead"
      return nil
    end

    if page.meta&.fetch_active?
      log_info "Skipping fetch because status is active"
      return nil
    end

    if page.meta&.fetch_success? && page.meta.fetch_finished_at > SITE_SCRAPER_FETCH_REFRESH_SECONDS.seconds.ago
      log_info "Skipping fetch because it was fetched recently"
      return false
    end

    log_info "Starting Fetch"
    FetchService::Client.fetch(page)
  end

  def index_page(page)
    if page.meta.index_dead?
      log_info "Skipping index because status is dead"
      return nil
    end

    if page.meta.index_active?
      log_info "Skipping index because status is active"
      return nil
    end

    if page.meta.index_finished_at && page.meta.index_finished_at > page.meta.fetch_finished_at
      log_info "Skipping index because it was indexed after the last fetch"
      return false
    end

    log_info "Starting Index"
    page.meta.index_status = :active
    page.save!

    log_info "Indexing title"
    IndexService::Client.index_page_title(page)
    log_info "Indexing links"
    IndexService::Client.index_page_links(page)
    log_info "Indexing headers"
    IndexService::Client.index_page_headers(page)
    log_info "Indexing paragraphs"
    IndexService::Client.index_page_paragraphs(page, 3, 1)

    page.reload

    success = page.meta.indexed_title && page.meta.indexed_links && page.meta.indexed_headers
    page.meta.index_status = success ? :success : :failure
    page.meta.index_finished_at = DateTime.now.utc
    page.save!
  end

  def insert_document(page)
    # if page.document && page.document.created_at > page.meta.fetch_finished_at
    #   log_info "Skipping document insert because a document was inserted after the last fetch"
    #   return false
    # end

    log_info "Starting Document insert"
    parsed_page = FetchService::Client.download_parsed_page(page)

    text = ""
    text += parsed_page[:title] + " "
    text += parsed_page[:headers].join(" ") if parsed_page[:headers].is_a?(Array)
    text += parsed_page[:paragraphs].join(" ") if parsed_page[:paragraphs].is_a?(Array)

    document_creator = Document::CreateFromText.new(text)
    document_creator.process_and_persist

    page.document&.postings&.delete_all
    page.document&.destroy!
    page.document = document_creator.document
    page.save!
  end

  def rank_page(page)
    if page.meta.rank_dead?
      log_info "Skipping rank because status is dead"
      return nil
    end

    if page.meta.rank_active?
      log_info "Skipping rank because status is active"
      return nil
    end

    if page.meta.rank_finished_at && page.meta.rank_finished_at > SITE_SCRAPER_RANK_REFRESH_SECCONDS.second.ago
      log_info "Skipping rank because it was ranked too recently"
      return false
    end

    log_info "Starting Rank"
    page.meta.rank_status = :active
    page.save!

    RankService::Client.rank_from_start_page(page, SITE_SCRAPER_RANK_PAGES)
  end

  def log_info(message)
    Rails.logger.info("#{Time.zone.now}: [INFO] [#{current_page.url}] #{message}")
  end

  def log_error(message, error = nil)
    error_message = error ? "\n#{error.message}" : ""
    Rails.logger.error("#{Time.zone.now}: [ERROR] [#{current_page.url}] #{message}#{error_message}")
  end
end
