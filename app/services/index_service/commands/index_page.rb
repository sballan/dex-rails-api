module IndexService::Commands
  class IndexPage < Command::Abstract
    def initialize(page, level)
      super()
      @page = page
      @level = level
    end

    def run_proc
      Rails.logger.debug "Starting IndexPage for Page(#{@page.id})"

      parsed_page = FetchService::Client.download_parsed_page(@page)

      index_title(parsed_page)
      index_links unless @level < 2
      index_headers(parsed_page) unless @level < 4

      Rails.logger.debug "Finished IndexPage for Page(#{@page.id})"

      result.succeed!
    end

    private

    def index_title(parsed_page)
      Rails.logger.debug "Starting IndexPage.index_title for Page(#{@page.id})"

      title = parsed_page[:title]
      return unless title.present?

      if @level == 0
        index_page_text(title, "title", 1, 0)
      elsif @level >= 1
        index_page_text(title, "title", 10, 3)
      end
    end

    def index_links
      Rails.logger.debug "Starting IndexPage.index_links for Page(#{@page.id})"
      link_texts = @page.links_to.where.not(text: [nil, ""]).pluck(:text)
      return if link_texts.blank?

      link_texts.each do |link_text|
        if @level == 2
          index_page_text(link_text, "link", 1, 0)
        elsif @level >= 3
          index_page_text(link_text, "link", 3, 2)
        end
      end
    end

    def index_headers(parsed_page)
      Rails.logger.debug "Starting IndexPage.index_headers for Page(#{@page.id})"

      parsed_page[:headers].each do |header|
        if @level == 4
          index_page_text(header, "header", 1, 0)
        elsif @level >= 5
          index_page_text(header, "header", 2, 1)
        end
      end
    end

    def index_page_text(text, kind, max_length, max_distance)
      command = IndexPageText.new(
        @page,
        text,
        kind,
        max_length,
        max_distance
      )
      command.run_with_gc!
    end
  end
end
