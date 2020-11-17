module Command
  class ScrapeUrl < Command::Base::Abstract
    def initialize(url)
      @url = url

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      download_url_command = Command::DownloadUrl.new(@url)
      run_nested(download_url_command)

      if(download_url_command.failure?)
        result.fail!(download_url_command.error)
        return
      end

      create_or_find_page_command = Command::CreateOrFindPage.new(@url)
      run_nested(create_or_find_page_command)

      if(create_or_find_page_command.failure?)
        result.fail!(create_or_find_page_command.error)
        return
      end

      page_file = download_url_command.payload
      page = create_or_find_page_command.payload

      extract_page_links_command = Command::ExtractPageLinks.new(page, page_file)
      run_nested(extract_page_links_command)

      if(extract_page_links_command.failure?)
        result.fail!(extract_page_links_command.error)
        return
      end

      result.success!
    end

  end
end