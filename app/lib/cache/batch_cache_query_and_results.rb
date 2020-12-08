module Cache
  class BatchCacheQueryAndResults < Command::Base::Abstract
    def initialize(query_ids)
      super()
      @query_ids = query_ids
    end

    def run_proc
      Query.where(id: @query_ids).in_batches(of: 10).each_record do |query|
        command = Cache::CacheQueryAndResults.new query
        run_nested_with_gc!(command)
      end

      result.succeed!
    end
  end
end
