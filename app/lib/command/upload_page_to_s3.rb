module Command
  class UploadPageToS3
    def initialize(page_id, page_content)
      @page_id = page_id
      @page_content = page_content

      @result = {
        status: :failure,
        payload: nil
      }
    end

    def run
      client = S3Client.new(ENV['DEV_BUCKET'])
      s3_key = "pages/#{@page_id}"
      client.write_private(key: s3_key, body: @page_content)
      @result[:status] = :success
    end
  end
end