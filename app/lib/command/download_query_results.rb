require 'base64'

module Command
  class DownloadQueryResults < Command::Base::Abstract
    def initialize(text)
      super()
      @text = text
    end

    def run_proc
      client = S3Client.new(ENV['DEV_BUCKET'], 'query_results')
      key = Base64.urlsafe_encode64(@text)
      body = client.read(key: key).body.read
      result.succeed!(body)
    rescue Aws::S3::Errors::NoSuchKey => e
      result.fail!(e)
    end
  end
end