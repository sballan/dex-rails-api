module FetchService::Commands
  class InsertLinks < Command::Abstract
    def initialize(page, parsed_page)
      super()
      @page = page
      @links_by_url = {}

      parsed_page[:links].each do |link|
        @links_by_url[link[:url]] = link
      end

      @links_by_url.each do |url, link|
        link.delete(:url)
        link[:text] = link[:text] || ""
        link[:from_id] = @page.id
      end
    end

    def run_proc
      # This is strange...but we're managing stupid timestamps here. For some reason I can't seem
      # to get default values for timestamps.  For now - we need to include created at and updated at.
      # Since we're doing unique by url, this will only create new pages (not affect existing ones), so this is safe.
      #
      # Rails does have "returning", but only works for postgres.  That's why we fetch_to_ids after this statement
      Page.insert_all(page_insert_attributes, unique_by: :url)
      fetch_to_ids
      Link.insert_all(@links_by_url.values, unique_by: :index_links_on_to_id_and_from_id_and_text)

      result.succeed!
    end

    private

    def fetch_to_ids
      # Once pages have been inserted, we can get all the ids and urls we need in a single query
      Page.where(url: @links_by_url.keys).in_batches do |pages|
        pages.pluck(:id, :url).each do |page|
          @links_by_url[page.second][:to_id] = page.first
        end
      end
    end

    def page_insert_attributes
      @links_by_url.map do |url, link|
        { url: url }
      end
    end
  end
end
