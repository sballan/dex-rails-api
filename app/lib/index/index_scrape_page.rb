module Index
  class IndexScrapePage < Command::Base::Abstract
    def initialize(scrape_page)
      super()
      @scrape_page = scrape_page
    end

    def run_proc
      query_ids_set = Set.new

      query_ids_set.merge(title_queries)
      query_ids_set.merge(links_queries)
      query_ids_set.merge(body_queries)

      handle_success!
      result.succeed!
    end

    private

    def handle_success!
      @scrape_page.index_status = :success
      @scrape_page.index_finished_at = DateTime.now.utc
      @scrape_page.save!

      Rails.logger.info "IndexScrapePage succeeded for ScrapePage #{@scrape_page.id}"
    end

    def title_queries
      if @scrape_page.page.title.blank?
        Rails.logger.debug "ScrapePage (#{@scrape_page.id}) belongs to a page with no title. Not indexing."
        return
      end
      index_atts = [{page_id: @scrape_page.page.id, text: @scrape_page.page.title, kind: 'title'}]
      insert_command = Index::InsertQueriesAndResults.new(index_atts)
      run_nested_with_gc!(insert_command)

      insert_command.payload
    end

    def links_queries
      link_texts = @scrape_page.page.links_to.where.not(text: [nil, ""]).pluck(:text)

      if link_texts.empty?
        Rails.logger.debug "ScrapePage (#{@scrape_page.id}) belongs to a page with no links_to. Not indexing."
        return
      end

      index_atts = link_texts.map do |link_text|
        {
            page_id: @scrape_page.page.id,
            text: link_text,
            kind: 'link'
        }
      end
      insert_command = Index::InsertQueriesAndResults.new(index_atts)
      run_nested_with_gc!(insert_command)

      insert_command.payload
    end

    def body_queries
      fetch_command = Parse::FetchPageFile.new(@scrape_page.page.url)
      run_nested_with_gc!(fetch_command)

      doc = Nokogiri::HTML(fetch_command.payload)
      doc.xpath('//script').remove
      doc.xpath('//style').remove

      page_content = Html2Text.convert doc.to_html.force_encoding('UTF-8')
      page_words = page_content.downcase.split(' ')

      query_ids = Query.where(text: page_words).pluck(:id)

      if query_ids.empty?
        Rails.logger.debug "ScrapePage (#{@scrape_page.id}) has a page file that does not contain any words that match queries in our database.  Not indexing."
        return
      end

      result_atts = query_ids.map do |q_id|
        {
          query_id: q_id,
          page_id: @scrape_page.page.id,
          kind: 'body',
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        }
      end
      Result.insert_all(result_atts, unique_by: :index_results_on_query_id_and_page_id_and_kind)

      query_ids
    end
  end
end