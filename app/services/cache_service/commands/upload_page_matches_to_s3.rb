module CacheService::Commands
  class UploadPageMatchesToS3 < Command::Abstract
    def initialize(query_text, cache_data_json)
      super()
      @query_text = query_text
      @body = cache_data_json
    end

    def run_proc
      namespace = ENV.fetch('DO_PAGE_MATCHES_NAMESPACE', '/page_matches')
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], namespace)
      key = Base64.urlsafe_encode64(@query_text)
      client.write_private(key: key, body: @body)

      result.succeed!(@body)
    end
  end
end
