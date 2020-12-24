module CacheService
  module Client
    extend self

    def cache_site(site)


    rescue StandardError => e
      handle_cache_failure(page)
      raise e
    end

    private

    def handle_cache_start(page)
      page.cache_status = :active
      page.cache_started_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Starting cache for Page(#{page.id})"
    end

    def handle_cache_failure(page)
      page.cache_status = :failure
      page.cache_finished_at = DateTime.now.utc
      page.save

      Rails.logger.info "Cache failed for Page(#{page.id})"
    end

    def handle_cache_success(page)
      page.cache_status = :success
      page.cache_finished_at = DateTime.now.utc
      page.save!

      Rails.logger.info "Cache succeeded for Page(#{page.id})"
    end
  end
end