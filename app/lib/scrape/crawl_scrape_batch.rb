module Scrape
  class CrawlScrapeBatch < Command::Abstract
    def initialize(scrape_batch, ttl=10.minutes)
      super()
      # @type [ScrapeBatch]
      @scrape_batch = scrape_batch
      @ttl = ttl
    end

    def run_proc
      startup_checks
      handle_start!

      while(@scrape_batch.active? && !ttl_exceeded) do
        refresh_scrape_pages
        break if ttl_exceeded
        parse_scrape_pages
        break if ttl_exceeded
        gather_new_pages
        @scrape_batch.reload
      end

      handle_success!
      result.succeed!(@scrape_batch)
    rescue StandardError => e
      Rails.logger.error "ScrapeBatch (#{@scrape_batch.id}) failed"
      handle_failure
      raise e
    end

    private

    def ttl_exceeded
      (DateTime.now.to_i - @scrape_batch.started_at.to_i) > @ttl.to_i
    end

    def gather_new_pages
      Rails.logger.debug "Gathering newly created pages"
      links = []
      @scrape_batch.links.includes(:to).in_batches do |links|
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

    def refresh_scrape_pages
      @scrape_batch.refresh_started_at ||= DateTime.now.utc
      @scrape_batch.save!

      scrape_pages_by_host = @scrape_batch.scrape_pages.refresh_ready.all.group_by do |scrape_page|
        URI.parse(scrape_page.page.url).host
      end

      # while any host still has unprocessed scrape_pages
      while(scrape_pages_by_host.any? {|host, scrape_pages| scrape_pages.any?}) do
        break if ttl_exceeded
        # pop a scrape_page for each host, refresh them all (since we don't worry about rate limits), then sleep
        scrape_pages_by_host.each do |host, scrape_pages|
          break if ttl_exceeded
          next unless scrape_pages.any?
          scrape_page = scrape_pages.pop
          command = Refresh::RefreshScrapePage.new scrape_page
          run_nested_with_gc(command)
        end
        sleep 2
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
        break if ttl_exceeded
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