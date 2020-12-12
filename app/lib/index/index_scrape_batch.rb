module Index
  class IndexScrapeBatch < Command::Base::Abstract
    def initialize(scrape_batch)
      super()
      @scrape_batch = scrape_batch
    end

    def run_proc
      if @scrape_batch.scrape_pages.parse_success.any?
        num_to_index = @scrape_batch.scrape_pages.parse_success.index_ready.count

        Rails.logger.debug "[Index::IndexScrapeBatch] More pages to index!"
        Rails.logger.info "[Index::IndexScrapeBatch] Starting loop of new Index::IndexScrapePage Command"

        @scrape_batch.scrape_pages.parse_success.index_ready.includes(:page).in_batches.each_record do |scrape_page|
          scrape_page.index_started_at = DateTime.now.utc
          scrape_page.index_status = :active
          scrape_page.save!
          command = Index::IndexScrapePage.new scrape_page
          command.run_with_gc # TODO: need a better convention here.  We catch all errors without the `!`

          if command.success?
            scrape_page.index_status = :success
          else
            scrape_page.index_status = :failure
          end
          scrape_page.index_finished_at = DateTime.now.utc

          scrape_page.save!
        end

        num_left = @scrape_batch.scrape_pages.parse_success.index_ready.count
        Rails.logger.debug "[Index::IndexScrapeBatch] We went from #{num_to_index} to #{num_left}."
      else
        Rails.logger.info "[Index::IndexScrapeBatch] No pages left to index. "
      end

      result.succeed!
    end

  end
end