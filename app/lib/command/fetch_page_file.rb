module Command
  class FetchPageFile < Command::Base::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      client = S3Client.new(ENV['DEV_BUCKET'], 'page_files')
      key = Base64.urlsafe_encode64(@url)
      body = client.read(key: key).body.read
      result.succeed!(body)
    end
  end
end