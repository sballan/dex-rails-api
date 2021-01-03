module RankService::Commands
  class CollectPages < Command::Abstract
    def initialize(start_page, max_pages)
      super()
      @start_page = start_page
      @max_pages = max_pages
    end

    def run_proc
      pages_map = {}
      current_page = @start_page
      pages_map[current_page.id] = {
        page: current_page,
        links_added: false
      }

      while current_page.present? && pages_map.size < @max_pages
        break unless (pages_map.size + current_page.links_from.count) < @max_pages

        current_page.links_from.includes(:from).each do |link|
          pages_map[link.from.id] ||= {
            page: link.from,
            links_added: false
          }
          break unless pages_map.size < @max_pages
        end

        Rails.logger.debug "Added page #{current_page.url}"

        pages_map[current_page.id][:links_added] = true
        current_page = pages_map.find {|_k, v| v[:links_added] == false}
        current_page = current_page.blank? ? nil : current_page.last[:page]
      end

      rank_pages = convert_pages(pages_map)

      result.succeed!(rank_pages)
    end

    private

    def convert_pages(pages_map)
      rank_pages = {}

      pages_map.each_with_index do |o, i|
        id = o.first
        position = i + 1
        start_rank = o.last[:page].rank || 1.0 / pages_map.size
        rank_pages[id] ||= RankService::Page.new(id: id, position: position, start_rank: start_rank)
      end

      pages_map.each do |k, v|
        next unless v[:links_added]
        v[:page].links_from.pluck(:from_id).each do |from_id|
          next unless rank_pages[from_id].present?
          back_link_page = rank_pages[from_id]
          back_link_position = back_link_page.position
          rank_pages[k].back_links[back_link_position] = back_link_page
        end
      end

      rank_pages.values
    end
  end
end