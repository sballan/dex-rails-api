module IndexService
  module Client
    extend self

    def index_page(page, level)
      command = Commands::IndexPage.new(page, level)
      command.run_with_gc!
    rescue StandardError => e
      handle_index_failure(page)
      raise e
    end

    private

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

    # def body_queries
    #   fetch_command = Parse::FetchPageFile.new(@scrape_page.page.url)
    #   run_nested_with_gc!(fetch_command)
    #
    #   doc = Nokogiri::HTML(fetch_command.payload)
    #   doc.xpath('//script').remove
    #   doc.xpath('//style').remove
    #
    #   page_content = Html2Text.convert doc.to_html.force_encoding('UTF-8')
    #   page_words = page_content.downcase.split(' ')
    #
    #   query_ids = Query.where(text: page_words).pluck(:id)
    #
    #   if query_ids.empty?
    #     Rails.logger.debug "ScrapePage (#{@scrape_page.id}) has a page file that does not contain any words that match queries in our database.  Not indexing."
    #     return []
    #   end
    #
    #   result_atts = query_ids.map do |q_id|
    #     {
    #       query_id: q_id,
    #       page_id: @scrape_page.page.id,
    #       kind: 'body',
    #       created_at: DateTime.now.utc,
    #       updated_at: DateTime.now.utc
    #     }
    #   end
    #   Result.insert_all(result_atts, unique_by: :index_results_on_query_id_and_page_id_and_kind)
    #
    #   query_ids
    # end
  end
end