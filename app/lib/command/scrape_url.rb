module Command
  class ScrapeUrl < Command::Base::Abstract
    def initialize(url)
      @url = url

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      download_url_result = download_url
      return result.fail!(download_url_result.error) if download_url_result.failure?

      page_file = download_url_result.payload
      process_page_file_result = process_page_file(page_file)
      return result.fail!(process_page_file_result.error) if process_page_file_result.failure?

      page = process_page_file_result.payload
      create_page_queries_result = create_page_queries(page)
      return result.fail!(create_page_queries_result.error) if create_page_queries_result.failure?

      result.succeed!
    end

    private

    def download_url
      download_url_command = Command::DownloadUrl.new(@url)
      run_nested(download_url_command)
      download_url_command.result
    end

    def process_page_file(page_file)
      process_page_file_command = Command::ProcessPageFile.new(@url, page_file)
      run_nested(process_page_file_command)
      process_page_file_command.result
    end

    def create_page_queries(page)
      create_page_queries_command = Command::CreatePageQueries.new(page)
      run_nested(create_page_queries_command)
      create_page_queries_command.result
    end

  end
end