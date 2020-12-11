module Parse
  class ParseScrapePage < Command::Base::Abstract
    # @param [ScrapePage] scrape_page
    def initialize(scrape_page)
      super()

      # @type [ScrapePage]
      @scrape_page = scrape_page
    end

    def run_proc
      handle_start!

      Rails.logger.debug "[Parse::ParseScrapePage] Starting parse: #{@scrape_page.page.url}"

      page_file = fetch_page_file
      parsed_page = parse_page_file(page_file)
      persist_parsed_page(parsed_page)

      Rails.logger.debug "[Parse::ParseScrapePage] Finished parse #{@scrape_page.page.url}"

      handle_success!
      result.succeed!(@scrape_page)
    rescue StandardError => e
      Rails.logger.error "[Parse::ParseScrapePage] failed for ScrapePage #{@scrape_page.id}"
      handle_failure
      result.fail!(e)
      raise e
    end

    private

    def handle_start!
      @scrape_page.status = :active
      @scrape_page.parse_status = :active
      @scrape_page.started_at = DateTime.now.utc
      @scrape_page.parse_started_at = DateTime.now.utc
      @scrape_page.save!
    end

    def handle_failure
      @scrape_page.parse_status = :failure
      @scrape_page.parse_finished_at = DateTime.now.utc
      @scrape_page.save
    end

    def handle_success!
      @scrape_page.parse_status = :success
      @scrape_page.parse_finished_at = DateTime.now.utc
      @scrape_page.save!

      Rails.logger.info "ParseScrapePage succeeded for ScrapePage #{@scrape_page.id}"
    end

    def fetch_page_file
      command = Parse::FetchPageFile.new(@scrape_page.page.url)
      command.run!
      command.payload
    end

    def parse_page_file(page_file)
      command = Parse::ParsePageFile.new(@scrape_page.page.url, page_file)
      command.run!
      command.payload
    end

    def persist_parsed_page(parsed_page)
      command = Parse::PersistParsedPage.new(@scrape_page.page, parsed_page)
      command.run!
    end
  end
end