module RefreshService::Client
  extend self

  def refresh_page(page, refresh_time=1.day.ago)
    if page.refresh_success? && (page.refresh_finished_at > refresh_time)
      return download_cached_page(page)
    end

    handle_refresh_start(page)
    
    mechanize_page = download(page)
    page_file = process_file(mechanize_page)

    key = page.url
    body = page_file 

    if body.present?
      upload_page_to_s3(key, body)
    else
      Rails.logger.info "Got a nil page_file - Page should be marked as dead."
      return nil
    end

    handle_refresh_success(page)
  rescue => e
    handle_refresh_failure(page)
  end

  def download_cached_page(page)
    client = S3Client.new(ENV['DEV_BUCKET'], 'page_files')
    key = Base64.urlsafe_encode64(page.url)
    body = client.read(key: key).body.read
    Rails.logger.debug "Fetched page_file from S3: #{page.url}"
    body
  end

  private
  
  def process_file(mechanize_page)
    return nil if mechanize_page.nil?

    nokogiri_doc = mechanize_page.parser
    command = Command::ProcessNokogiriDoc.new(nokogiri_doc)
    command.run_with_gc!
    command.payload
  end

  def mechanize_page(page)
    command = Refresh::DownloadMechanizePage.new(page.url)
    command.run_with_gc!
    command.payload
  rescue Command::Base::Errors::CommandInvalid => e
    Rails.logger.warn "This Page failed permanently to download #{page.id}."
    page.refresh_status = :dead
    page.refresh_finished_at = DateTime.now.utc
    page.save
    nil
  rescue Command::Base::Errors::CommandFailed => e
    Rails.logger.error "This ScrapePage failed to download #{page.id}"
    page.refresh_status = :failure
    page.save
    raise e
  end

  def upload_page_to_s3(key, body)
    command = Command::UploadPageToS3.new(key, body)
    command.run_with_gc!
    command.payload
  end

  def handle_refresh_start(page)
    page.refresh_status = :active
    page.refresh_started_at = DateTime.now.utc
    page.save!

    Rails.logger.info "Starting refresh for Page(#{page.id})"
  end    
  
  def handle_refresh_failure(page)
    page.refresh_status = :failure
    page.refresh_finished_at = DateTime.now.utc
    page.save

    Rails.logger.info "Refresh failed for Page(#{page.id})"
  end    

  def handle_refresh_success(page)
    page.refresh_status = :success
    page.refresh_finished_at = DateTime.now.utc
    page.save!

    Rails.logger.info "Refresh succeeded for Page(#{page.id})"
  end
end
