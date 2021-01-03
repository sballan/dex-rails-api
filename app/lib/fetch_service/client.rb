require 'net/http'

module FetchService
  module Client
    extend self

    # @param [Page] page
    def soft_fetch(page)
      unless page.meta.present?
        page.update(meta_attributes: {})
      end

      if page.meta.fetch_success?
        Rails.logger.info "Soft refresh does not refresh pages that have status refresh success"
        return
      end

      page.meta.tap do |meta|
        meta.fetch_status = :active
        meta.fetch_started_at = DateTime.now.utc
        meta.save!
      end

      page_file = nil
      host = URI(page.url).host
      ActiveLock::Lock.with_lock("Host/#{host}") do
        page_file = refresh_page(page)
        sleep 1
      end

      if page_file.blank?
        Rails.logger.info "Page(#{page.url}) is blank, marking as dead"
        page.meta.tap do |meta|
          meta.fetch_status = :dead
          meta.fetch_finished = DateTime.now.utc
          meta.save!
        end

        return
      end

      parse_page(page, page_file)

      page.meta.tap do |meta|
        meta.fetch_status = :success
        meta.fetch_finished_at = DateTime.now.utc
        meta.save!
      end
    end

    private

    def refresh_page(page)
      command = Commands::RefreshPage.new(page)
      command.run!
      command.payload
    end

    def parse_page(page, page_file)
      command = Commands::ParsePage.new(page, page_file)
      command.run!
      command.payload
    end
  end
end
