module Cache
  class CacheScrapePage < Command::Base::Abstract
    def initialize(scrape_page)
      super()
      @scrape_page = scrape_page
    end

    def run_proc
      cache_title
      cache_links

      create_body_queries

      result.succeed!
    end

    private

    def cache_title
      cache_atts = [{page_id: @page.id, text: @page.title, kind: 'title'}]
      command = Cache::InsertQueriesAndResults.new(cache_atts)
      run_nested_with_gc!(command)
    end

    def cache_links
      link_texts = @page.links_to.where.not(text: [nil, ""]).pluck(:text)
      cache_atts = link_texts.map do |link_text|
        {
            page_id: @page.id,
            text: link_text,
            kind: 'link'
        }
      end
      command = Cache::InsertQueriesAndResults.new(cache_atts)
      run_nested_with_gc!(command)
    end

    def create_body_queries
      return if @mechanize_page.nil?
      doc = @mechanize_page.parser
      doc.xpath('//script').remove
      doc.xpath('//style').remove

      page_content = Html2Text.convert doc.to_html.force_encoding('UTF-8')
      page_words = page_content.downcase.split(' ')

      Query.where(text: page_words).in_batches.each_record do |query|
        create_or_find_result_command = Command::CreateOrFindResult.new(query, @page, 'body')
        run_nested!(create_or_find_result_command)
      end
    end

  end
end