module Command
  class RefreshScrapePage < Command::Base::Abstract
    def initialize(scrape_page)
      super()
      @scrape_page = scrape_page
    end

    def run_proc
      handle_start!

      body = page_content
      client = S3Client.new(ENV['DEV_BUCKET'], 'page_files')
      url = @scrape_page.page.url
      key = Base64.urlsafe_encode64(url)
      client.write_private(key: key, body: body)

      handle_success!
      result.succeed!(@scrape_page)
    rescue StandardError => e
      Rails.logger.error "RefreshScrapePage failed for ScrapePage #{@scrape_page.id}"
      handle_failure
      result.fail!(e)
      raise e
    end

    private

    def handle_start!
      @scrape_page.active!
      @scrape_page.refresh_active!
      @scrape_page.started_at = DateTime.now.utc
      @scrape_page.refresh_started_at = DateTime.now.utc
      @scrape_page.save!
    end

    def handle_failure
      @scrape_page.refresh_failure!
      @scrape_page.failure!
      @scrape_page.finished_at = DateTime.now.utc
      @scrape_page.refresh_finished_at = DateTime.now.utc
      @scrape_page.save
    end

    def handle_success!
      @scrape_page.refresh_success!
      @scrape_page.success!
      @scrape_page.finished_at = DateTime.now.utc
      @scrape_page.refresh_finished_at = DateTime.now.utc
      @scrape_page.save!
    end

    def page_content
      mechanize_page = mechanize_agent.get(@scrape_page.page.url)
      Rails.logger.debug "Downloaded url: #{@scrape_page.page.url}"
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