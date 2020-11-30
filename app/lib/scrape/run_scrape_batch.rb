module Scrape
  class RunScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch, ttl=10.minutes)
      super()
      # @type [ScrapeBatch]
      @scrape_batch = scrape_batch
      @ttl = ttl
    end

    def run_proc
      startup_checks
      handle_start!

      refresh_scrape_pages
      parse_scrape_pages

      handle_success!
      result.succeed!(@scrape_batch)
    rescue StandardError => e
      Rails.logger.error "ScrapeBatch (#{@scrape_batch.id}) failed"
      handle_failure
      raise e
    end

    private

    def ttl_exceeded
      (DateTime.now - @scrape_batch.started_at) > @ttl
    end

    def refresh_scrape_pages
      @scrape_batch.refresh_started_at ||= DateTime.now.utc
      @scrape_batch.save!

      @scrape_batch.scrape_pages.refresh_ready.in_batches.each_record do |scrape_page|
        command = Refresh::RefreshScrapePage.new scrape_page
        run_nested_with_gc(command)
        sleep 1
      end

      @scrape_batch.reload

      if @scrape_batch.scrape_pages.refresh_ready.count == 0
        @scrape_batch.refresh_finished_at = DateTime.now.utc
      end

      if @scrape_batch.scrape_pages.refresh_failure.count == 0
        @scrape_batch.refresh_success!
      else
        @scrape_batch.refresh_failure!
      end

      @scrape_batch.save!
    end

    def parse_scrape_pages
      @scrape_batch.parse_started_at ||= DateTime.now.utc
      @scrape_batch.save!

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
      @scrape_batch.started_at = DateTime.now.utc
      @scrape_batch.save!
    end

    def handle_failure
      @scrape_batch.failure!
      @scrape_batch.finished_at = DateTime.now.utc
      @scrape_batch.save
    end

    def handle_success!
      @scrape_batch.success!
      @scrape_batch.finished_at = DateTime.now.utc
      @scrape_batch.save!
    end
  end
end