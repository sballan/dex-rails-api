module Command
  class UpdatePage < Command::Base::Abstract
    # @param [Page] page
    def initialize(page)
      @page = page

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      download_url_command = Command::DownloadUrl.new(@page.url)
      run_nested(download_url_command)

      if download_url_command.failure?
        result.fail!(download_url_command.error)
        return
      end

      page_file = download_url_command.payload
      upload_page_to_s3_command = Command::UploadPageToS3.new(@page.id, page_file)
      run_nested(upload_page_to_s3_command)

      if upload_page_to_s3_command.failure?
        result.fail!(upload_page_to_s3_command.error)
        return
      end

      result.succeed!
    end
  end
end