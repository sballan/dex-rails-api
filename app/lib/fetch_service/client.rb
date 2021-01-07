require 'net/http'

module FetchService
  module Client
    extend self

    # @param [Page] page
    def fetch(page)
      page.meta.update!(
        fetch_status: :active,
        fetch_started_at: DateTime.now.utc,
        fetch_finished_at: nil
      )

      page_file = nil
      host = URI(page.url).host
      ActiveLock::Lock.with_lock("Host/#{host}") do
        page_file = refresh_page(page)
        sleep 2
      end

      return nil if page_file.blank?

      parse_page(page, page_file)

      page.meta.update!(
        crawl_status: :ready,
        fetch_status: :success,
        fetch_finished_at: DateTime.now.utc
      )

    rescue => e
      page.meta.update!(
        fetch_status: :failure,
        fetch_finished_at: DateTime.now.utc
      )

      raise e
    end


    private

    def refresh_page(page)
      command = Commands::RefreshPage.new(page)
      command.run!
      page_file = command.payload

      return page_file unless page_file.blank?

      Rails.logger.info "Page(#{page.url}) is blank, marking as dead"

      page.meta.update!(
        fetch_status: :dead,
        fetch_finished_at: DateTime.now.utc
      )

      nil
    end

    def parse_page(page, page_file)
      command = Commands::ParsePage.new(page, page_file)
      command.run!
      command.payload
    end
  end
end
