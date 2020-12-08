require 'base64'

module Command
  class DownloadQueryResults < Command::Base::Abstract
    def initialize(text)
      super()
      @text = text
    end

    def run_proc
      namespace = ENV.fetch('CACHE_DATA_NAMESPACE', 'query_results')
      client = S3Client.new(ENV['DEV_BUCKET'], namespace)
      key = Base64.urlsafe_encode64(@text)
      body = client.read(key: key).body.read
      result.succeed!(body)
    rescue Aws::S3::Errors::NoSuchKey => e
      result.fail!(e)
    end
  end
end