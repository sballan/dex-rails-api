module Command
  class ProcessMechanizePage < Command::Base::Abstract
    # @param [Page] page
    # @param [Mechanize::Page] mechanize_page
    def initialize(page, mechanize_page)
      @page = page
      @mechanize_page = mechanize_page

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      title = @mechanize_page.title
      @page.title = title
      @page.save!

      extract_page_links

      result.succeed!(@page)
    end

    private


    def extract_page_links
      links_to = @mechanize_page.links&.map do |mechanize_link|
        create_page_link_result = create_page_link(mechanize_link)
        create_page_link_result.payload
        # rescue StandardError
        #   nil
      end

      if failed_result = result.results.find(&:failure?)
        Rails.logger.warn "Found a bad link!"
        result.fail!(failed_result.error)
        raise failed_result.error
      else
        @page.links_to = links_to
        @page.save!
      end
    end

    # @param [Mechanize::Page::Link] mechanize_link
    def create_page_link(mechanize_link)
      url = mechanize_link.resolved_uri.to_s

      # Link text should be lowercase words separated by spaces, should not be empty, and must have at least 1 english letter
      text = mechanize_link.text.strip.gsub(/\s/, " ").downcase
      text = nil unless text.match?(/[a-zA-Z]+/)
      text = nil if text.blank?

      create_page_link_command = Command::CreatePageLink.new(@page, url, text)
      run_nested(create_page_link_command)
      create_page_link_command.result
    end
  end
end