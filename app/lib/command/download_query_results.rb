require 'base64'

module Command
  class DownloadQueryResults < Command::Base::Abstract
    def initialize(query)
      super()
      @query = query
    end

    def run_proc
      client = S3Client.new(ENV['DEV_BUCKET'], 'query_results')
      key = Base64.urlsafe_encode64(@query.text)
      body = client.read(key: key).body.read
      result.succeed!(body)
    end

  end
end