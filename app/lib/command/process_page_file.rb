module Command
  class ProcessPageFile < Command::Base::Abstract
    def initialize(url, page_file)
      @url = url
      @page_file = page_file

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      title = extract_title
      create_or_find_page_result = create_or_find_page(title)
      return result.fail!(create_or_find_page_result.error) if create_or_find_page_result.failure?

      page = create_or_find_page_result.payload
      extract_page_links_result = extract_page_links(page)
      return result.fail!(extract_page_links_result.error) if extract_page_links_result.failure?

      result.succeed!(page)
    end

    private

    def extract_title
      doc = Nokogiri::HTML(@page_file)
      doc.at_css("title").text
    end

    def create_or_find_page(title)
      create_or_find_page_command = Command::CreateOrFindPage.new(@url, title)
      run_nested(create_or_find_page_command)
      create_or_find_page_command.result
    end

    def extract_page_links(page)
      extract_page_links_command = Command::ExtractPageLinks.new(page, @page_file)
      run_nested(extract_page_links_command)
      extract_page_links_command.result
    end
  end
end