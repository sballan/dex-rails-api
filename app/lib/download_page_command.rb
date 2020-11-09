class DownloadPageCommand
  attr_reader :page, :result

  # @param [Page] page
  def initialize(page)
    @page = page
    @result = {
        status: :failure,
        payload: nil
    }
  end

  def execute
    require 'pry'; binding.pry
    mechanize_agent = Mechanize.new
    mechanize_agent.history.max_size = 5 # default is 50
    mechanize_agent.robots = true

    mechanize_page = mechanize_agent.get(page.url)
    raise 'Page is nil' if mechanize_page.nil?
    raise 'Only html pages are supported' unless mechanize_page.is_a?(Mechanize::Page)

    page_file = StringIO.new mechanize_page.body.encode(
        'UTF-8', invalid: :replace, undef: :replace, replace: ''
    )

    client = S3Client.new(ENV['DEV_BUCKET'])
    client.write_private(key: page.id, body: page_file)

    page.download_success = DateTime.now.utc
    @result[:status] = :success
  rescue Mechanize::RobotsDisallowedError, Mechanize::ResponseCodeError => e
    page.download_invalid = DateTime.now.utc
    page.save

    raise
  end
end
