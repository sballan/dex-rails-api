module RankService
  MAX_RANK_PAGES = ENV.fetch("MAX_RANK_PAGES", 1)
  MAX_RANK_TIME = ENV.fetch("MAX_RANK_TIME", 6.hours)

  module Client
    extend self

    def tick(&block)
      PageMeta.where(rank_status: :active, rank_started_at: DateTime.new(0)..MAX_RANK_TIME.ago)
          .update_all(rank_status: :failure)

      num_active_pages = ::Page.by_meta(rank_status: :active).count
      num_additional_pages = MAX_RANK_PAGES - num_active_pages

                 # uggg...I guess having a Page constant in this module _did_ come back to bite me
      page_ids = ::Page.by_meta(rank_status: :ready).limit(num_additional_pages).pluck(:id)
      block.call(page_ids)
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
