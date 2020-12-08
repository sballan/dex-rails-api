module Parse
  class ParseScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      # @type [ScrapeBatch]
      @scrape_batch = scrape_batch
     end

    def run_proc
      parse_scrape_pages
      gather_new_pages

      result.succeed!(@scrape_batch)
    rescue StandardError => e
      Rails.logger.error "ScrapeBatch (#{@scrape_batch.id}) failed"
      raise e
    end

    private

    def parse_scrape_pages
      num_to_parse = @scrape_batch.scrape_pages.refresh_success.parse_ready.count
      Rails.logger.debug "[Parse::ParseScrapeBatch] We have #{num_to_parse} pages to parse"

      # NOTE: need to make sure we only get ones with refresh success. "parse ready" is a misnomer
      @scrape_batch.scrape_pages.refresh_success.parse_ready.in_batches.each_record do |scrape_page|
        command = Parse::ParseScrapePage.new scrape_page
        run_nested_with_gc(command) # TODO: need a better convention to signify catching errors
      end

      num_to_parse = @scrape_batch.scrape_pages.refresh_success.parse_ready.count
      Rails.logger.debug "[Parse::ParseScrapeBatch] After parsing, we have #{num_to_parse} pages to parse"
    end

    def gather_new_pages
      Rails.logger.debug "Gathering newly created pages"
      links = []
      @scrape_batch.links.in_batches do |links|
        scrape_page_attributes = links.all.map do |link|
          {
              scrape_batch_id: @scrape_batch.id,
              page_id: link.to_id,
              created_at: DateTime.now.utc,
              updated_at: DateTime.now.utc
          }
        end
        Rails.logger.debug "Adding newly created pages to batch"
        ScrapePage.insert_all(scrape_page_attributes, unique_by: :index_scrape_pages_on_scrape_batch_id_and_page_id)
      end
    end
  end
end