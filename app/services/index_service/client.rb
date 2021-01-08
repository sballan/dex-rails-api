module IndexService
  module Client
    extend self

    def index_page(page, level)
      handle_index_start(page)
      command = Commands::IndexPage.new(page, level)
      command.run_with_gc!
      handle_index_success(page)
    rescue StandardError => e
      handle_index_failure(page)
      raise e
    end

    def index_page_title(page, max_length=5, max_distance=5)
      parsed_page = ParseService::Client.download_cached_parsed_page(page)

      title = parsed_page[:title]
      return unless title.present?

      index_page_text(page, title, "title", max_length, max_distance)
    end

    def index_page_links(page, max_length=3, max_distance=2)
      link_texts = page.links_to.where.not(text: [nil, ""]).pluck(:text)
      return if link_texts.blank?

      link_texts.each do |link_text|
          index_page_text(page, link_text, "link", max_length, max_distance)
      end
    end

    def index_page_headers(page, max_length=5, max_distance=2)
      parsed_page = ParseService::Client.download_cached_parsed_page(page)

      parsed_page[:headers].each do |header|
          index_page_text(page, header, "header", max_length, max_distance)
      end
    end

    private

    def index_page_text(page, text, kind, max_length, max_distance)
      command = Commands::IndexPageText.new(
          page,
          text,
          kind,
          max_length,
          max_distance
      )
      command.run_with_gc!
    end

    def handle_index_start(page)
      page.index_status = :active
      page.index_started_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Starting index for Page(#{page.id})"
    end

    def handle_index_failure(page)
      page.index_status = :failure
      page.index_finished_at = DateTime.now.utc
      page.save

      Rails.logger.info "Index failed for Page(#{page.id})"
    end

    def handle_index_success(page)
      page.index_status = :success
      page.index_finished_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Index succeeded for Page(#{page.id})"
    end


  end
end