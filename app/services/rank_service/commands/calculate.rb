module RankService::Commands
  class Calculate < Command::Abstract
    def initialize(rank_pages)
      super()
      @rank_pages = rank_pages
    end

    def run_proc
      matrix = RankService::Matrix.new @rank_pages
      matrix.generate_matrix
      matrix.iterate_times(50)
      result.succeed!(matrix.rank_pages)
    end
  end
end