module RankService
  module Client
    extend self

    def rank_from_start_page(start_page, max_size)
      rank_pages = collect_pages(start_page, max_size)
      calculate(rank_pages)

    end

    private

    def collect_pages(start_page, max_size)
      command = Commands::CollectPages.new(start_page, max_size)
      command.run!
      command.payload
    end

    def calculate(rank_pages)
      command = Commands::Calculate.new(rank_pages)
      command.run!
    end
  end
end
