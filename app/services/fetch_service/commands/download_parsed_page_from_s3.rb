module FetchService::Commands
  class DownloadParsedPageFromS3 < Command::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      namespace = ENV.fetch("DO_PARSED_PAGES_NAMESPACE", "/parsed_pages")
      client = S3Client.new(ENV["DO_DEFAULT_BUCKET"], namespace)
      key = Base64.urlsafe_encode64(@url)
      body = client.read(key: key).body.read
      body = JSON.parse(body, symbolize_names: true)
      result.succeed!(body)
    end
  end
end
