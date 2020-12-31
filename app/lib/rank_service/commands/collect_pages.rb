module RankService::Commands
  class CollectPages < Command::Abstract
    def initialize(start_page, max_pages)
      super()
      @start_page = start_page
      @max_pages = max_pages
    end

    def run_proc
      pages = {}
      current_page = @start_page
      pages[current_page.id] = {
        page: current_page,
        links_added: false
      }

      while current_page.present? && pages.size < @max_pages
        break unless (pages.size + current_page.links_from.count) < @max_pages

        current_page.links_from.includes(:from).each do |link|
          pages[link.from.id] ||= {
            page: link.from,
            links_added: false
          }
          break unless pages.size < @max_pages
        end

        Rails.logger.debug "Added page #{current_page.url}"

        pages[current_page.id][:links_added] = true
        current_page = pages.find {|k, v| v[:links_added] == false}
        current_page = current_page.blank? ? nil : current_page.last[:page]
      end

      result.succeed!(pages.map {|k, v| v[:page] })
    end
  end
end