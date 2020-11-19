module Command
  class ExtractPageLinks < Command::Base::Abstract
    def initialize(page, page_file)
      @page = page
      @page_file = page_file
      @nokogiri_page = nil

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      links_to = extracted_links.map do |link|
        create_page_link_command = Command::CreatePageLink.new(@page, link[:href], link[:text])
        run_nested(create_page_link_command)
        create_page_link_command.payload
      end

      if result.results.any?(&:failure?)
        result.fail!
        return
      end

      @page.links_to = links_to
      @page.save!
      result.succeed!
    rescue StandardError => e
      result.fail!(e)
    end

    private

    def extracted_links
      nokogiri_page.css('a[href]').map do |a|
        text = a.text.strip
        text = nil if text.empty?
        { text: text, href: a['href'] }
      end
    end

    def nokogiri_page
      return @nokogiri_page unless @nokogiri_page.nil?

      @nokogiri_page = Nokogiri::HTML(@page_file)
      @nokogiri_page
    end
  end
end