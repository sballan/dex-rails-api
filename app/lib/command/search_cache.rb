module Command
  class SearchCache < Command::Base::Abstract
    def initialize(text)
      super()
      @text = text.downcase
    end

    def run_proc
      matches_set = Set.new
      text_words = @text.split(/\s/)

      matches_set << @text
      matches_set.merge(text_words)

      cache_hits = {}

      matches_set.each do |match|
        command = Command::DownloadQueryResults.new match
        run_nested(command)
        if(command.success? && command.payload.present?)
          raw_response = command.result.payload
          parsed_response = JSON.parse(raw_response)
          cache_hits[match] = parsed_response
        else
          Rails.logger.warn "Could not find match for #{match}"
        end
      end

      result.succeed!(cache_hits)
    end
  end
end