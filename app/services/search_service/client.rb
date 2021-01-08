module SearchService
  module Client
    extend self

    def search_cache(search_string)
      command = Commands::SearchCache.new(search_string)
      command.run!
      command.payload
    end

    def search_db(search_string)
      command = Commands::SearchDb.new(search_string)
      command.run!
      command.payload
    end
  end
end
