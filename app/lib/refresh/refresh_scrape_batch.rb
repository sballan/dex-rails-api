module Refresh
  class RefreshScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      # @type [ScrapeBatch]
      @scrape_batch = scrape_batch
     end

    def run_proc
      startup_checks
      handle_start!

      refresh_scrape_pages
      gather_new_pages
      @scrape_batch.reload

      handle_success!
      result.succeed!(@scrape_batch)
    rescue StandardError => e
      Rails.logger.error "ScrapeBatch (#{@scrape_batch.id}) failed"
      handle_failure
      raise e
    end

    private

    def refresh_scrape_pages
      scrape_pages_by_host = @scrape_batch.scrape_pages.refresh_ready.group_by do |scrape_page|
        URI.parse(scrape_page.page.url).host
      end

      # while any host still has unprocessed scrape_pages
      while(scrape_pages_by_host.any? {|host, scrape_pages| scrape_pages.any?}) do
        # pop a scrape_page for each host, refresh them all (since we don't worry about rate limits), then sleep
        scrape_pages_by_host.each do |host, scrape_pages|
          next unless scrape_pages.any?
          scrape_page = scrape_pages.pop
          command = Refresh::RefreshScrapePage.new scrape_page
          run_nested_with_gc(command)
        end
        sleep 2
      end
    end

    def gather_new_pages
      Rails.logger.debug "Gathering newly created pages"
      links = []
      @scrape_batch.links.includes(:to).in_batches do |links|
        scrape_page_attributes = links.all.map do |link|
          {
            scrape_batch_id: @scrape_batch.id,
            page_id: link.to_id
          }
        end
        Rails.logger.debug "Adding newly created pages to batch"
        ScrapePage.insert_all(scrape_page_attributes, unique_by: :index_scrape_pages_on_scrape_batch_id_and_page_id)
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
      @scrape_batch.refresh_started_at ||= DateTime.now.utc
      @scrape_batch.save!
    end

    def handle_failure
      @scrape_batch.refresh_failure!
      @scrape_batch.refresh_failure_at = DateTime.now.utc
      @scrape_batch.save
    end

    def handle_success!
      # If there are none left to refresh, we've finished
      if @scrape_batch.scrape_pages.refresh_ready.count > 0
        Rails.logger.debug "ScrapeBatch (#{@scrape_batch.id}) still has pages left to refresh. Status should remain refresh_active"
      else
        Rails.logger.debug "ScrapeBatch (#{@scrape_batch.id}) has no pages left to refresh. Setting refresh_finished_at"
        @scrape_batch.refresh_finished_at = DateTime.now.utc

        # If none failed, we've succeeded
        if @scrape_batch.scrape_pages.refresh_failure.count == 0
          Rails.logger.debug "ScrapeBatch (#{@scrape_batch.id}) has no pages left to refresh. Setting refresh_finished_at"
          @scrape_batch.refresh_success!
        else
          # TODO: some retry mechanism.  use 'dead' status to signify not retrying
          @scrape_batch.refresh_failure!
        end
        @scrape_batch.save!
      end
    end
  end
end