module Refresh
  class RefreshScrapePage < Command::Base::Abstract
    def initialize(scrape_page)
      super()
      @scrape_page = scrape_page
    end

    def run_proc
      handle_start!

      Rails.logger.debug "[Refresh::RefreshScrapePage] Starting refresh: #{@scrape_page.page.url}"
      key = @scrape_page.page.url
      body = page_content

      if body.nil?
        Rails.logger.info "Got a nil page - scrape_page should be marked as dead."
        return nil
      end

      command = Refresh::UploadPageToS3.new(key, body)
      command.run_with_gc!
      command.payload
      Rails.logger.debug "[Refresh::RefreshScrapePage] Finished refresh #{@scrape_page.page.url}"

      handle_success!
      result.succeed!(@scrape_page)
    rescue StandardError => e
      Rails.logger.error "[Refresh::RefreshScrapePage] failed for ScrapePage #{@scrape_page.id}"
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

      Rails.logger.info "RefreshScrapePage succeeded for ScrapePage #{@scrape_page.id}"
    end

    def page_content
      return nil if mechanize_page.nil?

      nokogiri_doc = mechanize_page.parser
      command = Refresh::ProcessNokogiriDoc.new(nokogiri_doc)
      command.run_with_gc!
      command.payload
    end

    def mechanize_page
      command = Refresh::DownloadMechanizePage.new(@scrape_page.page.url)
      command.run_with_gc!
      command.payload
    rescue Command::Base::Errors::CommandInvalid => e
      Rails.logger.warn "[Refresh::RefreshScrapePage] This ScrapePage failed permanently to download #{(@scrape_page.id)}."
      @scrape_page.refresh_dead!
      @scrape_page.refresh_finished_at = DateTime.now.utc
      @scrape_page.save
      nil
    rescue Command::Base::Errors::CommandFailed => e
      Rails.logger.error "[Refresh::RefreshScrapePage] This ScrapePage failed to download #{(@scrape_page.id)}"
      @scrape_page.refresh_failure!
      @scrape_page.save
      raise e
    end
  end
end