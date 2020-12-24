class SiteRefreshNextPageJob < ApplicationJob
  queue_as :refresh

  def perform(site_id)
    lock_site(site_id)

    site = Site.find(site_id)

    unless site.scrape_active
      Rails.logger.info "Site(#{site.id}) is not scrape_active. Not refreshing."
      return
    end

    # Our cheap version of a lock on this page.
    page = nil
    Page.transaction do
      page = Page.lock.by_site(site).refresh_ready.first
      if page.nil?
        SiteRefreshNextPageJob.set(wait: 10.seconds).perform_later(site.id)
        Rails.logger.info "No pages to refresh. Trying again in 10 seconds."
        return
      else
        page.refresh_status = :active
        page.refresh_started_at = DateTime.now.utc
        page.save!
      end
    end

    RefreshService::Client.refresh_page(page)

    unlock_site(site_id)

    page.parse_ready!

    if Page.by_site(site).refresh_ready.any?
      SiteRefreshNextPageJob.perform_later(site.id)
    else
      SiteRefreshNextPageJob.set(wait: 5.minutes).perform_later(site.id)
    end
  end

  private

  def lock_site(site_id)
    Site.transaction do
      site = Site.lock.find(site_id)

      if site.refresh_job_id.present? &&
          site.refresh_job_id != job_id &&
          site.refresh_job_started_at > 5.minutes.ago
        # Make sure this doesn't get retried, needs to be discarded
        raise "Cannot run this job, it is already running on a different worker"
      end

      site.refresh_job_id = job_id
      site.refresh_job_started_at = DateTime.now.utc
      site.save!
    end

    Rails.logger.debug "Successfully locked job #{job_id} for Site(#{site_id})"
  end

  def unlock_site(site_id)
    Site.transaction do
      site = Site.lock.find(site_id)

      if site.refresh_job_id.present? && site.refresh_job_id == job_id
        site.refresh_job_id = nil
        site.refresh_job_started_at = nil
        site.save!
      end
    end

    Rails.logger.debug "Successfully unlocked job #{job_id} for Site(#{site_id})"
  end
end
