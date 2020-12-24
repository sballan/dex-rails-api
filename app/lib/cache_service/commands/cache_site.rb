module CacheService::Commands
  class CacheSite < Command::Base::Abstract
    def initialize(site)
      super()
      @site = site
    end

    def run_proc
      PageMatch.by_site(@site)
      @scrape_batch.queries.in_batches(of: 25).each_record do |query|
        command = Cache::CacheQueryAndResults.new query
        command.run_with_gc!
      end

      result.succeed!
    end
  end
end