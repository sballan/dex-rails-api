module Command
  class ScrapeUrl < Command::Base::Abstract
    def initialize(url)
      @url = url

      @result = Command::Base::Result.new(self.class.name)
    end

    def run_proc
      create_or_find_page_result = create_or_find_page
      page = create_or_find_page_result.payload

      download_mechanize_page_result = download_mechanize_page
      mechanize_page = download_mechanize_page_result.payload

      process_mechanize_page(page, mechanize_page)

      create_page_queries(page, mechanize_page)

      result.succeed!
    end

    private

    def download_mechanize_page
      download_mechanize_page_command = Command::DownloadMechanizePage.new(@url)
      download_mechanize_page_command.run_with_gc!
      download_mechanize_page_command.result
    end

    def create_or_find_page
      create_or_find_page_command = Command::CreateOrFindPage.new(@url)
      create_or_find_page_command.run_with_gc!
      create_or_find_page_command.result
    end

    def process_mechanize_page(page, mechanize_page)
      process_page_file_command = Command::ProcessMechanizePage.new(page, mechanize_page)
      process_page_file_command.run_with_gc!
      process_page_file_command.result
    end

    def create_page_queries(page, mechanize_page=nil)
      create_page_queries_command = Command::CreatePageQueries.new(page, mechanize_page)
      create_page_queries_command.run_with_gc!
      create_page_queries_command.result
    end
  end
end
