module Cache
  class CacheScrapeBatchRange < Command::Base::Abstract
    def initialize(scrape_batch, start, finish, of=25)
      super()
      @scrape_batch = scrape_batch
      @start = start
      @finish = finish
      @of = of
    end

    def run_proc
      @scrape_batch.queries.in_batches(
        of: @of,
        start: @start,
        finish: @finish
      ).each_record do |query|
        command = Cache::CacheQueryAndResults.new query
        command.run_with_gc!
      end

      result.succeed!
    end
  end
end