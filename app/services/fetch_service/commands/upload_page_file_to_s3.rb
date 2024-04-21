module FetchService::Commands
  class UploadPageFileToS3 < Command::Abstract
    def initialize(url, page_content)
      super()
      @url = url
      @page_content = page_content
    end

    def run_proc
      namespace = ENV.fetch("DO_DEFAULT_NAME_SPACE", "dev") + "/page_files"
      client = S3Client.new(ENV["DO_DEFAULT_BUCKET"], namespace)
      key = Base64.urlsafe_encode64(@url)
      client.write_private(key: key, body: @page_content)
      result.succeed!
    end
  end
end
