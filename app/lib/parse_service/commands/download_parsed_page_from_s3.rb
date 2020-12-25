module ParseService::Commands
  class DownloadParsedPageFromS3 < Command::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], ENV['DO_PARSED_PAGES_NAMESPACE'])
      key = Base64.urlsafe_encode64(@url)
      body = client.read(key: key).body.read
      body = JSON.parse(body, symbolize_names: true)
      result.succeed!(body)
    end
  end
end