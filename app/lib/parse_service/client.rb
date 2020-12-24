module ParseService
  module Client
    extend self

    def parse_page(page)
      handle_parse_start(page)

      page_file = RefreshService::Client.refresh_page(page)
      parsed_page = parse_page_file(page.url, page_file)
      persist_parsed_page(page, parsed_page)

      handle_parse_success(page)
    rescue StandardError => e
      handle_parse_failure(page)
      raise e
    end

    def download_cached_parsed_page(page)
      command = Commands::DownloadParsedPageFromS3.new(page.url)
      command.run!
      command.payload
    end

    private

    def parse_page_file(url, page_file)
      command = Commands::ParsePageFile.new(url, page_file)
      command.run!
      command.payload
    end

    def persist_parsed_page(page, parsed_page)
      command = Commands::PersistParsedPage.new(page, parsed_page)
      command.run!
    end

    def upload_parsed_page_to_s3(key, body)
      command = Commands::UploadParsedPageToS3.new(key, body)
      command.run_with_gc!
      command.payload
    end
    def handle_parse_start(page)
      page.parse_status = :active
      page.parse_started_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Starting parse for Page(#{page.id})"
    end

    def handle_parse_failure(page)
      page.parse_status = :failure
      page.parse_finished_at = DateTime.now.utc
      page.save

      Rails.logger.info "Parse failed for Page(#{page.id})"
    end

    def handle_parse_success(page)
      page.parse_status = :success
      page.parse_finished_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Parse succeeded for Page(#{page.id})"
    end
  end
end