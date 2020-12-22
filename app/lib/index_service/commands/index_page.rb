module IndexService::Commands
  class IndexPage < Command::Base::Abstract
    def initialize(page, level)
      super()
      @page = page
      @level = level
    end

    def run_proc
      parsed_page = ParseService::Client.download_cached_parsed_page(@page)

      result.succeed!
    end

    private



  end
end
