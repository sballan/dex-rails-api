module Command
  class UploadPageToS3 < Command::Base::Abstract
    def initialize(page_id, page_content)
      @page_id = page_id
      @page_content = page_content

      @result = Command::Base::Result.new
    end

    def run
      client = S3Client.new(ENV['DEV_BUCKET'], 'pages')
      client.write_private(key: @page_id, body: @page_content)
      result.succeed!
    end
  end
end