module FetchService::Commands
  class RefreshPage < Command::Abstract
    def initialize(page)
      super()
      @page = page
    end

    def run_proc
      mechanize_page = mechanize_page @page
      page_file = process_file(mechanize_page)

      key = @page.url

      if page_file.present?
        upload_page_file_to_s3(key, page_file)
        result.succeed!(page_file)
      else
        Rails.logger.info "Got a nil page_file - Page should be marked as dead."
        result.succeed!(nil)
      end
    end

    private

    def mechanize_page(page)
      command = DownloadMechanizePage.new(page.url)
      command.run_with_gc!
      command.payload
    rescue Command::Errors::CommandInvalid => e
      Rails.logger.warn "This Page failed permanently to download #{page.id}."
      page.refresh_status = :dead
      page.refresh_finished_at = DateTime.now.utc
      page.save
      nil
    rescue Command::Errors::CommandFailed => e
      Rails.logger.error "This ScrapePage failed to download #{page.id}"
      page.refresh_status = :failure
      page.save
      raise e
    end

    def process_file(mechanize_page)
      return nil if mechanize_page.nil?

      nokogiri_doc = mechanize_page.parser
      command = ProcessNokogiriDoc.new(nokogiri_doc)
      command.run_with_gc!
      command.payload
    end

    def upload_page_file_to_s3(key, body)
      command = UploadPageFileToS3.new(key, body)
      command.run_with_gc!
      command.payload
    end
  end
end
