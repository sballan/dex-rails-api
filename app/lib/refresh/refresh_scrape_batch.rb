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
      # TODO: remove the magic number in limit. For now, it makes sure that a refresh job doesn't drag on too long
      # before getting to parsing the pages that were refreshed
      @scrape_batch.scrape_pages.includes(:page).refresh_ready.limit(20).in_batches(of: 10) do |scrape_pages|
        # group by host for some janky 'rate limiting'
        scrape_pages_by_host = scrape_pages.group_by do |scrape_page|
          URI.parse(scrape_page.page.url).host
        end

        # while any host still has unprocessed scrape_pages
        while(scrape_pages_by_host.any? {|host, sps| sps.any?}) do
          # pop a scrape_page for each host, refresh them all (since we don't worry about rate limits), then sleep
          scrape_pages_by_host.each do |host, sps|
            next unless sps.any?
            scrape_page = sps.pop
            command = Refresh::RefreshScrapePage.new scrape_page
            command.run_with_gc # TODO: need a better convention for not raising errors here.  hopefully they're all still logged...
          end
          sleep 1
        end
      end
    end
  end
end