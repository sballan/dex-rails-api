module RefreshService::Commands
  class DownloadPageFileFromS3 < Command::Base::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      client = S3Client.new(ENV['DEV_BUCKET'], ENV['DO_PAGE_FILES_NAMESPACE'])
      key = Base64.urlsafe_encode64(@url)
      body = client.read(key: key).body.read
      Rails.logger.debug "Fetched page_file from S3: #{@url}"

      result.succeed!(body)
    end
  end
end