module FetchService::Commands
  class UploadParsedPageToS3 < Command::Abstract
    def initialize(url, parsed_page)
      super()
      @url = url
      @parsed_page = parsed_page
    end

    def run_proc
      namespace = ENV.fetch("DO_PARSED_PAGES_NAMESPACE", "/parsed_pages")
      client = S3Client.new(ENV["DO_DEFAULT_BUCKET"], namespace)
      key = Base64.urlsafe_encode64(@url)

      body = @parsed_page.is_a?(String) ? @parsed_page : @parsed_page.to_json
      client.write_private(key: key, body: body)
      result.succeed!
    end
  end
end
