module FetchService::Commands
  class DownloadMechanizePage < Command::Abstract
    def initialize(url)
      super()
      @url = url
      @mechanize_page = nil
    end

    def run_proc
      raise Command::Errors::CommandFailed, "Page is nil" if mechanize_page.nil?
      raise Command::Errors::CommandInvalid, "Only html pages are supported" unless mechanize_page.is_a?(Mechanize::Page)

      result.succeed!(mechanize_page)
    rescue Mechanize::RobotsDisallowedError => e
      command_error = Command::Errors::CommandInvalid.new "Robots cannot scrape this page", e
      raise command_error # We raise this since we cannot do anything else with an invalid command.
    rescue Mechanize::ResponseCodeError => e
      command_error = Command::Errors::CommandFailed.new "Bad response code", e
      raise command_error # We raise this since we cannot do anything else with an invalid command.
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
