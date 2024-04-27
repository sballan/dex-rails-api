module CacheService::Commands
  class CacheQueryAndPageMatches < Command::Abstract
    def initialize(query)
      super()
      @query = query
    end

    def run_proc
      json = generate_results.to_json
      cache_result_json(json)

      @query.cached_at = DateTime.now.utc
      @query.save!

      Rails.logger.info "CacheQueryAndResults succeeded for Query #{@query.id}"
      result.succeed!(json)
    end

    def cache_result_json(json)
      command = UploadPageMatchesToS3.new(@query.text, json)
      command.run!

      if command.success?
        @query.cached_at = DateTime.now.utc
        @query.save!
      end
    end

    def generate_results
      # TODO: We need to page these page_matches somehow
      @query.page_matches.joins(:page).includes(:page).where.not(pages: {rank: nil}).order("pages.rank DESC").limit(50).map do |page_match|
        {
          text: @query.text,
          distance: page_match.distance,
          length: page_match.length,
          kind: page_match.kind,
          full: page_match.full,
          page: {
            url: page_match.page.url,
            title: page_match.page.title,
            rank: page_match.page.rank || 0
          }
        }
      end

      # This is the old Query, which I had for years.  I kept it for posterity, the new query should be more correct
      # query.page_matches.includes(:page).limit(50).map do |page_match|
      #   {
      #     text: query.text,
      #     distance: page_match.distance,
      #     length: page_match.length,
      #     kind: page_match.kind,
      #     full: page_match.full,
      #     page: {
      #       url: page_match.page.url,
      #       title: page_match.page.title,
      #       rank: page_match.page.rank || 0
      #     }
      #   }
      # end.sort_by { |pm| pm[:page][:rank] }.reverse
    end
  end
end
