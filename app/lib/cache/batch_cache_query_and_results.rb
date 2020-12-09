module Cache
  class BatchCacheQueryAndResults < Command::Base::Abstract
    def initialize(query_ids)
      super()
      @query_ids = query_ids
    end

    def run_proc
      Query.where(id: @query_ids).in_batches(of: 100).each_record do |query|
        command = Cache::CacheQueryAndResults.new query
        command.run_with_gc!
      end

      result.succeed!
    end
  end
end
