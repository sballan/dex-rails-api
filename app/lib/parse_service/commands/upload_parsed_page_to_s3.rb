module RefreshService::Commands
  class UploadParsedPageToS3 < Command::Base::Abstract
    def initialize(url, parsed_page)
      super()
      @url = url
      @parsed_page = parsed_page
    end

    def run_proc
      client = S3Client.new(ENV['DEV_BUCKET'], 'parsed_pages')
      key = Base64.urlsafe_encode64(@url)
      client.write_private(key: key, body: @parsed_page)
      result.succeed!
    end
  end
end