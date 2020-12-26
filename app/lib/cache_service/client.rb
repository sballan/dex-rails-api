module CacheService
  module Client
    extend self

    def cache_batch(size)
      Query.next_to_cache.includes(:page_matches).limit(size).in_batches(of: 50).each_record do |query|
        command = Commands::CacheQueryAndPageMatches.new(query)
        command.run_with_gc!
      end
    end

    def download_page_matches(query_text)
      command = Commands::DownloadPageMatchesFromS3.new(query_text)
      command.run!
      command.payload
    end
  end
end