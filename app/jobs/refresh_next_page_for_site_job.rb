class RefreshNextPageForSiteJob < ApplicationJob
  queue_as :refresh

  before_perform do |job|
    site_id = job.arguments.first
    Site.transaction do
      site = Site.lock.find(site_id)

      if site.refresh_job_id.present? &&
        site.refresh_job_id != job_id &&
        site.refresh_job_started_at > 10.minutes.ago
        # Make sure this doesn't get retried, needs to be discarded
        raise "Cannot run this job, it is already running on a different worker"
      end

      site.refresh_job_id = job_id
      site.refresh_job_started_at = DateTime.now.utc
      site.save!
    end

    Rails.logger.info "Successfully locked job #{job_id} for Site(#{site_id})"
  end

  after_perform do |job|
    site_id = job.arguments.first
    Site.transaction do
      site = Site.lock.find(site_id)

      if site.refresh_job_id.present? && site.refresh_job_id == job_id
        site.refresh_job_id = nil
        site.refresh_job_started_at = nil
        site.save!
      end
    end

    Rails.logger.info "Successfully unlocked job #{job_id} for Site(#{site_id})"
  end

  def perform(site_id)
    site = Site.find(site_id)
    # Our cheap version of a lock on this page.
    page = nil
    Page.transaction do
      page = Page.lock.refresh_ready_by_site(site).first
      if page.nil?
        RefreshNextPageForSiteJob.set(wait: 10.seconds).perform_later(site.id)
        Rails.logger.info "No pages to refresh.  Try again in 1 minute."
        return
      else
        page.refresh_status = :active
        page.refresh_started_at = DateTime.now.utc
        page.save!
      end
    end

    RefreshService::Client.refresh_page(page)

    if Page.refresh_ready_by_site(site).any?
      RefreshNextPageForSiteJob.perform_later(site.id)
    else
      RefreshNextPageForSiteJob.set(wait: 1.hour).perform_later(site.id)
    end
  end
end
