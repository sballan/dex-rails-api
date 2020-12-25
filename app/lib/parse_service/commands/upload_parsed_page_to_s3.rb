module ParseService::Commands
  class UploadParsedPageToS3 < Command::Abstract
    def initialize(url, parsed_page)
      super()
      @url = url
      @parsed_page = parsed_page
    end

    def run_proc
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], ENV['DO_PARSED_PAGES_NAMESPACE'])
      key = Base64.urlsafe_encode64(@url)

      body = @parsed_page.is_a?(String) ? @parsed_page : @parsed_page.to_json
      client.write_private(key: key, body: body)
      result.succeed!
    end
  end
end