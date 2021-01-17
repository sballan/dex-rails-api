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
      command.run!
      command.payload
    rescue Command::Errors::CommandInvalid => e
      Rails.logger.warn "This Page failed permanently to download #{page.id}."
      nil
    rescue Command::Errors::CommandFailed => e
      Rails.logger.error "This ScrapePage failed to download #{page.id}"
      page.save
      raise e
    end

    def process_file(mechanize_page)
      return nil if mechanize_page.nil?

      nokogiri_doc = mechanize_page.parser
      command = ProcessNokogiriDoc.new(nokogiri_doc)
      command.run!
      command.payload
    end

    def upload_page_file_to_s3(key, body)
      command = UploadPageFileToS3.new(key, body)
      command.run!
      command.payload
    end
  end
end
