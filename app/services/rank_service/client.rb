module RankService
  MAX_RANK_PAGES = ENV.fetch("MAX_RANK_PAGES", 1).to_i
  MAX_RANK_TIME = ENV.fetch("MAX_RANK_TIME", 6.hours).to_i.seconds

  module Client
    extend self

    def tick(&block)
      PageMeta.where(rank_status: :active, rank_started_at: DateTime.new(0)..MAX_RANK_TIME.ago)
        .update_all(rank_status: :failure, rank_finished_at: DateTime.now.utc)

      num_active_pages = PageMeta.rank_active.count
      num_additional_pages = [MAX_RANK_PAGES - num_active_pages, 0].max

      # uggg...I guess having a Page constant in this module _did_ come back to bite me
      page_ids = ::Page.by_meta(rank_status: :ready).limit(num_additional_pages).pluck(:id)
      block.call(page_ids)
    end

    def rank_from_start_page(start_page, max_size)
      GC.start full_mark: true, immediate_sweep: true
      GC.compact

      db_page_count = PageMeta.where.not(rank_status: :dead).count
      rank_pages = collect_pages(start_page, max_size, db_page_count)
      calculate(rank_pages, db_page_count)
      update_pages(rank_pages)

      start_page.meta.update(rank_status: :success, rank_finished_at: DateTime.now.utc)

      GC.start full_mark: true, immediate_sweep: true
      GC.compact
    end

    private

    def collect_pages(start_page, max_size, db_page_count)
      Rails.logger.debug("RankService::Client collect_pages with start_page: #{start_page.id}, max_size: #{max_size}, db_page_count: #{db_page_count}")

      command = Commands::CollectPages.new(start_page, max_size, db_page_count)
      command.run_with_gc!
      command.payload
    end

    def calculate(rank_pages, db_page_count)
      Rails.logger.debug("RankService::Client calculate with #{rank_pages.size} pages and #{db_page_count} db pages")

      command = Commands::Calculate.new(rank_pages, db_page_count)
      command.run!
    end

    def update_pages(rank_pages)
      Rails.logger.debug("RankService::Client update_pages with #{rank_pages.size} pages")

      command = Commands::UpdatePages.new(rank_pages)
      command.run_with_gc!
    end
  end
end
