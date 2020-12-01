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
      # NOTE: need to make sure we only get ones with refresh success. "parse ready" is a misnomer
      @scrape_batch.scrape_pages.refresh_success.parse_ready.in_batches.each_record do |scrape_page|
        command = Parse::ParseScrapePage.new scrape_page
        run_nested_with_gc(command)
      end
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

    # Need to work out the logic here for determining when to stop.  I think
    # we may need to this "upstream", so that each worker determines the status of the *other* workers, not themselves.
    def handle_success!
      # If there are still pages to parse at this point, raise an error...that shouldn't happen
      if @scrape_batch.scrape_pages.refresh_success.parse_ready.count != 0
        raise "This shouldn't be possible, we just succeeded..."
      else
        @scrape_batch.parse_finished_at = DateTime.now.utc
      end

      # If after parsing there are not pages to be refreshed, we've finished refreshing
      if @scrape_batch.scrape_pages.refresh_ready.count == 0
        @scrape_batch.refresh_finished_at ||= DateTime.now.utc
      else
        @scrape_batch.refresh_active!
        @scrape_batch.refresh_finished_at = nil
      end

      @scrape_batch.save!
    end
  end
end