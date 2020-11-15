module Command
  class DownloadUrl < Command::Abstract
    def initialize(url)
      @url = url
      @mechanize_page = nil

      @result = {
          status: :failure,
          payload: nil
      }
    end

    def run
      raise 'Page is nil' if mechanize_page.nil?
      raise 'Only html pages are supported' unless mechanize_page.is_a?(Mechanize::Page)

      page_file = StringIO.new mechanize_page.body.encode(
        'UTF-8', invalid: :replace, undef: :replace, replace: ''
      )
      @result[:status] = :success
      @result[:payload] = page_file
    rescue Mechanize::RobotsDisallowedError, Mechanize::ResponseCodeError => e
      @result[:status] = :failure
      @error = e
    end
  end

  private

  def mechanize_page
    return @mechanize_page unless @mechanize_agent.nil?

    mechanize_agent = Mechanize.new
    mechanize_agent.history.max_size = 2 # default is 50
    mechanize_agent.robots = true
    mechanize_agent
    @mechanize_page = mechanize_agent.get(url)
  end
end