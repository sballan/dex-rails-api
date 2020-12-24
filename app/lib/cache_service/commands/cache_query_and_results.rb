module CacheService::Commands
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

      Rails.logger.info "CacheQueryAndResults succeeded for Query #{@query.id}"
      result.succeed!(json)
    end

    def cache_result_json(json)
      command = Cache::UploadCacheData.new(@query.text, json)
      command.run!

      if command.success?
        @query.cached_at = DateTime.now.utc
        @query.save!
      end
    end

    def generate_results
      # TODO: We need to page these results somehow
      @query.results.includes(:page).limit(50).map do |result|
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
