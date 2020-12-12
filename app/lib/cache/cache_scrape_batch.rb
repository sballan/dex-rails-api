module Cache
  class CacheScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      @scrape_batch = scrape_batch
    end

    def run_proc
      @scrape_batch.queries.in_batches.each_record do |query|
        command = Cache::CacheQueryAndResults.new query
        command.run_with_gc!
      end

      result.succeed!
    end
  end
end