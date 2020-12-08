module Cache
  class CacheScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      @scrape_batch = scrape_batch
    end

    def run_proc
      if @scrape_batch.scrape_pages.parse_success.any?
        num_to_cache = @scrape_batch.scrape_pages.parse_success.cache_ready.count

        Rails.logger.debug "[Cache::CacheScrapeBatch] More pages to cache!"
        Rails.logger.info "[Cache::CacheScrapeBatch] Starting loop of new Cache::CacheScrapePage Command"

        @scrape_batch.scrape_pages.parse_success.cache_ready.includes(:page).in_batches.each_record do |scrape_page|
          scrape_page.cache_started_at = DateTime.now.utc
          scrape_page.cache_active!
          command = Cache::CacheScrapePage.new scrape_page
          command.run_with_gc!

          if command.success?
            scrape_page.cache_success!
            scrape_page.cache_finished_at = DateTime.now.utc
          else
            scrape_page.cache_failure!
            scrape_page.cache_finished_at = DateTime.now.utc
          end

          scrape_page.save!
        end

        num_left = @scrape_batch.scrape_pages.parse_success.cache_ready.count
        Rails.logger.debug "[Cache::CacheScrapeBatch] We went from #{num_to_cache} to #{num_left}."
      else
        Rails.logger.info "[Cache::CacheScrapeBatch] No pages left to cache. "
      end

      result.succeed!
    end

  end
end