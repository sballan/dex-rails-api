module Scrape
  class RunScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      @scrape_batch = scrape_batch
    end

    def run_proc
      startup_checks
      handle_start!

      refresh_scrape_pages

      handle_success!
      result.succeed!(@scrape_batch)
    rescue StandardError => e
      Rails.logger.error "ScrapeBatch (#{@scrape_batch.id}) failed"
      handle_failure
      raise e
    end

    private

    def refresh_scrape_pages
      @scrape_batch.scrape_pages.refresh_ready.in_batches.each_record do |scrape_page|
        command = Command::RefreshScrapePage.new scrape_page
        run_nested_with_gc(command)
        sleep 1
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