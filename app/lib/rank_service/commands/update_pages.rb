module RankService::Commands
  class UpdatePages < Command::Abstract
    def initialize(rank_pages)
      super()
      @rank_pages_map = rank_pages.to_h {|rp| [rp.id, rp]}
    end

    def run_proc
      Page.where(id: @rank_pages.keys).find_each do |page|
        page.with_lock do
          ranked_page = @rank_pages_map[page.id]
          new_rank = ranked_page.finish_rank
          new_rank = (new_rank + page.rank / 2.0) if page.rank.present?
          page.rank = new_rank
          page.save
        end
      end

      result.succeed!
    end
  end
end