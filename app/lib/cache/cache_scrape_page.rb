module Cache
  class CacheScrapePage < Command::Base::Abstract
    def initialize(scrape_page)
      super()
      @scrape_page = scrape_page
    end

    def run_proc
      cache_title
      cache_links
      cache_body

      result.succeed!
    end

    private

    def cache_title
      if @scrape_page.page.title.blank?
        Rails.logger.debug "ScrapePage (#{@scrape_page.id}) belongs to a page with no title. Not caching."
        return
      end
      cache_atts = [{page_id: @scrape_page.page.id, text: @scrape_page.page.title, kind: 'title'}]
      insert_command = Cache::InsertQueriesAndResults.new(cache_atts)
      run_nested_with_gc!(insert_command)

      query_ids = command.payload
      cache_command = Cache::CacheQueryAndResults.new(query_ids.first)
      run_nested_with_gc!(cache_command)
    end

    def cache_links
      link_texts = @scrape_page.page.links_to.where.not(text: [nil, ""]).pluck(:text)

      if link_texts.empty?
        Rails.logger.debug "ScrapePage (#{@scrape_page.id}) belongs to a page with no links_to. Not caching."
        return
      end

      cache_atts = link_texts.map do |link_text|
        {
            page_id: @scrape_page.page.id,
            text: link_text,
            kind: 'link'
        }
      end
      command = Cache::InsertQueriesAndResults.new(cache_atts)
      run_nested_with_gc!(command)

      query_ids = command.payload

      cache_command = Cache::BatchCacheQueryAndResults.new(query_ids)
      run_nested_with_gc!(cache_command)
    end

    def cache_body
      fetch_command = Parse::FetchPageFile.new(@scrape_page.page.url)
      run_with_gc!(fetch_command)

      doc = Nokogiri::HTML(fetch_command.payload)
      doc.xpath('//script').remove
      doc.xpath('//style').remove

      page_content = Html2Text.convert doc.to_html.force_encoding('UTF-8')
      page_words = page_content.downcase.split(' ')

      query_ids = Query.where(text: page_words).pluck(:id)

      if query_ids.empty?
        Rails.logger.debug "ScrapePage (#{@scrape_page.id}) has a page file that does not contain any words that match queries in our database.  Not caching."
        return
      end

      result_atts = query_ids.map {|q_id|  {query_id: q_id, page_id: @scrape_page.page.id, kind: 'body'} }
      Result.insert_all(result_atts, unique_by: :index_results_on_query_id_and_page_id_and_kind)

      cache_command = Cache::BatchCacheQueryAndResults.new(query_ids)
      run_nested_with_gc!(cache_command)
    end

  end
end