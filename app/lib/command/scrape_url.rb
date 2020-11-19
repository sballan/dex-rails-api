module Command
  class ScrapeUrl < Command::Base::Abstract
    def initialize(url)
      @url = url

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      download_url_result = download_url
      if download_url_result.failure?
        return result.fail!(download_url_result.error)
      end

      create_or_find_page_result = create_or_find_page
      if create_or_find_page_result.failure?
        return result.fail!(create_or_find_page_result.error)
      end

      page_file = download_url_result.payload
      page = create_or_find_page_result.payload
      extract_page_links_result = extract_page_links(page, page_file)
      if extract_page_links_result.failure?
        return result.fail!(extract_page_links_result.error)
      end

      result.succeed!
    end

    private

    def download_url
      download_url_command = Command::DownloadUrl.new(@url)
      run_nested(download_url_command)
      download_url_command.result
    end

    def create_or_find_page
      create_or_find_page_command = Command::CreateOrFindPage.new(@url)
      run_nested(create_or_find_page_command)
      create_or_find_page_command.result
    end

    def extract_page_links(page, page_file)
      extract_page_links_command = Command::ExtractPageLinks.new(page, page_file)
      run_nested(extract_page_links_command)
      extract_page_links_command.result
    end

  end
end