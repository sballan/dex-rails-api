module CacheService::Commands
  class CacheScrapeBatchRange < Command::Abstract
    def initialize(scrape_batch, start_id, finish_id, of=25)
      super()
      @scrape_batch = scrape_batch
      @start_id = start_id
      @finish_id = finish_id
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