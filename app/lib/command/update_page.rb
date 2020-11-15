module Command
  class UpdatePage < Command::Abstract
    # @param [Page] page
    def initialize(page)
      @page = page

      @result = {
        status: :failure
      }
    end

    def run
      download_url_command = Command::DownloadUrl.new(@page.url)
      download_url_command.run

      if download_url_command.success?
        @page.download_success = DateTime.now.utc
      else
        result[:status] = :failure
        error = download_url_command.error
        @page.download_failure = DateTime.now.utc
        return
      end
    end
  end
end