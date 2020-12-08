module Cache
  class CacheQueryAndResults < Command::Base::Abstract
    def initialize(query)
      super()
      @query = query
    end

    def run_proc
      json = generate_results.to_json
      cache_result_json(json)

      @query.cached_at = DateTime.now.utc
      @query.save!

      result.succeed!(body)
    end

    def cache_result_json(json)
      command = Cache::UploadCacheData.new(@query.text, json)
      command.run_with_gc!

      if command.success?
        @query.cached_at = DateTime.now.utc
        @query.save!
      end
    end

    def generate_results
      @query.results.includes(:page).map do |result|
        {
            kind: result.kind,
            page: {
                url: result.page.url,
                title: result.page.title
            }
        }
      end
    end
  end
end
