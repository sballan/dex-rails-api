module IndexService
  MAX_INDEX_PAGES = ENV.fetch("MAX_INDEX_PAGES", 5).to_i.seconds
  MAX_INDEX_TIME = ENV.fetch("MAX_INDEX_TIME", 6.hours).to_i.seconds

  module Client
    extend self

    def tick(&block)
      # Update old PageMeta to have failed status. The assumption is that pages indexing longer than
      # the MAX_INDEX_TIME are actually not running.
      PageMeta.where(index_status: :active, index_started_at: DateTime.new(0)..MAX_INDEX_TIME.ago)
          .update_all(index_status: :failure, index_finished_at: DateTime.now.utc)

      num_active_pages = PageMeta.index_active.count
      num_additional_pages = MAX_INDEX_PAGES - num_active_pages


      meta = PageMeta.index_ready.limit(num_additional_pages)
      meta.update(index_status: :active, index_started_at: DateTime.now.utc)
      page_ids = meta.pluck(:id)

      block.call(page_ids)
    end

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
      parsed_page = FetchService::Client.download_parsed_page(page)

      title = parsed_page[:title]
      return unless title.present?

      index_page_text(page, title, "title", max_length, max_distance)

      page.meta.update(indexed_title: true)
    end

    def index_page_links(page, max_length=3, max_distance=2)
      link_texts = page.links_to.where.not(text: [nil, ""]).pluck(:text)
      return if link_texts.blank?

      link_texts.each do |link_text|
          index_page_text(page, link_text, "link", max_length, max_distance)
      end

      page.meta.update(indexed_links: true)
    end

    def index_page_headers(page, max_length=5, max_distance=2)
      parsed_page = FetchService::Client.download_parsed_page(page)

      parsed_page[:headers].each do |header|
          index_page_text(page, header, "header", max_length, max_distance)
      end

      page.meta.update(indexed_headers: true)
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