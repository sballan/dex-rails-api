module Command
  class CrawlPage < Command::Base::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      page = create_or_find_page.payload
      refresh_page(@url)

      page_file = fetch_page_file.payload
      parsed_page = parse_page(page_file)

      refresh_links(parsed_page)
      insert_links(page, parsed_page)

      result.succeed!
    end

    private

    def create_or_find_page
      command = Command::CreateOrFindPage.new(@url)
      run_nested!(command)
      command.result
    end

    def refresh_page(url)
      command = Command::RefreshPage.new(url)
      run_nested!(command)
      command.result
    end

    def fetch_page_file
      command = Command::FetchPageFile.new(@url)
      run_nested!(command)
      command.result
    end

    def parse_page(page_file)
      command = Command::ParsePageFile.new(@url, page_file)
      command.run_with_gc!
      command.payload
    end

    def refresh_links(parsed_page)
      links = parsed_page[:links].map{|link| link[:url]}
      command = Command::RefreshPages.new(links)
      run_nested_with_gc!(command)
    end

    def insert_links(page, parsed_page)
      page_attrs = parsed_page[:links]
      page_attrs.each { |p| p.compact! }

      command = Command::InsertLinks.new page, page_attrs
      run_nested_with_gc!(command)
      command.result
    end
  end
end