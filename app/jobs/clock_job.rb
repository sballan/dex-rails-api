class ClockJob < ApplicationJob
  queue_as :default

  discard_on(Exception) do |job, error|
    Rails.logger.error "Encountered an error while running ClockJob #{job.job_id}.  We cannot retry clock jobs. Error: #{error.message}"
  end

  def perform
    Rails.logger.info "Clock Tick started"

    ClockJob.set(wait: ENV.fetch('CLOCK_INTERVAL', 10.minutes)).perform_later

    JobBatch::Batch.all.each do |jb|
      next unless jb.jobs.empty? && jb.children.empty?

      Rails.logger.info "Batch #{jb.id} is empty, let's handle it."
      jb.finished!
    end

    # To start off, we synchronously fetch all unsuccessful home pages for our sites
    FetchService::Client.tick do |page_ids|
      if page_ids.present?
        Page.where(id: page_ids).find_each do |page|
          FetchService::Client.fetch(page)
        end
      else
        Rails.logger.info "No Sites have a need for fetching"
      end
    end

    CrawlService::Client.tick do |page_ids|
      if page_ids.present?
        page_ids.each {|id| CrawlPageJob.perform_later(id) }
      else
        Rails.logger.info "No pages are crawl_ready"
      end
    end

    IndexService::Client.tick do |page_ids|
      if page_ids.present?
        page_ids.each {|id| IndexPageJob.perform_later(id) }
      else
        Rails.logger.info "No pages are index_ready"
      end
    end

    RankService::Client.tick do |page_ids|
      if page_ids.present?
        page_ids.each {|id| RankPageJob.perform_later(id) }
      else
        Rails.logger.info "No pages are rank_ready"
      end
    end

    Rails.logger.info "Clock Tick finished"
  end
end
