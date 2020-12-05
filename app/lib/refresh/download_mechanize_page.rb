module Refresh
  class DownloadMechanizePage < Command::Base::Abstract
    def initialize(url)
      super()
      @url = url
      @mechanize_page = nil
    end

    def run_proc
      raise Command::Base::Errors::CommandFailed, 'Page is nil' if mechanize_page.nil?
      raise Command::Base::Errors::CommandInvalid, "Only html pages are supported" unless mechanize_page.is_a?(Mechanize::Page)

      result.succeed!(mechanize_page)
    rescue Mechanize::RobotsDisallowedError, Mechanize::ResponseCodeError => e
      result.fail!(e)
    end

    private

    def mechanize_page
      return @mechanize_page unless @mechanize_page.nil?

      mechanize_agent = Mechanize.new
      mechanize_agent.history.max_size = 1 # default is 50
      mechanize_agent.robots = true
      @mechanize_page = mechanize_agent.get(@url)
    end
  end
end
