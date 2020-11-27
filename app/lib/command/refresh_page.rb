module Command
  class RefreshPage < Command::Base::Abstract
    def initialize(url)
      super()
      @url = url
    end

    def run_proc
      body = page_content
      client = S3Client.new(ENV['DEV_BUCKET'], 'page_files')
      key = Base64.urlsafe_encode64(@url)
      client.write_private(key: key, body: body)
      result.succeed!
    end

    private

    def page_content
      mechanize_page = mechanize_agent.get(@url)
      Rails.logger.debug "Downloaded url: #{@url}"
      doc = mechanize_page.parser
      doc.xpath('//script').remove
      doc.xpath('//style').remove
      doc.to_html.force_encoding('UTF-8')
    end

    def mechanize_agent
      mechanize_agent = Mechanize.new
      mechanize_agent.history.max_size = 1 # default is 50
      mechanize_agent.robots = true
      mechanize_agent
    end
  end
end