module CacheService
  module Client
    extend self

    def cache_query(query)
      command = Commands::CacheQueryAndPageMatches.new(query)
      command.run_with_gc!
    end

    def download_page_matches(query_text)
      command = Commands::DownloadPageMatchesFromS3.new(query_text)
      command.run!
      command.payload
    end
  end
end
