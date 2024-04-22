module RankService::Commands
  class Calculate < Command::Abstract
    def initialize(rank_pages, db_page_count)
      super()
      @rank_pages = rank_pages
      @db_page_count = db_page_count
    end

    def run_proc
      matrix = RankService::Matrix.new @rank_pages, @db_page_count
      matrix.generate_matrix
      matrix.iterate_times(50)
      result.succeed!(matrix.rank_pages)
    end
  end
end
