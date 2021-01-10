module FetchService::Commands
  class ParsePage < Command::Abstract
    def initialize(page, page_file)
      super()
      @page = page
      @page_file = page_file
    end

    def run_proc
      parsed_page = parse_page_file(@page.url, @page_file)
      upload_parsed_page_to_s3(@page.url, parsed_page)
      persist_parsed_page(@page, parsed_page)
      result.succeed!
    end

    private

    def parse_page_file(url, page_file)
      command = ParsePageFile.new(url, page_file)
      command.run_with_gc!
      command.payload
    end

    def persist_parsed_page(page, parsed_page)
      command = PersistParsedPage.new(page, parsed_page)
      command.run_with_gc!
    end

    def upload_parsed_page_to_s3(url, parsed_page)
      command = UploadParsedPageToS3.new(url, parsed_page)
      command.run_with_gc!
      command.payload
    end
  end
end
