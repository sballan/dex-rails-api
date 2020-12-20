module RefreshService::Commands
  class UploadPageFileToS3 < Command::Base::Abstract
    def initialize(url, page_content)
      super()
      @url = url
      @page_content = page_content
    end

    def run_proc
      client = S3Client.new(ENV['DEV_BUCKET'], 'page_files')
      key = Base64.urlsafe_encode64(@url)
      client.write_private(key: key, body: @page_content)
      result.succeed!
    end
  end
end