module Command
  class DownloadUrl < Command::Base::Abstract
    def initialize(url)
      @url = url
      @mechanize_page = nil

      @result = Command::Base::Result.new
    end

    def run
      raise 'Page is nil' if mechanize_page.nil?
      raise 'Only html pages are supported' unless mechanize_page.is_a?(Mechanize::Page)

      # NOTE: We read this into a string, which should be fine
      page_file = StringIO.new(mechanize_page.body.encode(
        'UTF-8', invalid: :replace, undef: :replace, replace: ''
      )).read
      result.succeed!(page_file)
    rescue Mechanize::RobotsDisallowedError, Mechanize::ResponseCodeError => e
      result.fail!(e)
    end

    private

    def mechanize_page
      return @mechanize_page unless @mechanize_page.nil?

      mechanize_agent = Mechanize.new
      mechanize_agent.history.max_size = 2 # default is 50
      mechanize_agent.robots = true
      @mechanize_page = mechanize_agent.get(@url)
    end
  end
end
