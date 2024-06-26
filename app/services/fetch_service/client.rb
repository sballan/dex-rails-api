require "net/http"

module FetchService
  MAX_FETCH_TIME = ENV.fetch("MAX_FETCH_TIME", 1.hour).to_i.seconds
  MAX_REFRESH_TIME = ENV.fetch("MAX_REFRESH_TIME", 10.minutes).to_i.seconds

  module Client
    extend self

    # Typically, Page fetching is queued by a crawl...EXCEPT for when a Site needs to get fetched.
    def tick(&block)
      PageMeta.where(fetch_status: :active, fetch_started_at: DateTime.new(0)..MAX_FETCH_TIME.ago)
        .update_all(fetch_status: :failure, fetch_finished_at: DateTime.now.utc)

      # NOTE: This is the pain we have for not putting site_id on Page. Still not sure about this decision.
      page_ids =
        Site.where(scrape_active: true)
          .all
          .map do |s|
          s.fetch_home_page
        end.select do |p|
          p.meta.fetch_ready?
        end.map(&:id)

      block.call(page_ids)
    end

    # @param [Page] page
    def fetch(page)
      page.update!(meta_attributes: {
        fetch_status: :active,
        fetch_started_at: DateTime.now.utc,
        fetch_finished_at: nil
      })

      page_file = nil
      host = URI(page.url).host
      ActiveLock::Lock.with_lock("Host/#{host}", nil, ttl: MAX_REFRESH_TIME) do
        page_file = refresh_page(page)
        sleep 2 # does this give some extension time to finish releaseing memory or something?
      end

      return nil if page_file.blank?

      parse_page(page, page_file)

      page.update!(meta_attributes: {
        index_status: :ready,
        crawl_status: :ready,
        fetch_status: :success,
        fetch_finished_at: DateTime.now.utc
      })
    rescue => e
      page.update!(meta_attributes: {
        fetch_status: :failure,
        fetch_finished_at: DateTime.now.utc
      })

      raise e unless e.is_a?(Command::Errors::CommandFailed)
    end

    def download_parsed_page(page)
      command = Commands::DownloadParsedPageFromS3.new(page.url)
      command.run!
      command.payload
    end

    private

    def refresh_page(page)
      command = Commands::RefreshPage.new(page)
      command.run_with_gc!
      page_file = command.payload

      return page_file unless page_file.blank?

      Rails.logger.info "Page(#{page.url}) is blank, marking as dead"

      page.update!(meta_attributes: {
        fetch_status: :dead,
        fetch_finished_at: DateTime.now.utc
      })

      nil
    end

    def parse_page(page, page_file)
      command = Commands::ParsePage.new(page, page_file)
      command.run_with_gc!
      command.payload
    end
  end
end
