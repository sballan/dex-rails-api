module CacheService::Commands
  class DownloadPageMatchesFromS3 < Command::Abstract
    def initialize(query_text)
      super()
      @query_text = query_text
    end

    def run_proc
      namespace = ENV.fetch('CACHE_DATA_NAMESPACE', 'query_results')
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], namespace)
      key = Base64.urlsafe_encode64(@query_text)
      body = client.read(key: key).body.read

      body = JSON.parse(body, symbolize_names: true)
      result.succeed!(body)
    end
  end
end
