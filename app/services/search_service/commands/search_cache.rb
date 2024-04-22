module SearchService::Commands
  class SearchCache < Command::Abstract
    def initialize(text)
      super()
      @text = text.present? ? text.downcase : ""
    end

    def run_proc
      matches_set = Set.new
      text_words = @text.split(/\s/)

      matches_set << @text
      matches_set.merge(text_words)

      cache_hits = {}

      matches_set.each do |match|
        page_matches = CacheService::Client.download_page_matches(match)

        if page_matches.present?
          cache_hits[match] = page_matches
        else
          Rails.logger.debug "Could not find match for #{match}"
        end
      end

      result.succeed!(cache_hits)
    end
  end
end
