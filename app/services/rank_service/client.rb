module RankService
  module Client
    extend self

    def tick
    end

    def rank_from_start_page(start_page, max_size)
      GC.start full_mark: true, immediate_sweep: true
      GC.compact

      rank_pages = collect_pages(start_page, max_size)
      calculate(rank_pages)
      update_pages(rank_pages)

      GC.start full_mark: true, immediate_sweep: true
      GC.compact
    end

    private

    def collect_pages(start_page, max_size)
      command = Commands::CollectPages.new(start_page, max_size)
      command.run_with_gc!
      command.payload
    end

    def calculate(rank_pages)
      command = Commands::Calculate.new(rank_pages)
      command.run!
    end

    def update_pages(rank_pages)
      command = Commands::UpdatePages.new(rank_pages)
      command.run_with_gc!
    end
  end
end
