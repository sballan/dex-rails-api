module Command
  class ScrapeUrl < Command::Base::Abstract
    def initialize(url)
      @url = url

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      create_or_find_page_result = create_or_find_page
      page = create_or_find_page_result.payload

      download_mechanize_page_result = download_mechanize_page
      mechanize_page = download_mechanize_page_result.payload

      process_mechanize_page(page, mechanize_page)

      create_page_queries(page)

      result.succeed!
    end

    private

    def download_mechanize_page
      download_mechanize_page_command = Command::DownloadMechanizePage.new(@url)
      run_nested!(download_mechanize_page_command)
      download_mechanize_page_command.result
    end

    def create_or_find_page
      create_or_find_page_command = Command::CreateOrFindPage.new(@url)
      run_nested!(create_or_find_page_command)
      create_or_find_page_command.result
    end

    def process_mechanize_page(page, mechanize_page)
      process_page_file_command = Command::ProcessMechanizePage.new(page, mechanize_page)
      run_nested!(process_page_file_command)
      process_page_file_command.result
    end

    def create_page_queries(page)
      create_page_queries_command = Command::CreatePageQueries.new(page)
      run_nested!(create_page_queries_command)
      create_page_queries_command.result
    end

  end
end