module RefreshService
  module Client
    extend self

    def refresh_page(page, refresh_time=1.day.ago)
      if page.refresh_success? && (page.refresh_finished_at > refresh_time)
        return download_cached_page_file(page)
      end

      handle_refresh_start(page)

      mechanize_page = mechanize_page(page)
      page_file = process_file(mechanize_page)

      key = page.url
      body = page_file

      if body.present?
        upload_page_file_to_s3(key, body)
      else
        Rails.logger.info "Got a nil page_file - Page should be marked as dead."
        return nil
      end

      handle_refresh_success(page)

      body
    rescue => e
      handle_refresh_failure(page)
    end

    def download_cached_page_file(page)
      command = Commands::DownloadPageFileFromS3.new(page.url)
      command.run!
      command.payload
    end

    private

    def mechanize_page(page)
      command = Commands::DownloadMechanizePage.new(page.url)
      command.
      command.run_with_gc!
      command.payload
    rescue Command::Base::Errors::CommandInvalid => e
      Rails.logger.warn "This Page failed permanently to download #{page.id}."
      page.refresh_status = :dead
      page.refresh_finished_at = DateTime.now.utc
      page.save
      nil
    rescue Command::Base::Errors::CommandFailed => e
      Rails.logger.error "This ScrapePage failed to download #{page.id}"
      page.refresh_status = :failure
      page.save
      raise e
    end

    def process_file(mechanize_page)
      return nil if mechanize_page.nil?

      nokogiri_doc = mechanize_page.parser
      command = Commands::ProcessNokogiriDoc.new(nokogiri_doc)
      command.run_with_gc!
      command.payload
    end


    def upload_page_file_to_s3(key, body)
      command = Commands::UploadPageFileToS3.new(key, body)
      command.run_with_gc!
      command.payload
    end

    def handle_refresh_start(page)
      page.refresh_status = :active
      page.refresh_started_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Starting refresh for Page(#{page.id})"
    end

    def handle_refresh_failure(page)
      page.refresh_status = :failure
      page.refresh_finished_at = DateTime.now.utc
      page.save

      Rails.logger.info "Refresh failed for Page(#{page.id})"
    end

    def handle_refresh_success(page)
      page.refresh_status = :success
      page.refresh_finished_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Refresh succeeded for Page(#{page.id})"
    end
  end
end
