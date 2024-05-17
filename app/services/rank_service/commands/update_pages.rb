module RankService::Commands
  class UpdatePages < Command::Abstract
    def initialize(rank_pages)
      super()
      @rank_pages_map = rank_pages.to_h { |rp| [rp.id, rp] }
    end

    def run_proc
      Page.where(id: @rank_pages_map.keys).in_batches do |rel|
        attributes_to_update = []
        rel.each do |page|
          ranked_page = @rank_pages_map[page.id]
          new_rank = ranked_page.finish_rank
          new_rank = (new_rank + page.rank / 2.0) if page.rank.present?
          page.rank = new_rank.to_f

          attributes_to_update << page.attributes.slice("id", "rank")
        end

        Page.upsert_all(attributes_to_update, unique_by: :id)
      end

      result.succeed!
    end
  end
end
