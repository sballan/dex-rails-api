module Parse
  class ParseScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      # @type [ScrapeBatch]
      @scrape_batch = scrape_batch
     end

    def run_proc
      startup_checks
      handle_start!

      parse_scrape_pages
      @scrape_batch.reload

      handle_success!
      result.succeed!(@scrape_batch)
    rescue StandardError => e
      Rails.logger.error "ScrapeBatch (#{@scrape_batch.id}) failed"
      handle_failure
      raise e
    end

    private

    def parse_scrape_pages
      @scrape_batch.scrape_pages.parse_ready.in_batches.each_record do |scrape_page|
        command = Parse::ParseScrapePage.new scrape_page
        run_nested_with_gc(command)
      end

      @scrape_batch.reload

      if @scrape_batch.scrape_pages.parse_ready.count == 0
        @scrape_batch.parse_finished_at = DateTime.now.utc
      end

      if @scrape_batch.scrape_pages.parse_failure.count == 0
        @scrape_batch.parse_success!
      else
        @scrape_batch.parse_failure!
      end

      @scrape_batch.save!
    end

    def startup_checks
      if @scrape_batch.active?
        Rails.logger.debug "Starting already active ScrapeBatch (#{@scrape_batch.id})"
      elsif @scrape_batch.ready?
        Rails.logger.debug "Starting ready ScrapeBatch (#{@scrape_batch.id})"
      else
        raise "Something went wrong"
      end
    end

    def handle_start!
      @scrape_batch.active!
      @scrape_batch.started_at ||= DateTime.now.utc
      @scrape_batch.parse_started_at ||= DateTime.now.utc
      @scrape_batch.save!
    end

    def handle_failure
      @scrape_batch.parse_failure!
      @scrape_batch.parse_failure_at = DateTime.now.utc
      @scrape_batch.save
    end

    def handle_success!
      # If there are none left to parse, we've finished
      if @scrape_batch.scrape_pages.parse_ready.count == 0
        @scrape_batch.parse_finished_at = DateTime.now.utc
      end

      # If none failed, we've succeeded
      if @scrape_batch.scrape_pages.parse_failure.count == 0
        @scrape_batch.parse_success!
      else
        @scrape_batch.parse_failure!
      end

      @scrape_batch.save!
    end
  end
end