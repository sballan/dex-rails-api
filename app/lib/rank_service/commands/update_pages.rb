module RankService::Commands
  class UpdatePages < Command::Abstract
    def initialize(rank_pages)
      super()
      @rank_pages = rank_pages
    end

    def run_proc
      Page.update(
        @rank_pages.map(&:id),
        @rank_pages.map {|rp| {rank: rp.finish_rank} }
      )
    end
  end
end