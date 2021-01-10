module FetchService::Commands
  class DownloadPageFileFromS3 < Command::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      namespace = ENV.fetch('DO_PAGE_FILES_NAMESPACE', '/page_files')
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], namespace)
      key = Base64.urlsafe_encode64(@url)
      body = client.read(key: key).body.read
      Rails.logger.debug "Fetched page_file from S3: #{@url}"

      result.succeed!(body)
    end
  end
end