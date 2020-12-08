module Refresh
  class RefreshScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      # @type [ScrapeBatch]
      @scrape_batch = scrape_batch
     end

    def run_proc
      Rails.logger.debug "[Refresh::RereshScrapeBatch] ScrapeBatch (#@scrape_batch) starting"
      refresh_scrape_pages

      Rails.logger.debug "[Refresh::RereshScrapeBatch] ScrapeBatch (#@scrape_batch) finished"
      result.succeed!(@scrape_batch)
    rescue StandardError => e
      Rails.logger.error "ScrapeBatch (#{@scrape_batch.id}) failed"
      raise e
    end

    private

    def refresh_scrape_pages
      # group by host for some janky 'rate limiting'
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
          run_nested_with_gc(command) # TODO: need a better convention for not raising errors here.  hopefully they're all still logged...
        end
        sleep 2
      end
    end

  end
end