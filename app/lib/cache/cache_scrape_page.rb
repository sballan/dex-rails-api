module Cache
  class CacheScrapePage
    # @param [Page] page
    def initialize(scrape_page)
      super()
      @scrape_page = scrape_page
    end

    def run_proc
      create_title_query

      @page.links_to.where.not(text: [nil, ""]).in_batches.each_record do |link|
        create_link_queries(link)
      end

      create_body_queries

      result.succeed!
    end

    private

    def create_title_query
      create_or_find_query_command = Command::CreateOrFindQuery.new(@page.title)
      run_nested!(create_or_find_query_command)
      query = create_or_find_query_command.payload

      create_or_find_result_command = Command::CreateOrFindResult.new(query, @page, 'title')
      run_nested!(create_or_find_result_command)
    end

    def create_link_queries(link)
      create_or_find_query_command = Command::CreateOrFindQuery.new(link.text)
      run_nested!(create_or_find_query_command)
      query = create_or_find_query_command.payload

      create_or_find_result_command = Command::CreateOrFindResult.new(query, @page, 'link')
      run_nested!(create_or_find_result_command)
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