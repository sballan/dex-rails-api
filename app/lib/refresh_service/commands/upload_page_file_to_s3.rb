module RefreshService::Commands
  class UploadPageFileToS3 < Command::Abstract
    def initialize(url, page_content)
      super()
      @url = url
      @page_content = page_content
    end

    def run_proc
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], ENV['DO_PAGE_FILES_NAMESPACE'])
      key = Base64.urlsafe_encode64(@url)
      client.write_private(key: key, body: @page_content)
      result.succeed!
    end
  end
end