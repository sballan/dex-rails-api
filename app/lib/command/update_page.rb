module Command
  class UpdatePage < Command::Base::Abstract
    # @param [Page] page
    def initialize(page)
      @page = page

      @result = Command::Base::Result.new
    end

    def run
      download_url_command = Command::DownloadUrl.new(@page.url)
      download_url_command.run

      if download_url_command.failure?
        result.fail!(download_url_command.error, [download_url_command])
        return
      end

      upload_page_to_s3_command = Command::UploadPageToS3.new(@page.id, download_url_command.payload)
      upload_page_to_s3_command.run

      if upload_page_to_s3_command.failure?
        result.fail!(upload_page_to_s3_command.error, [download_url_command, upload_page_to_s3_command])
        return
      end

      result.succeed!(nil, [download_url_command, upload_page_to_s3_command])
    end
  end
end