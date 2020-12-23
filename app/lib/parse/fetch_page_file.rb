module Parse
  class FetchPageFile < Command::Base::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], 'page_files')
      key = Base64.urlsafe_encode64(@url)
      body = client.read(key: key).body.read
      Rails.logger.debug "[Parse::FetchPageFile] Fetched from S3: #{@url}"
      result.succeed!(body)
    end
  end
end